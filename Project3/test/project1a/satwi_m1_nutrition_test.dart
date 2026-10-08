import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wolfbite/utils/nutritional_utils.dart';
import 'package:wolfbite/widgets/nutritional_badges.dart';

void main() {
  group('M1 - formatting', () {
    test('known value formats with unit', () {
      expect(NutritionalUtils.formatNutrient(120, 'cal'), '120cal');
      expect(NutritionalUtils.formatNutrient(3.5, 'g'), '3.5g');
    });

    test('null value formats as Unknown', () {
      expect(NutritionalUtils.formatNutrient(null, 'mg'), 'Unknown');
    });
  });

  group('M1 - building nutrition from source data', () {
    test('missing nutrients stay null, not zero', () {
      final n = NutritionalUtils.buildNutritionFromFoodNutrients({
        'foodNutrients': [],
      });
      expect(n['sodium'], isNull);
      expect(n['calories'], isNull);
    });

    test('a genuine zero is preserved as zero', () {
      final n = NutritionalUtils.buildNutritionFromFoodNutrients({
        'foodNutrients': [
          {'name': 'Sodium, Na', 'amount': 0},
        ],
      });
      expect(n['sodium'], 0.0);
    });
  });

  group('M1 - unknown values never earn favorable badges', () {
    test('fully unknown nutrition earns no badges', () {
      final badges = NutritionalUtils.getBadges(
        NutritionalUtils.unknownNutrition,
      );
      expect(badges, isEmpty);
    });

    test('unknown sodium does not earn Low Sodium or Heart Healthy', () {
      final badges = NutritionalUtils.getBadges({
        ...NutritionalUtils.unknownNutrition,
        'saturatedFat': 0.5,
      });
      expect(badges.contains(NutritionalBadge.lowSodium), isFalse);
      expect(badges.contains(NutritionalBadge.heartHealthy), isFalse);
    });

    test('known zero sodium still earns Low Sodium', () {
      final badges = NutritionalUtils.getBadges({
        ...NutritionalUtils.unknownNutrition,
        'sodium': 0.0,
      });
      expect(badges.contains(NutritionalBadge.lowSodium), isTrue);
    });

    test('known low values earn expected badges', () {
      final badges = NutritionalUtils.getBadges({
        'calories': 100.0,
        'totalFat': 2.0,
        'saturatedFat': 0.5,
        'sodium': 100.0,
        'sugar': 2.0,
        'protein': 12.0,
      });
      expect(badges.contains(NutritionalBadge.lowFat), isTrue);
      expect(badges.contains(NutritionalBadge.lowSodium), isTrue);
      expect(badges.contains(NutritionalBadge.lowSugar), isTrue);
      expect(badges.contains(NutritionalBadge.highProtein), isTrue);
      expect(badges.contains(NutritionalBadge.lowCalorie), isTrue);
      expect(badges.contains(NutritionalBadge.heartHealthy), isTrue);
    });
  });

  group('M1 - tradeoff wording', () {
    test('lower sodium is reported as better', () {
      final r = NutritionalUtils.compareTradeoff('Sodium', 340, 120, 'mg');
      expect(r, contains('Lower'));
      expect(r, contains('better'));
      expect(r, contains('120mg'));
      expect(r, contains('340mg'));
    });

    test('higher protein is reported as better when higher is better', () {
      final r = NutritionalUtils.compareTradeoff(
        'Protein', 4, 9, 'g',
        lowerIsBetter: false,
      );
      expect(r, contains('Higher'));
      expect(r, contains('better'));
    });

    test('higher sugar is reported as a tradeoff', () {
      final r = NutritionalUtils.compareTradeoff('Sugar', 3, 8, 'g');
      expect(r, contains('Higher'));
      expect(r, contains('tradeoff'));
    });

    test('unknown on either side is reported as unknown', () {
      final r = NutritionalUtils.compareTradeoff('Sugar', null, 5, 'g');
      expect(r, contains('unknown'));
    });
  });

  group('M1 - NutritionFactsPanel', () {
    testWidgets('shows values, units, explanations, and serving basis', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NutritionFactsPanel(
                nutrition: {
                  'calories': 150.0,
                  'totalFat': 8.0,
                  'saturatedFat': 5.0,
                  'sodium': 120.0,
                  'sugar': 12.0,
                  'protein': 8.0,
                  'fiber': null,
                  'servingBasis': 'Serving basis not specified',
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('150cal'), findsOneWidget);
      expect(find.text('120mg'), findsOneWidget);
      expect(find.text('Unknown'), findsOneWidget);
      expect(find.text('Serving basis not specified'), findsOneWidget);
      expect(find.textContaining('Energy this food provides'), findsOneWidget);
    });

    testWidgets('fully unknown nutrition shows Unknown for all 7 rows', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NutritionFactsPanel(
                nutrition: NutritionalUtils.unknownNutrition,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Unknown'), findsNWidgets(7));
    });
  });
}