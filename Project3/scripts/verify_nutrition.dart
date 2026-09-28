import 'dart:io';

import 'package:wolfbite/services/nutrition_recommender.dart';

void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

void main() {
  final lines = File('test/fixtures/nutrition_catalog.csv').readAsLinesSync();
  final headers = lines.first.split(',');
  final catalog = lines.skip(1).map((line) {
    final values = line.split(',');
    check(values.length == headers.length, 'Malformed CSV fixture');
    return NutritionProduct.fromMap({
      for (var i = 0; i < headers.length; i++) headers[i]: values[i],
    });
  }).toList();
  const engine = NutritionRecommender();
  const adultTarget = NutritionTargets(
    sourceUrl: 'https://example.org/test-target',
    lifeStage: LifeStage.adult,
    caloriesPerDay: 1500,
    proteinGramsPerDay: 90,
    sodiumMgMaxPerDay: 2300,
  );
  NutritionResult run(NutritionContext context) => engine.recommend(
    catalog: catalog,
    basketUpcs: {'V1'},
    context: context,
    now: DateTime(2026, 9, 27),
  );

  final privacy = run(
    const NutritionContext(
      mode: NutritionMode.privacy,
      lifeStage: LifeStage.unknown,
    ),
  );
  check(privacy.meals.isNotEmpty, 'Privacy mode should make meal ideas');
  check(
    privacy.meals.every((m) => m.products.every((p) => p.upc != 'G2')),
    'A missing sodium value entered a meal',
  );
  final bodybuilding = run(
    const NutritionContext(
      mode: NutritionMode.bodybuilding,
      lifeStage: LifeStage.adult,
      targets: adultTarget,
      training: true,
    ),
  );
  check(
    bodybuilding.meals.first.claimIds.contains('protein_training'),
    'Training evidence missing',
  );
  final fatLossChild = run(
    const NutritionContext(
      mode: NutritionMode.fatLoss,
      lifeStage: LifeStage.child,
      targets: adultTarget,
    ),
  );
  check(fatLossChild.meals.isEmpty, 'Adult target applied to a child');
  final budget = run(
    const NutritionContext(
      mode: NutritionMode.moneySaving,
      lifeStage: LifeStage.adult,
      targets: adultTarget,
      budgetPerMeal: 2,
    ),
  );
  check(
    budget.meals.isNotEmpty &&
        budget.meals.every((m) => m.pricePerServing <= 2),
    'Budget mode violated price constraint',
  );
  final oldPrice = engine.recommend(
    catalog: catalog,
    basketUpcs: {'V1'},
    context: const NutritionContext(
      mode: NutritionMode.moneySaving,
      lifeStage: LifeStage.adult,
      targets: adultTarget,
      budgetPerMeal: 2,
    ),
    now: DateTime(2027, 1, 1),
  );
  check(oldPrice.meals.isEmpty, 'Stale prices entered budget mode');
  final history = [
    PurchaseRecord(DateTime(2026, 9, 1), [catalog[1]]),
    PurchaseRecord(DateTime(2026, 9, 2), [catalog[1]]),
  ];
  NutritionResult withHistory(bool enabled) => engine.recommend(
    catalog: catalog,
    basketUpcs: {'V1'},
    context: NutritionContext(
      mode: NutritionMode.balanced,
      lifeStage: LifeStage.adult,
      targets: adultTarget,
      useHistory: enabled,
    ),
    history: history,
    now: DateTime(2026, 9, 27),
  );
  check(
    withHistory(false).historyMessages.isEmpty,
    'History was used without opt-in',
  );
  check(
    withHistory(true).historyMessages.length == 1,
    'Repeated purchase pattern was missed',
  );
  for (final meal in [...privacy.meals, ...bodybuilding.meals]) {
    for (final claimId in meal.claimIds) {
      check(
        nutritionEvidence[claimId]?.url.startsWith('https://') == true,
        'Claim $claimId lacks a citation',
      );
    }
  }
  stdout.writeln('CSV nutrition checks passed.');
}
