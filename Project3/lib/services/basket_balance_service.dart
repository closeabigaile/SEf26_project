/// M2: basket-wide balance check and one-swap suggestions.
///
/// Looks at the whole basket (quantities included), finds the nutrient with
/// the largest gap against an illustrative per-serving target, and ranks
/// same-category swaps by how much they close that gap for the basket.
///
/// This is a shopping aid. A basket is not a diet and a purchase is not
/// proof of what is eaten; the targets are FDA label thresholds used as
/// examples, not personal nutrition goals.
library;

/// An illustrative per-serving target for one nutrient.
class BalanceTarget {
  const BalanceTarget({
    required this.key,
    required this.label,
    required this.unit,
    required this.perServing,
    required this.lowerIsBetter,
    required this.basis,
  });

  /// Key in the M1 nutrition map (see [NutritionalUtils]).
  final String key;
  final String label;
  final String unit;
  final double perServing;
  final bool lowerIsBetter;

  /// Where the number comes from, shown next to it in the UI.
  final String basis;
}

/// FDA: 20% DV or more per serving is "high"; 10% DV is a "good source".
/// Sodium DV 2,300 mg, added sugars DV 50 g, fiber DV 28 g.
const demoBalanceTargets = <BalanceTarget>[
  BalanceTarget(
    key: 'sodium',
    label: 'Sodium',
    unit: 'mg',
    perServing: 460,
    lowerIsBetter: true,
    basis: 'FDA: 20% Daily Value (2,300 mg) per serving is high',
  ),
  BalanceTarget(
    key: 'addedSugar',
    label: 'Added sugar',
    unit: 'g',
    perServing: 10,
    lowerIsBetter: true,
    basis: 'FDA: 20% Daily Value (50 g) per serving is high',
  ),
  BalanceTarget(
    key: 'fiber',
    label: 'Fiber',
    unit: 'g',
    perServing: 2.8,
    lowerIsBetter: false,
    basis: 'FDA: 10% Daily Value (28 g) per serving is a good source',
  ),
];

/// The basket's quantity-weighted average for one nutrient.
class NutrientSummary {
  const NutrientSummary({
    required this.target,
    required this.averagePerServing,
    required this.measuredQty,
    required this.totalQty,
  });

  final BalanceTarget target;

  /// Null when no basket item has this nutrient.
  final double? averagePerServing;
  final int measuredQty;
  final int totalQty;

  /// Some basket items have no value for this nutrient.
  bool get incomplete => measuredQty < totalQty;

  /// Too few measured items to rank swaps on this nutrient.
  bool get tooSparse =>
      averagePerServing == null ||
      totalQty == 0 ||
      measuredQty / totalQty < BasketBalanceService.minCoverage;

  /// How far past the target the basket is (0 = on or within target).
  double get gap => averagePerServing == null
      ? 0
      : BasketBalanceService.gapFor(target, averagePerServing!);
}

/// One previewed swap. Applying it is a separate, shopper-confirmed step.
class SwapSuggestion {
  const SwapSuggestion({
    required this.fromUpc,
    required this.fromName,
    required this.category,
    required this.qty,
    required this.toUpc,
    required this.toName,
    required this.toNutrition,
    required this.focus,
    required this.before,
    required this.after,
    required this.improvement,
    required this.tradeoffs,
  });

  final String fromUpc;
  final String fromName;
  final String category;
  final int qty;
  final String toUpc;
  final String toName;
  final Map<String, dynamic> toNutrition;

  /// The nutrient this swap was ranked on.
  final BalanceTarget focus;

  /// Basket averages for [focus] before and after the swap.
  final double before;
  final double after;

  /// Reduction in the basket's [focus] gap.
  final double improvement;

  /// Plain-language notes on nutrients that get worse or become unknown.
  final List<String> tradeoffs;
}

class BasketBalanceReport {
  const BasketBalanceReport({
    required this.summaries,
    required this.suggestions,
    this.focus,
    this.message,
  });

  final List<NutrientSummary> summaries;
  final List<SwapSuggestion> suggestions;

  /// The nutrient with the largest gap, if any.
  final BalanceTarget? focus;

  /// Why there are no suggestions, or other notes for the shopper.
  final String? message;
}

