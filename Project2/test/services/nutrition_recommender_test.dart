import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wolfbite/services/nutrition_recommender.dart';

void main() {
  late List<NutritionProduct> catalog;
  const engine = NutritionRecommender();
  const targets = NutritionTargets(
    sourceUrl: 'https://example.org/test-target',
    lifeStage: LifeStage.adult,
    caloriesPerDay: 1500,
    proteinGramsPerDay: 90,
    sodiumMgMaxPerDay: 2300,
  );

  setUpAll(() {
    final lines = File('test/fixtures/nutrition_catalog.csv').readAsLinesSync();
    final headers = lines.first.split(',');
    catalog = lines.skip(1).map((line) {
      final values = line.split(',');
      return NutritionProduct.fromMap({
        for (var i = 0; i < headers.length; i++) headers[i]: values[i],
      });
    }).toList();
  });

  test('CSV products with missing nutrients cannot enter meal comparisons', () {
    final result = engine.recommend(
      catalog: catalog,
      basketUpcs: {'V1'},
      context: const NutritionContext(
        mode: NutritionMode.privacy,
        lifeStage: LifeStage.adult,
      ),
    );
    expect(result.blockedReason, isNull);
    expect(result.meals, isNotEmpty);
    expect(
      result.meals.every(
        (meal) =>
            meal.products.any((p) => p.upc == 'V1') &&
            meal.products.every((p) => p.upc != 'G2'),
      ),
      isTrue,
    );
    expect(result.meals.first.calories, greaterThan(0));
    for (final meal in result.meals) {
      for (final claimId in meal.claimIds) {
        expect(nutritionEvidence[claimId]?.url.startsWith('https://'), isTrue);
      }
    }
  });

  test('bodybuilding requires training and a sourced protein target', () {
    final blocked = engine.recommend(
      catalog: catalog,
      basketUpcs: {'V1'},
      context: const NutritionContext(
        mode: NutritionMode.bodybuilding,
        lifeStage: LifeStage.adult,
        targets: targets,
      ),
    );
    expect(blocked.meals, isEmpty);
    final result = engine.recommend(
      catalog: catalog,
      basketUpcs: {'V1'},
      context: const NutritionContext(
        mode: NutritionMode.bodybuilding,
        lifeStage: LifeStage.adult,
        targets: targets,
        training: true,
      ),
    );
    expect(result.meals.first.claimIds, contains('protein_training'));
    expect(result.meals.first.proteinGrams, greaterThanOrEqualTo(24));
    expect(result.meals.first.calories, greaterThanOrEqualTo(400));
  });

  test('fat-loss target is restricted by life stage', () {
    for (final stage in [
      LifeStage.child,
      LifeStage.pregnant,
      LifeStage.breastfeeding,
    ]) {
      final blocked = engine.recommend(
        catalog: catalog,
        basketUpcs: {'V1'},
        context: NutritionContext(
          mode: NutritionMode.fatLoss,
          lifeStage: stage,
          targets: targets,
        ),
      );
      expect(blocked.meals, isEmpty);
      final clinicianResult = engine.recommend(
        catalog: catalog,
        basketUpcs: {'V1'},
        context: NutritionContext(
          mode: NutritionMode.fatLoss,
          lifeStage: stage,
          targets: NutritionTargets(
            sourceUrl: 'https://example.org/clinician-test-target',
            lifeStage: stage,
            caloriesPerDay: 1500,
          ),
          clinicianWeightPlan: true,
        ),
      );
      expect(clinicianResult.meals, isNotEmpty);
      expect(
        clinicianResult.meals.first.claimIds,
        isNot(contains('adult_weight_plan')),
      );
    }
  });

  test('money-saving requires prices and respects budget', () {
    final result = engine.recommend(
      catalog: catalog,
      basketUpcs: {'V1'},
      context: const NutritionContext(
        mode: NutritionMode.moneySaving,
        lifeStage: LifeStage.adult,
        targets: targets,
        budgetPerMeal: 2,
      ),
      now: DateTime(2026, 9, 27),
    );
    expect(result.meals, isNotEmpty);
    expect(result.meals.every((meal) => meal.pricePerServing <= 2), isTrue);
    expect(
      result.meals.every(
        (meal) => meal.products.every((p) => p.pricePerServing != null),
      ),
      isTrue,
    );
  });

  test('history requires opt-in and two checkouts; privacy never uses it', () {
    final history = [
      PurchaseRecord(DateTime(2026, 9, 1), [catalog[1]]),
      PurchaseRecord(DateTime(2026, 9, 2), [catalog[1]]),
    ];
    NutritionResult run(NutritionMode mode, bool useHistory) =>
        engine.recommend(
          catalog: catalog,
          basketUpcs: {'V1'},
          context: NutritionContext(
            mode: mode,
            lifeStage: LifeStage.adult,
            targets: mode == NutritionMode.privacy ? null : targets,
            useHistory: useHistory,
          ),
          history: history,
          now: DateTime(2026, 9, 27),
        );
    expect(run(NutritionMode.balanced, false).historyMessages, isEmpty);
    expect(run(NutritionMode.privacy, true).historyMessages, isEmpty);
    final notices = run(NutritionMode.balanced, true).historyMessages;
    expect(notices, hasLength(1));
    expect(notices.single.message, contains('Purchases do not show'));
    expect(notices.single.claimIds, contains('label_high'));
  });
}
