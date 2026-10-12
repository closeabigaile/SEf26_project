/// Deterministic meal suggestions. Values are per stated serving, never per
/// package or inferred from a missing nutrient.
enum NutritionMode { balanced, bodybuilding, fatLoss, moneySaving, privacy }

enum LifeStage { adult, child, pregnant, breastfeeding, infant, unknown }

class NutritionEvidence {
  const NutritionEvidence(this.title, this.url, this.claim);

  final String title;
  final String url;
  final String claim;
}

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

class NutritionProduct {
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

  final String upc;
  final String name;
  final String foodGroup;
  final String category;
  final bool eligible;
  final double? servingGrams;
  final double? calories;
  final double? proteinGrams;
  final double? fiberGrams;
  final double? sodiumMg;
  final double? saturatedFatGrams;
  final double? addedSugarGrams;
  final double? pricePerServing;
  final DateTime? priceObservedAt;
  final String? priceSourceUrl;
  final String? priceMappingNote;
  final String sourceUrl;
  final String? addedSugarSourceUrl;
  final String? portionBasis;
  final bool labelBased;
  final bool mealCandidate;
  final String? candidateNote;
  final String mealStyle;

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
  const NutritionTargets({
    required this.sourceUrl,
    required this.lifeStage,
    this.caloriesPerDay,
    this.proteinGramsPerDay,
    this.sodiumMgMaxPerDay,
  });

  final String sourceUrl;
  final LifeStage lifeStage;
  final double? caloriesPerDay;
  final double? proteinGramsPerDay;
  final double? sodiumMgMaxPerDay;
}

class NutritionContext {
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

  final NutritionMode mode;
  final LifeStage lifeStage;
  final NutritionTargets? targets;
  final double? budgetPerMeal;
  final int mealsPerDay;
  final bool training;
  final bool clinicianWeightPlan;
  final bool useHistory;
  final Set<String> excludedUpcs;
}

class PurchaseRecord {
  const PurchaseRecord(this.date, this.products);

  final DateTime date;
  final List<NutritionProduct> products;
}

class MealSuggestion {
  const MealSuggestion(
    this.products,
    this.score,
    this.claimIds,
    this.replacedBasketUpcs,
  );

  final List<NutritionProduct> products;
  final double score;
  final List<String> claimIds;
  final List<String> replacedBasketUpcs;

  double get calories => products.fold(0, (sum, p) => sum + p.calories!);
  double get proteinGrams =>
      products.fold(0, (sum, p) => sum + p.proteinGrams!);
  double get sodiumMg => products.fold(0, (sum, p) => sum + p.sodiumMg!);
  double get pricePerServing =>
      products.fold(0, (sum, p) => sum + (p.pricePerServing ?? 0));
}

class NutritionResult {
  const NutritionResult(this.meals, this.historyMessages, this.blockedReason);

  final List<MealSuggestion> meals;
  final List<HistoryNotice> historyMessages;
  final String? blockedReason;
}

class HistoryNotice {
  const HistoryNotice(this.message, this.claimIds);

  final String message;
  final List<String> claimIds;
}

class NutritionRecommender {
  const NutritionRecommender();

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
