/// Ranking modes for the offline meal-suggestion prototype.
///
/// Privacy mode requires no personal target and ignores purchase history.
/// Other modes apply the gates described by [NutritionRecommender.recommend].
enum NutritionMode { balanced, bodybuilding, fatLoss, moneySaving, privacy }

/// Life-stage labels used to match supplied targets and gate recommendation modes.
enum LifeStage { adult, child, pregnant, breastfeeding, infant, unknown }

/// A source title, URL, and claim attached to a recommendation rationale.
class NutritionEvidence {
  /// Records a source and the claim it supports; URLs are not fetched or validated.
  const NutritionEvidence(this.title, this.url, this.claim);

  /// Human-readable title of the evidence source.
  final String title;

  /// Source URL included in CLI output for the reader to inspect.
  final String url;

  /// Limited claim associated with the source, not proof of a recommendation.
  final String claim;
}

/// Evidence registry keyed by the claim IDs returned in meal and history results.
const nutritionEvidence = <String, NutritionEvidence>{
  'balanced_pattern': NutritionEvidence(
    'WHO: Healthy diet',
    'https://www.who.int/news-room/fact-sheets/detail/healthy-diet',
    'Food-group variety is one part of a healthy dietary pattern.',
  ),
  'protein_training': NutritionEvidence(
    'NIH ODS: Exercise and athletic performance',
    'https://ods.od.nih.gov/factsheets/ExerciseAndAthleticPerformance-HealthProfessional/',
    'Adequate protein supports adaptation to resistance training.',
  ),
  'adult_weight_plan': NutritionEvidence(
    'NIH: Body Weight Planner',
    'https://www.niddk.nih.gov/health-information/weight-management/body-weight-planner',
    'Personal calorie plans for weight goals apply to adults who are not pregnant or breastfeeding.',
  ),
  'sodium': NutritionEvidence(
    'WHO: Sodium and cardiovascular disease',
    'https://www.who.int/tools/elena/interventions/sodium-cvd-adults',
    'Lower sodium intake can support healthier blood pressure in adults.',
  ),
  'label_high': NutritionEvidence(
    'FDA: Percent Daily Value',
    'https://www.fda.gov/food/nutrition-facts-label/lows-and-highs-percent-daily-value-nutrition-facts-label',
    'A serving with at least 20% of the Daily Value is considered high in that nutrient.',
  ),
  'sodium_daily_value': NutritionEvidence(
    'FDA: Sodium in your diet',
    'https://www.fda.gov/food/nutrition-education-resources-materials/sodium-your-diet',
    'The Daily Value for sodium is 2,300 mg for adults and children age four and older.',
  ),
  'serving_basis': NutritionEvidence(
    'FDA: Serving size on the Nutrition Facts label',
    'https://www.fda.gov/food/nutrition-facts-label/serving-size-nutrition-facts-label',
    'Label nutrient amounts describe the stated serving, not necessarily the whole package.',
  ),
};

/// A catalog product with nutrient amounts for its stated portion.
///
/// Missing amounts remain null. Construction alone does not validate the data;
/// [hasComparableNutrition] checks presence and [NutritionRecommender.recommend]
/// applies additional filters. This model belongs to the offline meal prototype.
class NutritionProduct {
  /// Stores product data and provenance without inventing missing nutrient values.
  const NutritionProduct({
    required this.upc,
    required this.name,
    required this.foodGroup,
    required this.category,
    required this.eligible,
    required this.servingGrams,
    required this.calories,
    required this.proteinGrams,
    required this.fiberGrams,
    required this.sodiumMg,
    required this.saturatedFatGrams,
    required this.addedSugarGrams,
    required this.sourceUrl,
    this.pricePerServing,
    this.priceObservedAt,
    this.priceSourceUrl,
    this.priceMappingNote,
    this.addedSugarSourceUrl,
    this.portionBasis,
    this.labelBased = false,
    this.mealCandidate = true,
    this.candidateNote,
    this.mealStyle = 'neutral',
  });

