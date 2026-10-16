import 'package:flutter/material.dart';

/// Utility class for determining nutritional badges based on product information.
///
/// Defines thresholds for various nutritional categories and provides methods
/// to calculate which badges a product should display based on its nutritional data.
class NutritionalUtils {
  // Nutritional thresholds (per serving)
  static const int lowFatThreshold = 3; // grams
  static const int lowSodiumThreshold = 140; // mg
  static const int lowSugarThreshold = 5; // grams
  static const int highProteinThreshold = 10; // grams
  static const int lowCalorieThreshold = 120; // calories
  static const int heartHealthyMaxSaturatedFat = 1; // grams
  static const int heartHealthyMaxSodium = 140; // mg

  /// Measurement basis shown with nutrition values.
  ///
  /// The source data does not state whether amounts are per serving or per
  /// 100 g, so this stays neutral until verified against the APL records.
  /// If verified, change this one line (e.g. to 'per 100 g').
  static const String defaultServingBasis = 'Serving basis not specified';

  /// Units shown next to each nutrient's value.
  static const Map<String, String> nutrientUnits = {
    'calories': 'cal',
    'totalFat': 'g',
    'saturatedFat': 'g',
    'transFat': 'g',
    'sodium': 'mg',
    'sugar': 'g',
    'addedSugar': 'g',
    'protein': 'g',
    'fiber': 'g',
  };

  /// Short, plain-language explanation shown under each nutrient.
  static const Map<String, String> nutrientExplanations = {
    'calories': 'Energy this food provides per the listed amount.',
    'totalFat': 'Combined saturated and unsaturated fat in this food.',
    'saturatedFat':
        'A type of fat linked to higher cholesterol when eaten in excess.',
    'sodium': 'High sodium intake is linked to increased blood pressure.',
    'sugar': 'Includes natural and added sugars in this food.',
    'protein': 'Supports muscle repair and helps you feel full.',
    'fiber': 'Supports digestion; most people do not get enough.',
  };

  /// A nutrition map with every value null (unknown).
  ///
  /// Used when a product has no nutrition data, so the UI shows "Unknown"
  /// instead of silently treating missing data as zero.
  static Map<String, dynamic> get unknownNutrition => {
    'calories': null,
    'totalFat': null,
    'saturatedFat': null,
    'transFat': null,
    'sodium': null,
    'sugar': null,
    'addedSugar': null,
    'protein': null,
    'fiber': null,
    'wicEligible': null,
    'servingBasis': null,
  };

  /// Formats a nutrient value with its unit, or "Unknown" if null.
  static String formatNutrient(num? value, String unit) {
    if (value == null) return 'Unknown';
    final text = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
    return '$text$unit';
  }

  /// Describes how an alternative compares to a base product for one
  /// nutrient, without assuming either value is known.
  ///
  /// Reports the direction (Lower/Higher) and whether that is better or a
  /// tradeoff, depending on [lowerIsBetter].
  static String compareTradeoff(
    String label,
    num? base,
    num? alternative,
    String unit, {
    bool lowerIsBetter = true,
  }) {
    if (base == null || alternative == null) {
      return '$label: unknown for one or both items';
    }
    if (base == alternative) {
      return '$label unchanged (${formatNutrient(alternative, unit)})';
    }
    final direction = alternative < base ? 'Lower' : 'Higher';
    final isBetter = lowerIsBetter ? alternative < base : alternative > base;
    final verdict = isBetter ? 'better' : 'tradeoff';
    return '$label: $direction, $verdict '
        '(${formatNutrient(alternative, unit)} vs '
        '${formatNutrient(base, unit)})';
  }

