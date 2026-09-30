import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/nutritional_utils.dart';

/// Central application state manager that handles user-scoped WIC benefits
/// balances and shopping basket data.
///
/// This [ChangeNotifier] persists data to [FirebaseFirestore] and derives
/// sensible default caps for each WIC category when first encountered.
/// APL (Approved Product List) documents do NOT carry caps - they are
/// managed entirely within this state.
///
/// Usage: Wire this into your app via [ChangeNotifierProxyProvider] in
/// [main.dart] to automatically sync with [FirebaseAuth] state changes.
class AppState extends ChangeNotifier {
  // final _db = FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  AppState({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  // ---------- Reactive data ----------

  /// User-specific WIC benefit balances by category.
  ///
  /// Maps canonical category names (uppercase, normalized) to balance objects
  /// containing:
  /// - `'allowed'`: [int]? - Maximum items allowed (null = uncapped, e.g., CVB)
  /// - `'used'`: [int] - Number of items currently in basket
  ///
  /// Example: `{ 'MILK': { 'allowed': 3, 'used': 1 } }`
  Map<String, Map<String, dynamic>> balances = {};

  /// The user's current shopping basket.
  ///
  /// Each item is a [Map] with keys:
  /// - `'upc'`: [String] - Universal Product Code
  /// - `'name'`: [String] - Product display name
  /// - `'category'`: [String] - Canonical category (uppercase)
  /// - `'qty'`: [int] - Quantity of this item
  final List<Map<String, dynamic>> basket = [];

  // ---------- Auth/user ----------

  /// The currently authenticated user's unique ID from [FirebaseAuth].
  ///
  /// Null when no user is logged in.
  String? _uid;

  /// Whether user-specific [balances] data has been loaded from [FirebaseFirestore].
  ///
  /// Screens can check this before displaying balance information.
  bool _balancesLoaded = false;

  /// Public getter for [_balancesLoaded].
  ///
  /// Returns true after [loadUserState] completes successfully.
  bool get balancesLoaded => _balancesLoaded;

  // ---------- Public: wire auth state into AppState ----------

  /// Updates the internal user reference and triggers state reload.
  ///
  /// This is called by the [ChangeNotifierProxyProvider] in [main.dart]
  /// whenever the [FirebaseAuth] state changes. If [user] is null,
  /// all data is cleared. Otherwise, [loadUserState] is called in the
  /// background to fetch persisted data.
  ///
  /// Side effects:
  /// - Clears [balances] and [basket] if logged out
  /// - Calls [notifyListeners] to rebuild widgets
  /// - Initiates [loadUserState] for logged-in users
  void updateUser(User? user) {
    _uid = user?.uid;
    if (_uid == null) {
      _clear();
      notifyListeners();
      return;
    }
    _balancesLoaded = false;
    // fire-and-forget load; UI can check balancesLoaded
    // ignore: discarded_futures
    loadUserState();
    notifyListeners();
  }

  // ---------- Helpers ----------

  /// Clears all local state data.
  ///
  /// Resets [balances], [basket], and [_balancesLoaded] flag.
  /// Does NOT persist to [FirebaseFirestore] - use [_persist] for that.
  void _clear() {
    balances = {};
    basket.clear();
    _balancesLoaded = false;
  }