  /// Product identifier used for catalog matching, exclusions, and deterministic ties.
  final String upc;

  /// Product name shown in suggested meals.
  final String name;

  /// Meal role: `vegetable`, `fruit`, `protein`, or `grain` for current assembly rules.
  final String foodGroup;

  /// Catalog category label; this is not a participant benefit allocation.
  final String category;

  /// Whether the supplied catalog marks the product eligible for consideration.
  final bool eligible;

  /// Grams in the stated portion, or null when unknown.
  final double? servingGrams;

  /// Energy in kilocalories for the stated portion, or null when unknown.
  final double? calories;

  /// Grams of protein in the stated portion, or null when unknown.
  final double? proteinGrams;

  /// Grams of fiber in the stated portion, or null when unknown.
  final double? fiberGrams;

  /// Milligrams of sodium in the stated portion, or null when unknown.
  final double? sodiumMg;

  /// Grams of saturated fat in the stated portion, or null when unknown.
  final double? saturatedFatGrams;

  /// Grams of added sugar in the stated portion, or null when unknown.
  final double? addedSugarGrams;

  /// Price for the stated portion; must use the same currency as the meal budget.
  final double? pricePerServing;

  /// Observation date used to reject future prices and prices older than 30 days.
  final DateTime? priceObservedAt;

  /// Price provenance; budget-mode candidates require an HTTPS URL.
  final String? priceSourceUrl;

  /// Explanation of how the observed price was mapped to this portion.
  final String? priceMappingNote;

  /// Source of the product nutrition; a nonempty value is required for comparison.
  final String sourceUrl;

  /// Separate source for added sugar when the main record does not provide it.
  final String? addedSugarSourceUrl;

  /// Description of the portion represented by the nutrient values.
  final String? portionBasis;

  /// Whether amounts are identified as label-based for label-specific rationales.
  final bool labelBased;

  /// Whether this product is enabled for meal assembly in the prototype catalog.
  final bool mealCandidate;

  /// Catalog review note explaining inclusion or exclusion as a meal candidate.
  final String? candidateNote;

  /// Compatibility label; current rules reject savory protein with a sweet grain.
  final String mealStyle;

  /// Returns a copy with portion mass, nutrients, and known price scaled by [servings].
  ///
  /// All nutrient fields and [servingGrams] must be non-null; otherwise the null
  /// assertions throw. The caller must supply an appropriate positive factor.
  /// Identity and provenance are retained, and the original product is unchanged.
  NutritionProduct scaledBy(double servings) => NutritionProduct(
    upc: upc,
    name: name,
    foodGroup: foodGroup,
    category: category,
    eligible: eligible,
    servingGrams: servingGrams! * servings,
    calories: calories! * servings,
    proteinGrams: proteinGrams! * servings,
    fiberGrams: fiberGrams! * servings,
    sodiumMg: sodiumMg! * servings,
    saturatedFatGrams: saturatedFatGrams! * servings,
    addedSugarGrams: addedSugarGrams! * servings,
    sourceUrl: sourceUrl,
    pricePerServing: pricePerServing == null
        ? null
        : pricePerServing! * servings,
    priceObservedAt: priceObservedAt,
    priceSourceUrl: priceSourceUrl,
    priceMappingNote: priceMappingNote,
    addedSugarSourceUrl: addedSugarSourceUrl,
    portionBasis: portionBasis,
    labelBased: labelBased,
    mealCandidate: mealCandidate,
    candidateNote: candidateNote,
    mealStyle: mealStyle,
  );

  /// Whether identity, source, positive portion mass, and all nutrient values exist.
  ///
  /// This presence check does not establish source accuracy or validate every
  /// nutrient value; recommendation filtering performs further checks.
  bool get hasComparableNutrition =>
      servingGrams != null &&
      servingGrams! > 0 &&
      calories != null &&
      proteinGrams != null &&
      fiberGrams != null &&
      sodiumMg != null &&
      saturatedFatGrams != null &&
      addedSugarGrams != null &&
      sourceUrl.isNotEmpty &&
      upc.isNotEmpty &&
      name.isNotEmpty;

