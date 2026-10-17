import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/nutritional_utils.dart';
import '../utils/wic_categories.dart';

/// Service for querying the Approved Product List (APL) from [FirebaseFirestore].
///
/// The APL collection contains WIC-eligible products with their UPC codes,
/// names, categories, and eligibility status. This service provides methods
/// to look up products and find substitutes within the same category.
///
/// The NC APL carries no nutrition data. Nutrition comes from the separate
/// `nutrition/{upc}` collection (see scripts/enrich_nutrition_off.cjs), which
/// is merged in here so the APL import itself stays unchanged.
class AplService {
  // final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  AplService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  /// Looks up a product by its Universal Product Code (UPC).
  ///
  /// Queries the `apl` collection in [FirebaseFirestore] using the [upc]
  /// as the document ID.
  ///
  /// Returns a [Map] with product data (name, category, eligible, etc.)
  /// if found, or null if the product doesn't exist in the APL.
  ///
  /// Example return value:
  /// ```dart
  /// {
  ///   'upc': '000000743266',
  ///   'name': 'Whole Milk',
  ///   'category': 'Milk',
  ///   'eligible': true
  /// }
  /// ```
  ///
  /// The returned `category` is canonical ([WicCategories]); the APL's own
  /// text is kept in `sourceCategory`. When the APL record has no
  /// `foodNutrients`, they are filled from `nutrition/{upc}` if present.
  Future<Map<String, dynamic>?> findByUpc(String upc) async {
    final doc = await _db.collection('apl').doc(upc).get();
    if (!doc.exists) return null;
    final data = Map<String, dynamic>.from(doc.data() ?? const {});
    if (data['category'] != null || data['categoryCode'] != null) {
      data['sourceCategory'] = data['category'];
      data['category'] = WicCategories.canonical(
        data['category'],
        code: data['categoryCode'],
      );
    }
    if (!_hasNutrients(data)) {
      final nutrition = await _nutritionDoc(upc);
      if (nutrition != null) {
        data['foodNutrients'] = nutrition['foodNutrients'];
        if (nutrition['servingBasis'] is String) {
          data['servingBasis'] = nutrition['servingBasis'];
        }
        data['nutritionSource'] = nutrition['source'];
      }
    }
    return data;
  }

  static bool _hasNutrients(Map<String, dynamic> data) =>
      data['foodNutrients'] is List &&
      (data['foodNutrients'] as List).isNotEmpty;

  /// `nutrition/{upc}`, or null when absent or not readable.
  Future<Map<String, dynamic>?> _nutritionDoc(String upc) async {
    try {
      final doc = await _db.collection('nutrition').doc(upc).get();
      return doc.exists ? doc.data() : null;
    } on FirebaseException {
      // Rules may not allow nutrition reads yet: nutrition stays unknown.
      return null;
    }
  }

  /// Products in `nutrition/` for this category whose APL record exists and
  /// is eligible, shaped like an APL document with `foodNutrients`.
  Future<List<Map<String, dynamic>>> _nutritionCandidates(
    String category, {
    Object? categoryCode,
    int max = 30,
  }) async {
    var code = (categoryCode ?? '').toString().trim();
    final canonical = WicCategories.canonical(category, code: code);
    if (code.isEmpty) {
      code =
          WicCategories.nameByCode.entries
              .where((e) => e.value == canonical)
              .map((e) => e.key)
              .firstOrNull ??
          '';
    }
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
    try {
      final collection = _db.collection('nutrition');
      final query = code.isNotEmpty
          ? collection.where('categoryCode', isEqualTo: code)
          : collection.where('category', isEqualTo: canonical);
      docs = (await query.limit(max).get()).docs;
    } on FirebaseException {
      return [];
    }
    final results = <Map<String, dynamic>>[];
    for (final doc in docs) {
      final apl = await _db.collection('apl').doc(doc.id).get();
      final aplData = apl.data();
      if (aplData == null || aplData['eligible'] != true) continue;
      results.add({
        ...aplData,
        'upc': doc.id,
        'category': WicCategories.canonical(
          aplData['category'],
          code: aplData['categoryCode'],
        ),
        'foodNutrients': doc.data()['foodNutrients'],
        if (doc.data()['servingBasis'] is String)
          'servingBasis': doc.data()['servingBasis'],
        'nutritionSource': doc.data()['source'],
      });
    }
    return results;
  }

  /// Finds WIC-eligible substitute products in the same category.
  ///
  /// Queries the `apl` collection for products matching the given [category]
  /// where `eligible` is true. Results are limited to [max] items (default 3).
  ///
  /// This is useful when a user's preferred product would exceed their
  /// category limit, allowing the app to suggest alternatives.
  ///
  /// Parameters:
  /// - [category]: The product category to search within
  /// - [max]: Maximum number of substitutes to return (default: 3)
  ///
  /// Returns a [List] of product [Map]s with the same structure as [findByUpc].
  Future<List<Map<String, dynamic>>> substitutes(
    String category, {
    int max = 3,
  }) async {
    final query = await _db
        .collection('apl')
        .where('category', isEqualTo: category)
        .where('eligible', isEqualTo: true)
        .limit(max)
        .get();

    return query.docs.map((d) => d.data()).toList();
  }

