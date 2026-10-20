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

import '../utils/wic_categories.dart';

/// An illustrative per-serving target for one nutrient.
class BalanceTarget {
  /// Creates a comparison target; [perServing] must be positive and finite.
  const BalanceTarget({
    required this.key,
    required this.label,
    required this.unit,
    required this.perServing,
    required this.lowerIsBetter,
    required this.basis,
  });

  /// Key in the M1 nutrition map, such as `sodium`, `addedSugar`, or `fiber`.
  final String key;

  /// Nutrient name displayed in summaries and swap explanations.
  final String label;

  /// Unit shared by the target and nutrient values, such as `mg` or `g`.
  final String unit;

  /// Illustrative target per serving; not a personal daily requirement.
  final double perServing;

  /// Whether exceeding the target is unfavorable; otherwise falling below it is.
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
  /// Stores an average over measured quantities and the total quantity considered.
  const NutrientSummary({
    required this.target,
    required this.averagePerServing,
    required this.measuredQty,
    required this.totalQty,
  });

  /// Target and units associated with this nutrient summary.
  final BalanceTarget target;

  /// Null when no basket item has this nutrient.
  final double? averagePerServing;

  /// Sum of positive item quantities with a finite, nonnegative nutrient value.
  final int measuredQty;

  /// Sum of all positive item quantities, including those with unknown nutrition.
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
  /// Records a preview replacing the entire source line while preserving its quantity.
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
    this.source,
  });

  /// Identifier of the basket product proposed for replacement.
  final String fromUpc;

  /// Display name of the source basket product.
  final String fromName;

  /// Canonical benefit category shared by both products.
  final String category;

  /// Number of source-line items replaced by the preview.
  final int qty;

  /// Identifier of the proposed replacement product.
  final String toUpc;

  /// Display name of the proposed replacement product.
  final String toName;

  /// Replacement nutrient map; unknown values remain null.
  final Map<String, dynamic> toNutrition;

  /// The nutrient this swap was ranked on.
  final BalanceTarget focus;

  /// Quantity-weighted basket average for [focus] before the swap.
  final double before;

  /// Quantity-weighted basket average for [focus] after the previewed replacement.
  final double after;

  /// How far the basket's [focus] average moves in the better direction,
  /// as a fraction of the target.
  final double improvement;

  /// Plain-language notes on nutrients that get worse or become unknown.
  final List<String> tradeoffs;

  /// Provenance of [toNutrition] (e.g. Open Food Facts URL), when known.
  final Map<String, dynamic>? source;

  /// Identifies this swap for "Not now" within a session.
  String get key => '$fromUpc>$toUpc';
}

/// Nutrient summaries and optional swap previews for the current basket.
///
/// An empty suggestion list can mean targets are met, data is insufficient,
/// allowances are inconsistent, or no improving candidate exists; see [message].
class BasketBalanceReport {
  /// Collects summaries, ranked previews, and an optional explanation.
  const BasketBalanceReport({
    required this.summaries,
    required this.suggestions,
    this.focus,
    this.message,
  });

  /// One summary for each configured target, in target order.
  final List<NutrientSummary> summaries;

  /// Best preview per eligible source line, ranked and limited by the service.
  final List<SwapSuggestion> suggestions;

  /// The nutrient with the largest gap, if any.
  final BalanceTarget? focus;

  /// Why there are no suggestions, or other notes for the shopper.
  final String? message;
}

/// Pure basket analysis using quantity-weighted nutrient averages and demo targets.
///
/// The largest rankable target gap selects the focus nutrient. Swaps preserve
/// category and quantity, skip PAID lines, and require consistent app allowances.
/// Results are previews; this service performs no database writes or basket edits.
class BasketBalanceService {
  /// Uses [targets], defaulting to the illustrative [demoBalanceTargets].
  ///
  /// Supply a nonempty list with positive, finite per-serving target values.
  const BasketBalanceService({this.targets = demoBalanceTargets});

  /// Ordered comparison targets; order resolves ties for the focus nutrient.
  final List<BalanceTarget> targets;

  /// Minimum fraction of total item quantity with measured values for ranking.
  static const double minCoverage = 0.5;

  /// Maximum number of ranked previews returned by [analyze].
  static const int maxSuggestions = 3;
  static const double _epsilon = 1e-9;

  /// Normalizes a category through [WicCategories.canonical].
  static String canon(Object? raw) => WicCategories.canonical(raw);

  /// Returns the unfavorable distance from [target], divided by its per-serving value.
  ///
  /// Returns zero when [average] meets the target direction. The target value
  /// must be positive and finite; inputs are not validated by this helper.
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
  /// shaped `{upc, name, category, eligible, nutrition}`. Swaps whose
  /// [SwapSuggestion.key] is in [rejected] are not offered again. Nothing is
  /// mutated.
  ///
  /// Basket lines carry `upc`, `name`, `category`, positive integer `qty`, and
  /// an optional `nutrition` map. [balances] maps canonical categories to
  /// integer `used` counts and integer or null `allowed` limits. Missing or
  /// invalid nutrient values do not count as zero. Summaries include PAID
  /// lines, but those lines are not swap candidates.
  ///
  /// Requires nonempty [targets]. The report explains why no suggestions
  /// were produced, including insufficient data or inconsistent allowances.
  BasketBalanceReport analyze({
    required List<Map<String, dynamic>> basket,
    required Map<String, Map<String, dynamic>> balances,
    required Map<String, List<Map<String, dynamic>>> candidatesByCategory,
    Set<String> rejected = const {},
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
            rejected.contains('$fromUpc>$toUpc') ||
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
        // Movement of the basket average in the better direction, relative
        // to the target. Unlike the gap, this keeps ranking a bigger change
        // higher after both options reach the target.
        final change =
            (after.averagePerServing! - focusSummary.averagePerServing!) /
            focus.perServing;
        final improvement = focus.lowerIsBetter ? -change : change;
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
          source: candidate['source'] is Map
              ? Map<String, dynamic>.from(candidate['source'] as Map)
              : null,
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

  /// Formats [value] with [unit] for display.
  ///
  /// Values at least 100 round to an integer; smaller values use up to one
  /// decimal place. This formatting does not affect ranking calculations.
  static String formatAmount(double value, String unit) {
    final rounded = value >= 100
        ? value.round().toString()
        : value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
    return '$rounded $unit';
  }
}