  /// Parses a JSON/CSV-style [row] without replacing missing amounts with zero.
  ///
  /// Numeric fields accept numbers or parseable numeric strings. Invalid numeric
  /// strings and dates become null; absent identity fields become empty strings.
  /// Boolean flags accept the corresponding boolean or lowercase text value.
  /// Parsing does not establish suitability for recommendation.
  factory NutritionProduct.fromMap(Map<String, dynamic> row) {
    double? amount(String key) {
      final value = row[key];
      if (value is num) return value.toDouble();
      if (value is String && value.trim().isNotEmpty) {
        return double.tryParse(value.trim());
      }
      return null;
    }

    return NutritionProduct(
      upc: row['upc']?.toString() ?? '',
      name: row['name']?.toString() ?? '',
      foodGroup: row['foodGroup']?.toString() ?? '',
      category: row['category']?.toString() ?? '',
      eligible: row['eligible'] == true || row['eligible'] == 'true',
      servingGrams: amount('servingGrams'),
      calories: amount('calories'),
      proteinGrams: amount('proteinGrams'),
      fiberGrams: amount('fiberGrams'),
      sodiumMg: amount('sodiumMg'),
      saturatedFatGrams: amount('saturatedFatGrams'),
      addedSugarGrams: amount('addedSugarGrams'),
      pricePerServing: amount('pricePerServing'),
      priceObservedAt: DateTime.tryParse(
        row['priceObservedAt']?.toString() ?? '',
      ),
      priceSourceUrl: row['priceSourceUrl']?.toString(),
      priceMappingNote: row['priceMappingNote']?.toString(),
      sourceUrl: row['sourceUrl']?.toString() ?? '',
      addedSugarSourceUrl: row['addedSugarSourceUrl']?.toString(),
      portionBasis: row['portionBasis']?.toString(),
      labelBased: row['labelBased'] == true || row['labelBased'] == 'true',
      mealCandidate:
          row['mealCandidate'] != false && row['mealCandidate'] != 'false',
      candidateNote: row['candidateNote']?.toString(),
      mealStyle: row['mealStyle']?.toString() ?? 'neutral',
    );
  }
}

/// Targets are supplied by a life-stage reference or a qualified professional.
/// The source URL is required so a number is never presented without origin.
class NutritionTargets {
  /// Stores caller-supplied daily targets; the recommender checks applicability.
  const NutritionTargets({
    required this.sourceUrl,
    required this.lifeStage,
    this.caloriesPerDay,
    this.proteinGramsPerDay,
    this.sodiumMgMaxPerDay,
  });

  /// Source URL identifying the origin of the supplied daily targets.
  final String sourceUrl;

  /// Life stage to which these targets apply.
  final LifeStage lifeStage;

  /// Daily energy target in kilocalories, or null if not supplied.
  final double? caloriesPerDay;

  /// Daily protein target in grams, or null if not supplied.
  final double? proteinGramsPerDay;

  /// Daily sodium maximum in milligrams, or null if not supplied.
  final double? sodiumMgMaxPerDay;
}

/// Caller-supplied preferences and constraints for one offline recommendation.
///
/// Flags describe supplied inputs; this object does not authenticate clinical
/// review, derive personal targets, or query official benefits.
class NutritionContext {
  /// Creates a request context with optional history use disabled by default.
  const NutritionContext({
    required this.mode,
    required this.lifeStage,
    this.targets,
    this.budgetPerMeal,
    this.mealsPerDay = 3,
    this.training = false,
    this.clinicianWeightPlan = false,
    this.useHistory = false,
    this.excludedUpcs = const {},
  });

  /// Ranking mode and associated eligibility gates for this request.
  final NutritionMode mode;

  /// Life stage used to check the supplied targets and mode restrictions.
  final LifeStage lifeStage;