class BasketBalanceService {
  const BasketBalanceService({this.targets = demoBalanceTargets});

  final List<BalanceTarget> targets;

  /// Share of basket items that must have a value before ranking on it.
  static const double minCoverage = 0.5;
  static const int maxSuggestions = 3;
  static const double _epsilon = 1e-9;

  static String canon(Object? raw) => (raw ?? '')
      .toString()
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ')
      .toUpperCase();

  static double gapFor(BalanceTarget target, double average) {
    if (target.lowerIsBetter) {
      return average <= target.perServing
          ? 0
          : (average - target.perServing) / target.perServing;
    }
    return average >= target.perServing
        ? 0
        : (target.perServing - average) / target.perServing;
  }

  static double? _value(Map<String, dynamic>? nutrition, String key) {
    final v = nutrition?[key];
    return v is num && v.isFinite && v >= 0 ? v.toDouble() : null;
  }

  static int _qty(Map<String, dynamic> line) {
    final q = line['qty'];
    return q is int && q > 0 ? q : 0;
  }

  static Map<String, dynamic>? _nutrition(Map<String, dynamic> line) {
    final n = line['nutrition'];
    return n is Map ? Map<String, dynamic>.from(n) : null;
  }

  NutrientSummary _summarize(
    BalanceTarget target,
    List<Map<String, dynamic>> basket, {
    int? swapIndex,
    Map<String, dynamic>? swapNutrition,
  }) {
    var total = 0.0;
    var measured = 0;
    var totalQty = 0;
    for (var i = 0; i < basket.length; i++) {
      final qty = _qty(basket[i]);
      totalQty += qty;
      final nutrition = i == swapIndex ? swapNutrition : _nutrition(basket[i]);
      final value = _value(nutrition, target.key);
      if (value == null) continue;
      total += value * qty;
      measured += qty;
    }
    return NutrientSummary(
      target: target,
      averagePerServing: measured == 0 ? null : total / measured,
      measuredQty: measured,
      totalQty: totalQty,
    );
  }

  /// The basket's category allowance must agree with its lines before a swap
  /// is offered: used covers every benefit line and does not exceed allowed.
  static bool _balanceConsistent(
    String category,
    List<Map<String, dynamic>> basket,
    Map<String, Map<String, dynamic>> balances,
  ) {
    final balance = balances[category];
    if (balance == null) return false;
    final used = balance['used'];
    final allowed = balance['allowed'];
    var allocated = 0;
    for (final line in basket) {
      if (canon(line['category']) != category) continue;
      final qty = _qty(line);
      if (qty == 0) return false;
      allocated += qty;
    }
    return used is int &&
        used >= allocated &&
        (allowed == null || (allowed is int && used <= allowed));
  }