  /// Builds a normalized nutrition map from a product's foodNutrients array.
  ///
  /// A nutrient that is not present in [data] is returned as null, not 0.0,
  /// so the UI and badge logic can distinguish "known to be zero" from
  /// "unknown."
  static Map<String, dynamic> buildNutritionFromFoodNutrients(
    Map<String, dynamic> data,
  ) {
    final nutrients = (data['foodNutrients'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    double? getAmt(String name) {
      final n = nutrients.firstWhere(
        (m) => (m['name'] as String?)?.toLowerCase() == name.toLowerCase(),
        orElse: () => const {},
      );
      final v = n['amount'];
      return v is num ? v.toDouble() : null;
    }

    return {
      'calories': getAmt('Energy'),
      'totalFat': getAmt('Total lipid (fat)'),
      'saturatedFat': getAmt('Fatty acids, total saturated'),
      'transFat': getAmt('Fatty acids, total trans'),
      'sodium': getAmt('Sodium, Na'),
      'sugar': getAmt('Total Sugars'),
      'addedSugar': getAmt('Sugars, added'),
      'protein': getAmt('Protein'),
      'fiber': getAmt('Fiber, total dietary'),
      'wicEligible': data['eligible'],
      'servingBasis': defaultServingBasis,
    };
  }

  /// Determines which nutritional badges should be displayed for a product.
  ///
  /// A null (unknown) nutrient never qualifies a product for a favorable
  /// badge.
  static List<NutritionalBadge> getBadges(Map<String, dynamic> nutrition) {
    final badges = <NutritionalBadge>[];

    final calories = nutrition['calories'] as num?;
    final totalFat = nutrition['totalFat'] as num?;
    final saturatedFat = nutrition['saturatedFat'] as num?;
    final sodium = nutrition['sodium'] as num?;
    final sugar = nutrition['sugar'] as num?;
    final protein = nutrition['protein'] as num?;

    if (nutrition['wicEligible'] as bool? ?? false) {
      badges.add(NutritionalBadge.wicEligible);
    }

    if (totalFat != null && totalFat <= lowFatThreshold) {
      badges.add(NutritionalBadge.lowFat);
    }

    if (sodium != null && sodium <= lowSodiumThreshold) {
      badges.add(NutritionalBadge.lowSodium);
    }

    if (sugar != null && sugar <= lowSugarThreshold) {
      badges.add(NutritionalBadge.lowSugar);
    }

    if (protein != null && protein >= highProteinThreshold) {
      badges.add(NutritionalBadge.highProtein);
    }

    if (calories != null && calories <= lowCalorieThreshold) {
      badges.add(NutritionalBadge.lowCalorie);
    }

    if (saturatedFat != null &&
        sodium != null &&
        saturatedFat <= heartHealthyMaxSaturatedFat &&
        sodium <= heartHealthyMaxSodium) {
      badges.add(NutritionalBadge.heartHealthy);
    }

    return badges;
  }
}

/// Enum representing different types of nutritional badges.
enum NutritionalBadge {
  lowFat,
  lowSodium,
  lowSugar,
  highProtein,
  lowCalorie,
  heartHealthy,
  wicEligible,
}

/// Extension to provide display properties for nutritional badges.
extension NutritionalBadgeExtension on NutritionalBadge {
  /// Returns the display label for the badge.
  String get label {
    switch (this) {
      case NutritionalBadge.lowFat:
        return 'Low Fat';
      case NutritionalBadge.lowSodium:
        return 'Low Sodium';
      case NutritionalBadge.lowSugar:
        return 'Low Sugar';
      case NutritionalBadge.highProtein:
        return 'High Protein';
      case NutritionalBadge.lowCalorie:
        return 'Low Calorie';
      case NutritionalBadge.heartHealthy:
        return 'Heart Healthy';
      case NutritionalBadge.wicEligible:
        return 'WIC Eligible';
    }
  }

  /// Returns the icon for the badge.
  Object get icon {
    switch (this) {
      case NutritionalBadge.lowFat:
        return Icons.water_drop_outlined;
      case NutritionalBadge.lowSodium:
        return Icons.grain;
      case NutritionalBadge.lowSugar:
        return Icons.do_not_disturb_on_outlined;
      case NutritionalBadge.highProtein:
        return Icons.fitness_center;
      case NutritionalBadge.lowCalorie:
        return Icons.energy_savings_leaf;
      case NutritionalBadge.heartHealthy:
        return Icons.favorite_outline;
      case NutritionalBadge.wicEligible:
        return Image.asset('assets/images/wic-logo.png');
    }
  }

  /// Returns the color for the badge.
  Color get color {
    switch (this) {
      case NutritionalBadge.lowFat:
        return Colors.blue;
      case NutritionalBadge.lowSodium:
        return Colors.orange;
      case NutritionalBadge.lowSugar:
        return Colors.purple;
      case NutritionalBadge.highProtein:
        return Colors.green;
      case NutritionalBadge.lowCalorie:
        return Colors.teal;
      case NutritionalBadge.heartHealthy:
        return Colors.red;
      case NutritionalBadge.wicEligible:
        return Colors.transparent;
    }
  }
}