  /// Daily reference targets; required outside privacy mode.
  final NutritionTargets? targets;

  /// Maximum meal price in the catalog currency; required in money-saving mode.
  final double? budgetPerMeal;

  /// Positive divisor for converting daily targets into illustrative meal targets.
  final int mealsPerDay;

  /// Whether the request supplies the training flag required by bodybuilding mode.
  final bool training;

  /// Caller assertion of a clinician plan used by non-adult weight/training gates.
  final bool clinicianWeightPlan;

  /// Whether adult, non-privacy requests may examine supplied purchase history.
  final bool useHistory;

  /// Product identifiers to omit; this does not implement complete allergy screening.
  final Set<String> excludedUpcs;
}

/// A dated list of purchased products supplied to the optional history review.
///
/// A purchase record is not evidence of consumption. This model performs no storage.
class PurchaseRecord {
  /// Stores a checkout date and its supplied product records.
  const PurchaseRecord(this.date, this.products);

  /// Purchase date used by the inclusive 90-day history window.
  final DateTime date;

  /// Products recorded for this purchase; quantities are represented by the input list.
  final List<NutritionProduct> products;
}

/// A ranked combination of produce, protein, and grain portions.
///
/// Instances created by the recommender contain measured nutrient values.
/// The scoring weights are prototype heuristics, not clinical validation.
class MealSuggestion {
  /// Stores selected portions, ranking score, evidence IDs, and any proposed replacement.
  const MealSuggestion(
    this.products,
    this.score,
    this.claimIds,
    this.replacedBasketUpcs,
  );

  /// Products with portion-scaled nutrient amounts for this meal.
  final List<NutritionProduct> products;

  /// Prototype ranking score; higher values sort first within a request.
  final double score;

  /// Keys into [nutritionEvidence] for the meal rationale.
  final List<String> claimIds;

  /// Basket product IDs proposed for replacement; the suggestion does not mutate a basket.
  final List<String> replacedBasketUpcs;

  /// Total kilocalories across portions; requires non-null product energy values.
  double get calories => products.fold(0, (sum, p) => sum + p.calories!);

  /// Total protein in grams; requires non-null product protein values.
  double get proteinGrams =>
      products.fold(0, (sum, p) => sum + p.proteinGrams!);

  /// Total sodium in milligrams; requires non-null product sodium values.
  double get sodiumMg => products.fold(0, (sum, p) => sum + p.sodiumMg!);

  /// Sum of portion prices, treating unknown prices as zero for this calculation.
  ///
  /// Check that every price is known before presenting this as a complete meal
  /// cost. The CLI suppresses it when any price is unknown.
  double get pricePerServing =>
      products.fold(0, (sum, p) => sum + (p.pricePerServing ?? 0));
}

/// Meal ideas, optional history notices, and a reason when suggestions are blocked.
class NutritionResult {
  /// Collects a recommendation outcome without changing catalog or basket data.
  const NutritionResult(this.meals, this.historyMessages, this.blockedReason);

  /// Up to three suggestions, ordered by score and then product identifiers.
  final List<MealSuggestion> meals;

  /// Notices from eligible, opted-in purchase-history review; otherwise empty.
  final List<HistoryNotice> historyMessages;

  /// Explanation when request validation or candidate filtering yields no meals.
  final String? blockedReason;
}

/// A purchase-history observation with supporting evidence identifiers.
class HistoryNotice {
  /// Pairs a human-readable observation with source-registry keys.
  const HistoryNotice(this.message, this.claimIds);

  /// Observation about recorded purchases, not a diagnosis or consumption estimate.
  final String message;

  /// Keys into [nutritionEvidence] supporting the observation.
  final List<String> claimIds;
}

/// Offline meal-prototype engine using supplied catalog, target, and history data.
///
/// This is separate from the app's basket-balance swap service. It does not
/// query Firebase, derive clinical targets, verify benefits, or apply swaps.
class NutritionRecommender {
  /// Creates a stateless engine; all inputs are supplied to [recommend].
  const NutritionRecommender();