  /// Analyzes [basket] and previews up to [maxSuggestions] swaps.
  ///
  /// [candidatesByCategory] maps a canonical category to eligible products
  /// shaped `{upc, name, category, eligible, nutrition}`. Nothing is mutated.
  BasketBalanceReport analyze({
    required List<Map<String, dynamic>> basket,
    required Map<String, Map<String, dynamic>> balances,
    required Map<String, List<Map<String, dynamic>>> candidatesByCategory,
  }) {
    final summaries = [for (final t in targets) _summarize(t, basket)];
    if (basket.isEmpty || summaries.first.totalQty == 0) {
      return BasketBalanceReport(
        summaries: summaries,
        suggestions: const [],
        message: 'Add items to your basket to check its balance.',
      );
    }

    final rankable = summaries.where((s) => !s.tooSparse).toList();
    if (rankable.isEmpty) {
      return BasketBalanceReport(
        summaries: summaries,
        suggestions: const [],
        message:
            'Not enough nutrition information in this basket to compare. '
            'At least half of the items need values.',
      );
    }

    // Largest gap wins; ties fall back to target order.
    NutrientSummary? focusSummary;
    for (final s in rankable) {
      if (s.gap > _epsilon &&
          (focusSummary == null || s.gap > focusSummary.gap)) {
        focusSummary = s;
      }
    }
    if (focusSummary == null) {
      return BasketBalanceReport(
        summaries: summaries,
        suggestions: const [],
        message: 'Your basket is within the example per-serving targets.',
      );
    }
    final focus = focusSummary.target;

    final suggestions = <SwapSuggestion>[];
    var skippedForBalance = false;
    for (var i = 0; i < basket.length; i++) {
      final line = basket[i];
      final category = canon(line['category']);
      final fromUpc = (line['upc'] ?? '').toString();
      final qty = _qty(line);
      final fromNutrition = _nutrition(line);
      if (category.isEmpty ||
          category == 'PAID' ||
          qty == 0 ||
          _value(fromNutrition, focus.key) == null) {
        continue;
      }
      if (!_balanceConsistent(category, basket, balances)) {
        skippedForBalance = true;
        continue;
      }

      SwapSuggestion? best;
      for (final candidate in candidatesByCategory[category] ?? const []) {
        final toUpc = (candidate['upc'] ?? '').toString();
        final toNutrition = candidate['nutrition'] is Map
            ? Map<String, dynamic>.from(candidate['nutrition'] as Map)
            : null;
        // Hard constraints exclude a candidate rather than lowering its rank.
        if (toUpc.isEmpty ||
            toUpc == fromUpc ||
            candidate['eligible'] != true ||
            canon(candidate['category']) != category ||
            _value(toNutrition, focus.key) == null) {
          continue;
        }

        final after = _summarize(
          focus,
          basket,
          swapIndex: i,
          swapNutrition: toNutrition,
        );
        final improvement = focusSummary.gap - after.gap;
        if (improvement <= _epsilon) continue;

        final tradeoffs = <String>[];
        for (final other in summaries) {
          if (identical(other.target, focus)) continue;
          final t = other.target;
          if (_value(fromNutrition, t.key) != null &&
              _value(toNutrition, t.key) == null) {
            tradeoffs.add('${t.label} is unknown for ${candidate['name']}.');
            continue;
          }
          final otherAfter = _summarize(
            t,
            basket,
            swapIndex: i,
            swapNutrition: toNutrition,
          );
          if (other.averagePerServing != null &&
              otherAfter.averagePerServing != null &&
              otherAfter.gap > other.gap + _epsilon) {
            tradeoffs.add(
              '${t.label} average ${t.lowerIsBetter ? 'rises' : 'falls'}: '
              '${formatAmount(other.averagePerServing!, t.unit)} → '
              '${formatAmount(otherAfter.averagePerServing!, t.unit)} per serving.',
            );
          }
        }

        final suggestion = SwapSuggestion(
          fromUpc: fromUpc,
          fromName: (line['name'] ?? '').toString(),
          category: category,
          qty: qty,
          toUpc: toUpc,
          toName: (candidate['name'] ?? '').toString(),
          toNutrition: toNutrition!,
          focus: focus,
          before: focusSummary.averagePerServing!,
          after: after.averagePerServing!,
          improvement: improvement,
          tradeoffs: tradeoffs,
        );
        if (best == null ||
            improvement > best.improvement + _epsilon ||
            ((improvement - best.improvement).abs() <= _epsilon &&
                toUpc.compareTo(best.toUpc) < 0)) {
          best = suggestion;
        }
      }
      if (best != null) suggestions.add(best);
    }

    suggestions.sort((a, b) {
      final byImprovement = b.improvement.compareTo(a.improvement);
      if ((a.improvement - b.improvement).abs() > _epsilon) {
        return byImprovement;
      }
      final byFrom = a.fromUpc.compareTo(b.fromUpc);
      return byFrom != 0 ? byFrom : a.toUpc.compareTo(b.toUpc);
    });

    String? message;
    if (suggestions.isEmpty) {
      message = skippedForBalance
          ? 'Your saved allowance does not match the basket, so no swap is '
                'suggested. Check your balance first.'
          : 'No same-category swap lowers the basket\'s '
                '${focus.label.toLowerCase()} gap with the data available.';
    }
    return BasketBalanceReport(
      summaries: summaries,
      suggestions: suggestions.take(maxSuggestions).toList(),
      focus: focus,
      message: message,
    );
  }

  static String formatAmount(double value, String unit) {
    final rounded = value >= 100
        ? value.round().toString()
        : value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
    return '$rounded $unit';
  }
}
