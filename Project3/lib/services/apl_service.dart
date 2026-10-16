import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for querying the Approved Product List (APL) from [FirebaseFirestore].
///
/// The APL collection contains WIC-eligible products with their UPC codes,
/// names, categories, and eligibility status. This service provides methods
/// to look up products and find substitutes within the same category.
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
  Future<Map<String, dynamic>?> findByUpc(String upc) async {
    final doc = await _db.collection('apl').doc(upc).get();
    if (!doc.exists) return null;
    return doc.data();
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

    final penalties = energy * 0.01 +
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
    final baseScore = _computeHealthScore(baseProduct);
    final snap = await _db
        .collection('apl')
        .where('category', isEqualTo: category)
        .where('eligible', isEqualTo: true)
        .limit(50)
        .get();
    
    final results = <Map<String, dynamic>>[];

    for (final doc in snap.docs) {
      final data = doc.data();
      if (data['fdcId'] == baseProduct['fdcId'] ||
          doc.id == (baseProduct['upc'] ?? '')) {
            continue;
      }

      final score = _computeHealthScore(data);
      if (score < baseScore) {
        data['healthScore'] = score;
        data['upc'] = doc.id;
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
}