  /// Builds up to three meal ideas subject to [context] and available catalog data.
  ///
  /// [catalog] supplies product portions and provenance; [basketUpcs] anchors the
  /// meal or identifies a single unsuitable item proposed for replacement.
  /// Unsupported requests and insufficient data return a [NutritionResult] with
  /// a blocked reason. Inputs are not mutated.
  ///
  /// [history] is considered only when opted in, outside privacy mode, for adults.
  /// [now] makes price freshness and history windows reproducible; otherwise
  /// the current time is used. Scores are heuristic and ties use product IDs.
  NutritionResult recommend({
    required List<NutritionProduct> catalog,
    required Set<String> basketUpcs,
    required NutritionContext context,
    List<PurchaseRecord> history = const [],
    DateTime? now,
  }) {
    if (context.mealsPerDay < 1) {
      return const NutritionResult([], [], 'Meals per day must be positive.');
    }
    if (context.mode != NutritionMode.privacy &&
        (context.lifeStage == LifeStage.infant ||
            context.lifeStage == LifeStage.unknown)) {
      return const NutritionResult(
        [],
        [],
        'An applicable life stage is required.',
      );
    }
    final target = context.targets;
    if (target != null &&
        [
          target.caloriesPerDay,
          target.proteinGramsPerDay,
          target.sodiumMgMaxPerDay,
        ].whereType<double>().any((value) => !value.isFinite || value <= 0)) {
      return const NutritionResult(
        [],
        [],
        'Targets must be positive and finite.',
      );
    }
    if (context.mode != NutritionMode.privacy &&
        (context.targets == null || context.targets!.sourceUrl.isEmpty)) {
      return const NutritionResult([], [], 'A sourced target is required.');
    }
    if (context.mode != NutritionMode.privacy &&
        target!.lifeStage != context.lifeStage) {
      return const NutritionResult(
        [],
        [],
        'The target does not match this life stage.',
      );
    }
    if (context.mode == NutritionMode.bodybuilding &&
        (!context.training ||
            context.targets!.proteinGramsPerDay == null ||
            (context.lifeStage != LifeStage.adult &&
                !context.clinicianWeightPlan))) {
      return const NutritionResult(
        [],
        [],
        'Training and a protein target are required.',
      );
    }
    if (context.mode == NutritionMode.fatLoss &&
        (context.targets!.caloriesPerDay == null ||
            (context.lifeStage != LifeStage.adult &&
                !context.clinicianWeightPlan))) {
      return const NutritionResult(
        [],
        [],
        'An applicable weight-plan target is required.',
      );
    }
    if (context.mode == NutritionMode.moneySaving &&
        (context.budgetPerMeal == null || context.budgetPerMeal! <= 0)) {
      return const NutritionResult(
        [],
        [],
        'A positive meal budget is required.',
      );
    }
    if (basketUpcs.isEmpty) {
      return const NutritionResult(
        [],
        [],
        'Add a basket item to build a meal.',
      );
    }
    if (!catalog.any((p) => basketUpcs.contains(p.upc))) {
      return const NutritionResult(
        [],
        [],
        'Basket item is absent from the catalog.',
      );
    }

    final products = catalog
        .where(
          (p) =>
              p.eligible &&
              p.mealCandidate &&
              !context.excludedUpcs.contains(p.upc) &&
              p.hasComparableNutrition &&
              p.servingGrams! > 0 &&
              p.calories! >= 0 &&
              p.proteinGrams! >= 0 &&
              p.fiberGrams! >= 0 &&
              p.sodiumMg! >= 0 &&
              p.saturatedFatGrams! >= 0 &&
              p.addedSugarGrams! >= 0,
        )
        .toList();
    final usableBasket = products.any((p) => basketUpcs.contains(p.upc));
    if (!usableBasket && basketUpcs.length != 1) {
      return const NutritionResult(
        [],
        [],
        'Only one unsuitable basket item can be swapped at a time.',
      );
    }
    final vegetables = products
        .where((p) => p.foodGroup == 'vegetable' || p.foodGroup == 'fruit')
        .toList();
    final proteins = products.where((p) => p.foodGroup == 'protein').toList();
    final grains = products.where((p) => p.foodGroup == 'grain').toList();
    final suggestions = <MealSuggestion>[];

    for (final vegetable in vegetables) {
      for (final protein in proteins) {
        for (final grain in grains) {
          for (final proteinFactor
              in context.mode == NutritionMode.bodybuilding
                  ? const [1.0, 1.5, 2.0]
                  : const [1.0]) {
            for (final grainFactor
                in context.mode == NutritionMode.bodybuilding
                    ? const [1.0, 1.5]
                    : const [1.0]) {
              for (final produceFactor
                  in context.mode == NutritionMode.bodybuilding
                      ? const [1.0, 1.5]
                      : const [1.0]) {
                final meal = [
                  vegetable.scaledBy(produceFactor),
                  protein.scaledBy(proteinFactor),
                  grain.scaledBy(grainFactor),
                ];
                if (protein.mealStyle == 'savory' &&
                    grain.mealStyle == 'sweet') {
                  continue;
                }
                if (usableBasket &&
                    !meal.any((p) => basketUpcs.contains(p.upc))) {
                  continue;
                }
                if (protein.proteinGrams! < 10) {
                  continue;
                }
                if (context.mode == NutritionMode.moneySaving &&
                    (meal.any(
                          (p) =>
                              p.pricePerServing == null ||
                              p.pricePerServing! < 0 ||
                              p.priceSourceUrl == null ||
                              !p.priceSourceUrl!.startsWith('https://') ||
                              p.priceObservedAt == null ||
                              p.priceObservedAt!.isAfter(
                                now ?? DateTime.now(),
                              ) ||
                              p.priceObservedAt!.isBefore(
                                (now ?? DateTime.now()).subtract(
                                  const Duration(days: 30),
                                ),
                              ),
                        ) ||
                        meal.fold<double>(
                              0,
                              (sum, p) => sum + p.pricePerServing!,
                            ) >
                            context.budgetPerMeal!)) {
                  continue;
                }

                final claims = <String>['balanced_pattern'];
                if (meal.every((p) => p.labelBased)) {
                  claims.add('serving_basis');
                }
                var score = meal.fold<double>(
                  0,
                  (sum, p) =>
                      sum +
                      p.fiberGrams! * 2 -
                      p.sodiumMg! / 300 -
                      p.saturatedFatGrams! -
                      p.addedSugarGrams! / 2,
                );
                final calories = meal.fold<double>(
                  0,
                  (sum, p) => sum + p.calories!,
                );
                final proteinGrams = meal.fold<double>(
                  0,
                  (sum, p) => sum + p.proteinGrams!,
                );
                final sodiumMg = meal.fold<double>(
                  0,
                  (sum, p) => sum + p.sodiumMg!,
                );
                if (context.mode == NutritionMode.privacy && sodiumMg > 800) {
                  continue;
                }
                if (target?.sodiumMgMaxPerDay != null &&
                    sodiumMg >
                        target!.sodiumMgMaxPerDay! /
                            context.mealsPerDay *
                            1.25) {
                  continue;
                }
                if (context.mode == NutritionMode.fatLoss) {
                  final perMealCalories =
                      target!.caloriesPerDay! / context.mealsPerDay;
                  if (calories > perMealCalories * 1.2 || proteinGrams < 20) {
                    continue;
                  }
                }
                if (context.mode == NutritionMode.bodybuilding) {
                  final proteinFloor =
                      target!.proteinGramsPerDay! / context.mealsPerDay * 0.8;
                  if (proteinGrams < proteinFloor ||
                      (target.caloriesPerDay != null &&
                          calories <
                              target.caloriesPerDay! /
                                  context.mealsPerDay *
                                  0.8)) {
                    continue;
                  }
                }
                if (target?.sodiumMgMaxPerDay != null &&
                    target!.sodiumMgMaxPerDay! > 0) {
                  final mealLimit =
                      target.sodiumMgMaxPerDay! / context.mealsPerDay;
                  score -=
                      (meal.fold<double>(0, (sum, p) => sum + p.sodiumMg!) /
                          mealLimit) *
                      5;
                }
                switch (context.mode) {
                  case NutritionMode.bodybuilding:
                    if (context.lifeStage == LifeStage.adult) {
                      claims.add('protein_training');
                    }
                    final perMeal =
                        target!.proteinGramsPerDay! / context.mealsPerDay;
                    score -= (proteinGrams - perMeal).abs() / perMeal * 20;
                    if (target.caloriesPerDay != null) {
                      final energyPerMeal =
                          target.caloriesPerDay! / context.mealsPerDay;
                      score -=
                          (calories - energyPerMeal).abs() / energyPerMeal * 40;
                    }
                  case NutritionMode.fatLoss:
                    if (context.lifeStage == LifeStage.adult) {
                      claims.add('adult_weight_plan');
                    }
                    final perMeal =
                        target!.caloriesPerDay! / context.mealsPerDay;
                    score -= (calories - perMeal).abs() / perMeal * 20;
                  case NutritionMode.moneySaving:
                    score -=
                        meal.fold<double>(
                          0,
                          (sum, p) => sum + p.pricePerServing!,
                        ) /
                        context.budgetPerMeal! *
                        20;
                  case NutritionMode.balanced:
                  case NutritionMode.privacy:
                    break;
                }
                suggestions.add(
                  MealSuggestion(
                    meal,
                    score,
                    claims,
                    usableBasket ? const [] : basketUpcs.toList(),
                  ),
                );
              }
            }
          }
        }
      }
    }

    suggestions.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.products
          .map((p) => p.upc)
          .join('|')
          .compareTo(b.products.map((p) => p.upc).join('|'));
    });
    final messages = <HistoryNotice>[];
    if (context.useHistory &&
        context.mode != NutritionMode.privacy &&
        context.lifeStage == LifeStage.adult) {
      final asOf = now ?? DateTime.now();
      final cutoff = asOf.subtract(const Duration(days: 90));
      final recent = history.where(
        (record) => !record.date.isBefore(cutoff) && !record.date.isAfter(asOf),
      );
      final recordedItems = recent.fold<int>(
        0,
        (sum, record) => sum + record.products.length,
      );
      final measuredItems = recent.fold<int>(
        0,
        (sum, record) =>
            sum +
            record.products
                .where(
                  (p) =>
                      p.sodiumMg != null &&
                      p.sodiumMg!.isFinite &&
                      p.sodiumMg! >= 0,
                )
                .length,
      );
      final highSodiumCheckouts = recent
          .where(
            (record) => record.products.any(
              (p) => p.labelBased && p.sodiumMg != null && p.sodiumMg! >= 460,
            ),
          )
          .length;
      if (recordedItems > 0 &&
          measuredItems / recordedItems >= 0.8 &&
          highSodiumCheckouts >= 2) {
        messages.add(
          HistoryNotice(
            'In $highSodiumCheckouts recorded checkouts in the last 90 days, '
            'at least one purchased item listed 460 mg or more sodium per serving '
            '(20% of the FDA Daily Value). Sodium data covered '
            '$measuredItems of $recordedItems recorded items. '
            'Purchases do not show what was eaten.',
            const ['label_high', 'sodium_daily_value', 'serving_basis'],
          ),
        );
      }
    }
    return NutritionResult(
      suggestions.take(3).toList(),
      messages,
      suggestions.isEmpty
          ? context.mode == NutritionMode.moneySaving
                ? 'No meal has current, comparable prices within budget.'
                : 'No meal matches the available foods, data, and constraints.'
          : null,
    );
  }
}
