// End-to-end tests across the Project 2 milestone branches.
//
// Each test drives the real AppState (backed by FakeFirebaseFirestore), the
// real BasketScreen, and the real milestone services together:
// - M0/M4: checkout help (repository, button, dialog)
// - M1: nutrition units, explanations, unknown-value handling
// - M2: nutrition recommender
// - M3: redesigned shopping interface (phone and desktop layouts)
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wolfbite/screens/basket_screen.dart';
import 'package:wolfbite/services/nutrition_recommender.dart';
import 'package:wolfbite/state/app_state.dart';
import 'package:wolfbite/utils/nutritional_utils.dart';

const _uid = 'e2e-shopper';

class _User extends Mock implements User {
  @override
  String get uid => _uid;
}

const _phone = Size(390, 844);
const _desktop = Size(1280, 900);

Map<String, dynamic> _scenario(String id) =>
    (jsonDecode(
              File('assets/mock/checkout_help_scenarios.json')
                  .readAsStringSync(),
            )['scenarios']
            as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((s) => s['scenario_id'] == id);

/// A basket line in the format the M4 repository recognizes.
Map<String, dynamic> _helpLine(String id) {
  final item = _scenario(id)['input']['item'];
  return {
    'upc': item['id'],
    'name': item['name'],
    'qty': item['quantity'],
    'category': item['basket_category'],
    'original_benefit_category': item['original_benefit_category'],
    'checkout_help_source': 'synthetic',
    'checkout_help_scenario_id': id,
  };
}

/// Product lookup payload in the FoodData Central shape the scan screen
/// hands to [NutritionalUtils.buildNutritionFromFoodNutrients].
Map<String, dynamic> _fdcCarrots() => {
  'name': 'Carrots',
  'category': 'VEGETABLE',
  'eligible': true,
  'foodNutrients': [
    {'name': 'Energy', 'amount': 35},
    {'name': 'Total lipid (fat)', 'amount': 0.2},
    {'name': 'Fatty acids, total saturated', 'amount': 0},
    {'name': 'Sodium, Na', 'amount': 50},
    {'name': 'Total Sugars', 'amount': 4},
    {'name': 'Protein', 'amount': 1},
    {'name': 'Fiber, total dietary', 'amount': 3},
  ],
};

List<NutritionProduct> _catalog() {
  final lines = File('test/fixtures/nutrition_catalog.csv').readAsLinesSync();
  final headers = lines.first.split(',');
  return lines.skip(1).map((line) {
    final values = line.split(',');
    return NutritionProduct.fromMap({
      for (var i = 0; i < headers.length; i++) headers[i]: values[i],
    });
  }).toList();
}

/// Maps an M2 catalog product into the nutrition map AppState/M1 display.
Map<String, dynamic> _nutritionOf(NutritionProduct p) => {
  'calories': p.calories,
  'saturatedFat': p.saturatedFatGrams,
  'sodium': p.sodiumMg,
  'addedSugar': p.addedSugarGrams,
  'protein': p.proteinGrams,
  'fiber': p.fiberGrams,
  'totalFat': null,
  'sugar': null,
  'wicEligible': p.eligible,
  'servingBasis': NutritionalUtils.defaultServingBasis,
};

void main() {
  late FakeFirebaseFirestore db;

  setUp(rootBundle.clear);

  /// Signs a shopper in against [db] seeded with [basket]/[balances] and
  /// waits for the real AppState load to finish.
  Future<AppState> signIn({
    List<Map<String, dynamic>> basket = const [],
    Map<String, dynamic> balances = const {},
  }) async {
    await db.collection('users').doc(_uid).set({
      'basket': basket,
      'balances': balances,
      'updatedAt': Timestamp.now(),
    });
    final state = AppState(db: db);
    final loaded = Completer<void>();
    void onChange() {
      if (state.balancesLoaded && !loaded.isCompleted) loaded.complete();
    }

    state.addListener(onChange);
    state.updateUser(_User());
    await loaded.future;
    state.removeListener(onChange);
    return state;
  }

  Future<Map<String, dynamic>> saved() async =>
      (await db.collection('users').doc(_uid).get()).data()!;

  Future<void> pumpBasket(WidgetTester tester, AppState state, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: BasketScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder cardOf(String name) =>
      find.ancestor(of: find.text(name), matching: find.byType(Card)).first;

  Future<void> tapIn(WidgetTester tester, String item, String label) async {
    final target = find.descendant(
      of: cardOf(item),
      matching: find.text(label),
    );
    await tester.ensureVisible(target);
    await tester.pump();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  setUp(() => db = FakeFirebaseFirestore());

  for (final (label, size) in [('phone', _phone), ('desktop', _desktop)]) {
    testWidgets(
      'E2E-1 [$label] scan -> basket (M3) -> nutrition (M1) -> checkout help '
      '(M4) -> checkout persists',
      (tester) async {
        final helpLine = _helpLine('M0-M4-01');
        late AppState state;
        await tester.runAsync(() async {
          state = await signIn(
            basket: [helpLine],
            balances: {
              'CEREAL': {'allowed': 2, 'used': 1},
            },
          );
        });
        addTearDown(state.dispose);

        // Scan path: same calls ScanScreen._addToBasket makes.
        final scanned = _fdcCarrots();
        expect(
          state.addItem(
            upc: 'V1',
            name: scanned['name'],
            category: scanned['category'],
            nutrition: NutritionalUtils.buildNutritionFromFoodNutrients(
              scanned,
            ),
          ),
          isTrue,
        );

        await pumpBasket(tester, state, size);
        expect(tester.takeException(), isNull, reason: 'M3 layout overflow');
        expect(find.text('Carrots'), findsOneWidget);
        expect(find.text('Mock cereal - 24 oz'), findsOneWidget);

        // M1: units + explanations inside M3's nutrition section.
        await tapIn(tester, 'Carrots', 'View nutrition details');
        expect(tester.takeException(), isNull);
        expect(find.text('35cal'), findsOneWidget);
        expect(find.text('50mg'), findsOneWidget);
        expect(
          find.text(NutritionalUtils.nutrientExplanations['sodium']!),
          findsOneWidget,
        );

        // M4: checkout help on the synthetic cereal line, inside M3's card.
        final before = jsonEncode({
          'basket': state.basket,
          'balances': state.balances,
        });
        await tapIn(tester, 'Mock cereal - 24 oz', 'Get checkout help');
        expect(tester.takeException(), isNull);
        final expected = _scenario('M0-M4-01')['expected_help'];
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text(expected['explanation']),
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(
          jsonEncode({'basket': state.basket, 'balances': state.balances}),
          before,
          reason: 'Help must not change basket or balances',
        );

        // Checkout through the real state; Firestore reflects it.
        await tester.runAsync(state.checkout);
        await tester.pumpAndSettle();
        expect(find.text('Carrots'), findsNothing);
        late Map<String, dynamic> doc;
        await tester.runAsync(() async => doc = await saved());
        expect(doc['basket'], isEmpty);
        expect(doc['balances']['VEGETABLE']['used'], 1);
      },
    );
  }

  testWidgets(
    'E2E-2 scanned product with missing nutrients stays Unknown through '
    'basket, badges, Firestore save and reload',
    (tester) async {
      late AppState state;
      await tester.runAsync(() async => state = await signIn());
      addTearDown(state.dispose);

      final scanned = {
        'name': 'Mystery bar',
        'category': 'CEREAL',
        'foodNutrients': [
          {'name': 'Energy', 'amount': 210},
        ],
      };
      state.addItem(
        upc: 'X1',
        name: 'Mystery bar',
        category: 'CEREAL',
        nutrition: NutritionalUtils.buildNutritionFromFoodNutrients(scanned),
      );
      // Let the fire-and-forget persist land.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));

      late AppState reloaded;
      await tester.runAsync(() async {
        reloaded = AppState(db: db);
        final done = Completer<void>();
        reloaded.addListener(() {
          if (reloaded.balancesLoaded && !done.isCompleted) done.complete();
        });
        reloaded.updateUser(_User());
        await done.future;
      });
      addTearDown(reloaded.dispose);

      final nutrition =
          reloaded.basket.single['nutrition'] as Map<String, dynamic>;
      expect(nutrition['calories'], 210);
      expect(nutrition['sodium'], isNull);
      expect(
        NutritionalUtils.getBadges(nutrition),
        isEmpty,
        reason: 'Unknown nutrients must not earn favorable badges',
      );

      await pumpBasket(tester, reloaded, _phone);
      await tapIn(tester, 'Mystery bar', 'View nutrition details');
      expect(tester.takeException(), isNull);
      expect(find.text('210cal'), findsOneWidget);
      expect(find.text('Unknown'), findsNWidgets(6));
    },
  );

  test(
    'E2E-3 basket items saved before M1 (no nutrition map) reload as '
    'Unknown, not zero',
    () async {
      final state = await signIn(
        basket: [
          {'upc': 'OLD1', 'name': 'Legacy item', 'category': 'CEREAL', 'qty': 1},
        ],
        balances: {
          'CEREAL': {'allowed': 2, 'used': 1},
        },
      );
      addTearDown(state.dispose);

      final nutrition = state.basket.single['nutrition'] as Map<String, dynamic>;
      expect(
        nutrition['calories'],
        isNull,
        reason:
            'AppState.loadUserState still fills missing nutrition with 0.0, '
            "bypassing M1's unknownNutrition handling",
      );
      expect(NutritionalUtils.getBadges(nutrition), isEmpty);
    },
  );

  test(
    'E2E-4 M2 recommender works from the real basket and leaves it intact',
    () async {
      final catalog = _catalog();
      final state = await signIn();
      addTearDown(state.dispose);

      final carrots = catalog.singleWhere((p) => p.upc == 'V1');
      state.addItem(
        upc: carrots.upc,
        name: carrots.name,
        category: carrots.category,
        nutrition: _nutritionOf(carrots),
      );
      final basketBefore = jsonEncode(state.basket);

      final result = const NutritionRecommender().recommend(
        catalog: catalog,
        basketUpcs: {for (final line in state.basket) line['upc'] as String},
        context: const NutritionContext(
          mode: NutritionMode.privacy,
          lifeStage: LifeStage.adult,
        ),
      );

      expect(result.blockedReason, isNull);
      expect(result.meals, isNotEmpty);
      for (final meal in result.meals) {
        expect(meal.products.any((p) => p.upc == 'V1'), isTrue);
        for (final id in meal.claimIds) {
          expect(nutritionEvidence[id]?.url, startsWith('https://'));
        }
      }
      expect(jsonEncode(state.basket), basketBefore);

      // M1 and M2 agree on units for the same product.
      final shown = state.basket.single['nutrition'] as Map<String, dynamic>;
      expect(
        NutritionalUtils.formatNutrient(
          shown['sodium'] as num?,
          NutritionalUtils.nutrientUnits['sodium']!,
        ),
        '${carrots.sodiumMg!.toInt()}mg',
      );
    },
  );

  testWidgets(
    'E2E-5 category cap overflows to PAID and both lines still offer help',
    (tester) async {
      late AppState state;
      await tester.runAsync(() async {
        state = await signIn(
          balances: {
            'CEREAL': {'allowed': 1, 'used': 0},
          },
        );
      });
      addTearDown(state.dispose);

      state.addItem(
        upc: 'C1',
        name: 'Oat cereal',
        category: 'CEREAL',
        nutrition: NutritionalUtils.unknownNutrition,
      );
      state.incrementItem('C1', 'CEREAL');

      expect(state.basket, hasLength(2));
      final paid = state.basket.singleWhere((l) => l['category'] == 'PAID');
      expect(paid['original_benefit_category'], 'CEREAL');
      expect(state.balances['CEREAL']!['used'], 1);

      await pumpBasket(tester, state, _desktop);
      expect(tester.takeException(), isNull);
      expect(find.text('Get checkout help'), findsNWidgets(2));

      // Non-synthetic line: help must not invent a cause.
      final buttons = find.text('Get checkout help');
      await tester.ensureVisible(buttons.last);
      await tester.pump();
      await tester.tap(buttons.last);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Unable to determine the cause'), findsOneWidget);
    },
  );
}