  /// Computes a health score for a product based on its foodNutrients array.
  ///
  /// Analyzes key nutrients from USDA FDC data (energy, sugars, sodium, fats,
  /// fiber, protein) to generate a numeric score. Lower scores indicate healthier
  /// products.
  ///
  /// Penalties (higher = worse):
  /// - Energy (kcal), total/added sugars, sodium, saturated/trans fats
  /// Bonuses (higher = better):
  /// - Dietary fiber, protein
  ///
  /// This score enables ranking and comparison of products within the same category
  /// for "healthier alternative" suggestions.
  ///
  /// Parameters:
  /// - [data]: Firestore document data containing `foodNutrients` array
  ///
  /// Returns a [double] where lower values = healthier product.
  double _computeHealthScore(Map<String, dynamic> data) {
    final nutrients = (data['foodNutrients'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    // Helper function to return numerical amount of given nutrient
    double getAmt(String name) {
      final n = nutrients.firstWhere(
        (m) => (m['name'] as String?)?.toLowerCase() == name.toLowerCase(),
        orElse: () => const {},
      );
      final v = n['amount'];
      return v is num ? v.toDouble() : 0.0;
    }

    final energy = getAmt('Energy');
    final sugar = getAmt('Total Sugars');
    final addedSugar = getAmt('Sugars, added');
    final sodium = getAmt('Sodium, Na');
    final satFat = getAmt('Fatty acids, total saturated');
    final transFat = getAmt('Fatty acids, total trans');
    final fiber = getAmt('Fiber, total dietary');
    final protein = getAmt('Protein');

    final penalties =
        energy * 0.01 +
        sugar * 0.5 +
        addedSugar * 0.7 +
        sodium * 0.01 +
        satFat * 1.0 +
        transFat * 2.0;

    final bonuses = fiber * 1.5 + protein * 0.3;

    return penalties - bonuses;
  }

  /// Finds healthier substitute products in the same category.
  ///
  /// Queries the `apl` collection for WIC-eligible products matching the given
  /// [category], computes health scores for each, and returns the top [max] (default 5)
  /// products with **better** (lower) health scores than the [baseProduct].
  ///
  /// Each candidate is scored using `_computeHealthScore` based on foodNutrients.
  /// Results are sorted by health score (ascending) with `healthScore` and `upc`
  /// fields added to the returned maps.
  ///
  /// This powers the "healthier alternatives" UI feature - when clicked, users
  /// can swap their scanned item for a nutritionally superior option in the same
  /// WIC category.
  ///
  /// Parameters:
  /// - [category]: Exact category match for substitutes
  /// - [baseProduct]: Currently scanned product for score comparison
  /// - [max]: Maximum number of healthier substitutes to return (default: 5)
  ///
  /// Returns a [List] of product [Map]s (sorted by health score) that are nutritionally
  /// superior to the base product. Empty list if no better options found.
  Future<List<Map<String, dynamic>>> healthierSubstitutes({
    required String category,
    required Map<String, dynamic> baseProduct,
    int max = 5,
  }) async {
    if (category.trim().isEmpty) return [];
    // Without nutrition for the scanned item there is nothing to compare.
    if (!_hasNutrients(baseProduct)) return [];
    final baseScore = _computeHealthScore(baseProduct);
    final snap = await _db
        .collection('apl')
        .where('category', isEqualTo: baseProduct['sourceCategory'] ?? category)
        .where('eligible', isEqualTo: true)
        .limit(50)
        .get();

    final candidates = <String, Map<String, dynamic>>{
      for (final doc in snap.docs) doc.id: {...doc.data(), 'upc': doc.id},
    };
    for (final c in await _nutritionCandidates(
      category,
      categoryCode: baseProduct['categoryCode'],
    )) {
      // The enriched record replaces the bare APL one for the same UPC.
      candidates[c['upc'] as String] = c;
    }

    final results = <Map<String, dynamic>>[];

    for (final data in candidates.values) {
      if ((data['fdcId'] != null && data['fdcId'] == baseProduct['fdcId']) ||
          data['upc'] == (baseProduct['upc'] ?? '')) {
        continue;
      }
      // An item with no nutrition data must not look "healthier" (score 0).
      if (!_hasNutrients(data)) continue;

      final score = _computeHealthScore(data);
      if (score < baseScore) {
        data['healthScore'] = score;
        results.add(data);
      }
    }

    results.sort((a, b) {
      final sa = a['healthScore'];
      final sb = b['healthScore'];
      final da = (sa is num) ? sa.toDouble() : double.infinity;
      final db = (sb is num) ? sb.toDouble() : double.infinity;
      return da.compareTo(db);
    });

    if (results.length > max) {
      return results.sublist(0, max);
    }
    return results;
  }

  /// Eligible same-category products for the M2 basket balance check.
  ///
  /// Each result is `{upc, name, category, eligible, nutrition}` with the M1
  /// nutrition map, so missing nutrients stay null.
  ///
  /// Candidates come from `nutrition/` (checked against the APL for
  /// eligibility) plus any APL records that carry `foodNutrients` themselves.
  Future<List<Map<String, dynamic>>> balanceCandidates(
    String category, {
    int max = 25,
  }) async {
    if (category.trim().isEmpty) return [];
    final canonical = WicCategories.canonical(category);
    final byUpc = <String, Map<String, dynamic>>{};
    for (final c in await _nutritionCandidates(canonical, max: max)) {
      byUpc[c['upc'] as String] = c;
    }
    final snap = await _db
        .collection('apl')
        .where('category', isEqualTo: canonical)
        .where('eligible', isEqualTo: true)
        .limit(max)
        .get();
    for (final doc in snap.docs) {
      if (_hasNutrients(doc.data())) {
        byUpc.putIfAbsent(doc.id, () => {...doc.data(), 'upc': doc.id});
      }
    }
    return [
      for (final data in byUpc.values)
        {
          'upc': data['upc'],
          'name': data['name'] ?? data['upc'],
          'category': WicCategories.canonical(
            data['category'] ?? canonical,
            code: data['categoryCode'],
          ),
          'eligible': data['eligible'] == true,
          'nutrition': NutritionalUtils.buildNutritionFromFoodNutrients(data),
          if (data['nutritionSource'] != null)
            'source': data['nutritionSource'],
        },
    ];
  }
}