  /// Canonicalizes a category string for consistent storage and comparison.
  ///
  /// Trims whitespace, collapses multiple spaces to single spaces, and
  /// converts to uppercase.
  ///
  /// Example: `"  Milk Products  "` becomes `"MILK PRODUCTS"`
  String _canon(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();

  /// Derives a default allowed quantity for a newly encountered category.
  ///
  /// Returns `null` for uncapped categories (CVB, Fruits & Vegetables).
  /// Returns sensible defaults for common WIC categories:
  /// - Dairy (milk, cheese, yogurt): 3-4 items
  /// - Bread & Grains: 2 items
  /// - Protein (meat, beans, peanut butter): 1-2 items
  /// - Juice: 1 item
  /// - Default: 2 items
  ///
  /// This is called by [_ensureCategoryInit] when a category is first added
  /// to [balances].
  int? _deriveAllowed(String canonCat) {
    // you can use money
    if (canonCat.toUpperCase() == 'PAID') {
      return null;
    }
    // CVB / Fruit & Veg — uncapped
    if (canonCat.contains('CVB') ||
        canonCat.contains('FRUIT') ||
        canonCat.contains('VEGETABLE')) {
      return null;
    }
    // Dairy
    if (canonCat.contains('MILK') ||
        canonCat.contains('CHEESE') ||
        canonCat.contains('YOGURT') ||
        canonCat.contains('DAIRY')) {
      return 3;
    }
    // Bread
    if (canonCat.contains('BREAD') ||
        canonCat.contains('GRAIN') ||
        canonCat.contains('CEREAL')) {
      return 2;
    }
    // Protein
    if (canonCat.contains('MEAT') ||
        canonCat.contains('BEAN') ||
        canonCat.contains('PEANUT')) {
      return 1;
    }
    // Juice
    if (canonCat.contains('JUICE')) {
      return 1;
    }
    // Default
    return 2;
  }

  /// Ensures the given canonical category exists in [balances] with defaults.
  ///
  /// If [canonCat] is not yet in [balances], initializes it with:
  /// - `'allowed'`: derived from [_deriveAllowed]
  /// - `'used'`: 0
  ///
  /// If it exists, ensures both keys are present.
  void _ensureCategoryInit(String canonCat) {
    if (!balances.containsKey(canonCat)) {
      balances[canonCat] = {
        'allowed': _deriveAllowed(canonCat), // may be null (uncapped)
        'used': 0,
      };
      return;
    }
    final m = balances[canonCat]!;
    m.putIfAbsent('allowed', () => _deriveAllowed(canonCat));
    m.putIfAbsent('used', () => 0);
  }

  /// Checks if another item from the given canonical category can be added.
  ///
  /// Returns true if:
  /// - The category is uncapped (allowed is null), OR
  /// - The used count is less than the allowed count
  ///
  /// Returns false if the limit has been reached.
  bool _canAddCanon(String canonCat) {
    final allowed = balances[canonCat]?['allowed'];
    final used = (balances[canonCat]?['used'] ?? 0) as int;
    if (allowed is int) return used < allowed;
    return true; // uncapped
  }

  /// Checks if the last update was in a previous month/year compared to now.
  bool _isNewMonth(Timestamp? lastUpdate) {
    if (lastUpdate == null) return false; // No history, assume fresh
    final last = lastUpdate.toDate();
    final now = DateTime.now();
    return last.month != now.month || last.year != now.year;
  }

  /// Resets all "used" counts to 0 and clears the basket.
  void _resetMonthlyUsage() {
    balances.forEach((key, value) {
      value['used'] = 0;
    });
    basket.clear();

    _persist();
    notifyListeners();
  }

  // ---------- Firestore I/O ----------

  /// Loads user-specific [balances] and [basket] from [FirebaseFirestore].
  ///
  /// Fetches the document at `users/{uid}` and populates local state.
  /// If the document doesn't exist, creates an empty scaffold via [_persist].
  /// All category names are canonicalized via [_canon].
  ///
  /// Side effects:
  /// - Sets [_balancesLoaded] to true on completion
  /// - Calls [notifyListeners] to update UI
  /// - Creates Firestore document for first-time users
  Future<void> loadUserState() async {
    if (_uid == null) {
      _clear();
      notifyListeners();
      return;
    }

    try {
      final doc = await _db.collection('users').doc(_uid).get();
      final data = doc.data();

      if (data == null) {
        // First-time user: start empty; caps derive on demand
        _clear();
        await _persist(); // create doc scaffold
      } else {
        // balances
        final b = (data['balances'] as Map?) ?? {};
        balances = b.map((k, v) {
          final key = _canon(k.toString());
          final allowed = (v is Map && v['allowed'] is int)
              ? v['allowed'] as int
              : null;
          final used = (v is Map && v['used'] is int) ? v['used'] as int : 0;
          return MapEntry(key, {'allowed': allowed, 'used': used});
        });

        // basket
        final raw = (data['basket'] as List?) ?? [];
        basket
          ..clear()
          ..addAll(
            raw.whereType<Map>().map((m) {
              final cat = _canon((m['category'] ?? '').toString());
              return {
                'upc': (m['upc'] ?? '').toString(),
                'name': (m['name'] ?? '').toString(),
                'category': cat,
                // Keep the original category separate from the PAID label.
                // Old paid records without it remain unknown; do not invent it.
                if (m['original_benefit_category'] is String)
                  'original_benefit_category': _canon(
                    m['original_benefit_category'] as String,
                  )
                else if (cat != 'PAID')
                  'original_benefit_category': cat,
                if (m['checkout_help_source'] == 'synthetic' &&
                    m['checkout_help_scenario_id'] is String) ...{
                  'checkout_help_source': 'synthetic',
                  'checkout_help_scenario_id': m['checkout_help_scenario_id'],
                },
                'qty': (m['qty'] is int) ? m['qty'] as int : 1,
                'nutrition':
                    m['nutrition'] as Map<String, dynamic>? ??
                    const {
                      'calories': 0.0,
                      'totalFat': 0.0,
                      'saturatedFat': 0.0,
                      'transFat': 0.0,
                      'sodium': 0.0,
                      'sugar': 0.0,
                      'addedSugar': 0.0,
                      'protein': 0.0,
                      'fiber': 0.0,
                    },
              };
            }),
          );

        // Check if we need a monthly reset
        final lastUpdate = data['updatedAt'] as Timestamp?;
        if (_isNewMonth(lastUpdate)) {
          print("📅 New month detected! Resetting balances...");
          _resetMonthlyUsage();
        }
      }
    } finally {
      _balancesLoaded = true;
      notifyListeners();
    }
  }

  /// Persists current [balances] and [basket] to [FirebaseFirestore].
  ///
  /// Updates the document at `users/{uid}` with current state and a
  /// server timestamp. Uses merge mode to preserve other fields.
  ///
  /// This is called after any mutation ([addItem], [incrementItem],
  /// [decrementItem]) to keep Firestore in sync.
  Future<void> _persist() async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).set({
      'balances': balances,
      'basket': basket,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ---------- Public API used by screens ----------

  /// Returns true if another item from the given category can be added.
  ///
  /// The [categoryRaw] string is canonicalized before checking against
  /// [balances]. Returns true for first-time categories (will be capped
  /// on first [addItem] call).
  ///
  /// Used by UI to enable/disable "Add" buttons.
  bool canAdd(String categoryRaw) {
    final cat = _canon(categoryRaw);
    if (!balances.containsKey(cat)) return true; // first time seen -> allowed
    return _canAddCanon(cat);
  }

  /// Adds one item to the [basket] and updates [balances].
  ///
  /// If an item with the same [upc] already exists, increments its quantity
  /// via [incrementItem] and returns false.
  ///
  /// Otherwise, creates a new basket line with qty=1, increments the category's
  /// used count, and persists via [_persist].
  ///
  /// Parameters:
  /// - [upc]: Universal Product Code
  /// - [name]: Display name for the product
  /// - [category]: Raw category string (will be canonicalized)
  /// - [nutrition]: Nutrition data (map of maps)
  ///
  /// Returns true if a new line was created, false if only quantity increased.
  ///
  /// Side effects:
  /// - Calls [_ensureCategoryInit] to set default caps
  /// - Calls [_persist] to save to [FirebaseFirestore]
  /// - Calls [notifyListeners] to update UI
  bool addItem({
    required String upc,
    required String name,
    required String category,
    Map<String, dynamic>? nutrition,
  }) {
    if (_uid == null) return false;
    final cat = _canon(category);

    _ensureCategoryInit(cat);

    // Check if the item already exists in some form
    final idx = basket.indexWhere((e) => e['upc'] == upc && upc.isNotEmpty);
    if (idx >= 0) {
      // existing line -> increment path
      incrementItem(upc, category);
      return false;
    }

    // If it doesn't exist, we try to add it.
    // If regular category is full, we must check if we can add to PAID logic,
    // but typically addItem implies adding a NEW line.
    if (!_canAddCanon(cat)) {
      // If we can't add to canonical, logic dictates we probably shouldn't add
      // the initial WIC item. However, user might expect auto-PAID.
      // For now, retaining original logic: prevent add if full.
      // Use incrementItem on an existing item to trigger overflow.
      return false;
    }

    // Generate nutritional data if not provided
    final nutritionData =
        nutrition ??
        const {
          'calories': 0.0,
          'totalFat': 0.0,
          'saturatedFat': 0.0,
          'transFat': 0.0,
          'sodium': 0.0,
          'sugar': 0.0,
          'addedSugar': 0.0,
          'protein': 0.0,
          'fiber': 0.0,
        };

    basket.add({
      'upc': upc,
      'name': name,
      'category': cat,
      'qty': 1,
      'original_benefit_category': cat,
      'nutrition': nutritionData,
    });
    balances[cat]!['used'] = (balances[cat]!['used'] ?? 0) + 1;

    // persist (fire-and-forget)
    // ignore: discarded_futures
    _persist();
    notifyListeners();
    return true;
  }

  // bool addItemFromProduct(Map<String, dynamic> product) {
  //   final nutrition =
  //       NutritionalUtils.buildNutritionFromFoodNutrients(product);
  //   return addItem(
  //     upc: product['upc'] ?? '',
  //     name: product['name'] ?? 'Unknown',
  //     category: product['category'] ?? 'Unknown',
  //     nutrition: nutrition,
  //   );
  // }

  /// Increases the quantity of an existing basket item by 1.
  ///
  /// Searches [basket] for an item with matching [upc], increments its
  /// `'qty'` field, and updates the category's used count in [balances].
  /// Increases the quantity of a product.
  ///
  /// 1. Tries to fill the original WIC category first.
  /// 2. If the WIC category is full (capped), it overflows into the 'PAID' category.
  ///    This will either find an existing 'PAID' item for this UPC or create a new one.
  ///
  /// Side effects:
  /// - Calls [_persist] to save to [FirebaseFirestore]
  /// - Calls [notifyListeners] to update UI
  void incrementItem(String upc, String category) {
    if (_uid == null) return;

    final originalCat = _canon(category);
    _ensureCategoryInit(originalCat);

    // 1. Check if we can add to the requested (original) category
    if (_canAddCanon(originalCat)) {
      // Find the specific line item corresponding to this category/upc
      final index = basket.indexWhere(
        (e) => e['upc'] == upc && _canon(e['category']) == originalCat,
      );

      if (index >= 0) {
        basket[index]['qty'] = (basket[index]['qty'] ?? 1) + 1;
        balances[originalCat]!['used'] =
            (balances[originalCat]!['used'] ?? 0) + 1;
      }
      // Note: If index < 0, it means the item isn't in basket yet.
      // Usually addItem handles creation, but if reached here, we skip.
    } else {
      // 2. Original category is full; Fill up PAID category instead.
      const String paidCategory = 'PAID';
      _ensureCategoryInit(paidCategory);

      final paidIndex = basket.indexWhere(
        (e) =>
            e['upc'] == upc && _canon(e['category'] as String) == paidCategory,
      );

      if (paidIndex >= 0) {
        // Increment existing PAID item
        basket[paidIndex]['qty'] = (basket[paidIndex]['qty'] ?? 1) + 1;
        balances[paidCategory]!['used'] =
            (balances[paidCategory]!['used'] ?? 0) + 1;
      } else {
        // Create new PAID item based on the original item's details
        // We need to find the original WIC item to copy details (name/nutrition)
        final wicItem = basket.firstWhere(
          (e) => e['upc'] == upc && _canon(e['category']) == originalCat,
          orElse: () => {},
        );

        if (wicItem.isNotEmpty) {
          basket.add({
            'upc': upc,
            'name': wicItem['name'],
            'category': paidCategory,
            'qty': 1,
            'original_benefit_category':
                wicItem['original_benefit_category'] ?? originalCat,
            'nutrition': wicItem['nutrition'], // Shared nutrition data
          });
          balances[paidCategory]!['used'] =
              (balances[paidCategory]!['used'] ?? 0) + 1;
        }
      }
    }

    // ignore: discarded_futures
    _persist();
    notifyListeners();
  }

  /// Decreases the quantity of a product.
  ///
  /// 1. Checks if a 'PAID' version of this item exists (overflow).
  /// 2. If 'PAID' exists, decrements that first (removing it if qty hits 0).
  /// 3. If no 'PAID' version exists, decrements the original WIC item.
  ///
  /// Side effects:
  /// - Calls [_persist] to save to [FirebaseFirestore]
  /// - Calls [notifyListeners] to update UI
  void decrementItem(String upc, String category) {
    if (_uid == null) return;

    const String paidCategory = 'PAID';
    final originalCat = _canon(category);

    // 1. Check if a 'PAID' line item for this product exists
    final paidIndex = basket.indexWhere(
      (e) => e['upc'] == upc && _canon(e['category'] as String) == paidCategory,
    );

    if (paidIndex >= 0) {
      // PAID category exists -> Decrease that
      final newQty = (basket[paidIndex]['qty'] ?? 1) - 1;

      // Update balance
      if (balances.containsKey(paidCategory)) {
        final used = (balances[paidCategory]!['used'] ?? 0) as int;
        balances[paidCategory]!['used'] = (used - 1).clamp(0, 999);
      }

      if (newQty <= 0) {
        basket.removeAt(paidIndex);
      } else {
        basket[paidIndex]['qty'] = newQty;
      }
    } else {
      // 2. No PAID category -> Decrease original category
      final wicIndex = basket.indexWhere(
        (e) =>
            e['upc'] == upc && _canon(e['category'] as String) == originalCat,
      );

      if (wicIndex >= 0) {
        final newQty = (basket[wicIndex]['qty'] ?? 1) - 1;

        if (balances.containsKey(originalCat)) {
          final used = (balances[originalCat]!['used'] ?? 0) as int;
          balances[originalCat]!['used'] = (used - 1).clamp(0, 999);
        }

        if (newQty <= 0) {
          basket.removeAt(wicIndex);
        } else {
          basket[wicIndex]['qty'] = newQty;
        }
      }
    }

    // ignore: discarded_futures
    _persist();
    notifyListeners();
  }

  Future<void> checkout() async {
    if (_uid == null) return;

    basket.clear();

    await _persist();
    notifyListeners();
  }

  void clearBasket() {
    if (_uid == null) return;

    for (final item in basket) {
      final cat = _canon(item['category'] as String);
      final qty = item['qty'] as int;

      if (balances.containsKey(cat)) {
        final currentUsed = (balances[cat]!['used'] ?? 0) as int;
        balances[cat]!['used'] = (currentUsed - qty).clamp(0, 999);
      }
    }

    basket.clear();

    _persist();
    notifyListeners();
  }
}
