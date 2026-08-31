import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wolfbite/screens/basket_screen.dart';
import 'package:wolfbite/state/app_state.dart';

import '../mocks/mocks.mocks.dart';

// This file contains tests for UC11 through UC15.
// UC11 is tested at the AppState level rather than through the widget
// because ReceiptScannerScreen hard-codes AplService() internally and makes
// live network calls to api.ocr.space with no constructor injection point,
// so it cannot be exercised offline the way ScanScreen can. This is a
// testability finding, documented in the traceability notes.
// UC12–UC15 are tested through the real BasketScreen widget with a
// MockAppState, matching the pattern used for UC1–UC5.
void main() {
  group('UC11 — Add receipt products (state-level)', () {
    late _SatwiMockStateStore store;
    late MockUser user;
    late AppState state;

    setUp(() async {
      user = MockUser();
      when(user.uid).thenReturn('receipt-user');
      store = _SatwiMockStateStore(null);
      state = AppState(db: store.db);
      state.updateUser(user);
      await _waitForLoaded(state);
    });

    test('test_uc11_multiple_recognized_products_are_each_added', () {
      // ARRANGE/ACT: simulate _addAllToBasket looping addItem for each
      // recognized receipt product.
      final resultA = state.addItem(
        upc: '111',
        name: 'Receipt Milk',
        category: 'MILK',
        nutrition: const {'calories': 150.0},
      );
      final resultB = state.addItem(
        upc: '222',
        name: 'Receipt Bread',
        category: 'BREAD',
        nutrition: const {'calories': 90.0},
      );
      // ASSERT: both distinct products are represented and both report a
      // newly created line, as UC11's main scenario requires.
      expect(resultA, isTrue);
      expect(resultB, isTrue);
      expect(state.basket, hasLength(2));
      expect(state.balances['MILK']?['used'], 1);
      expect(state.balances['BREAD']?['used'], 1);
    });

    test(
      'test_uc11_duplicate_recognized_upc_increments_but_addition_count_is_undercounted',
      () {
        // UC11 extension 2a: a product already in the basket increments its
        // quantity, but addItem's Boolean return value is false for that
        // path, so any caller counting "true" results (as _addAllToBasket
        // does) will underreport the number of items actually affected.
        final firstAdd = state.addItem(
          upc: '333',
          name: 'Receipt Cereal',
          category: 'CEREAL',
        );
        final secondAdd = state.addItem(
          upc: '333',
          name: 'Receipt Cereal',
          category: 'CEREAL',
        );
        expect(firstAdd, isTrue);
        expect(secondAdd, isFalse);
        expect(state.basket, hasLength(1));
        expect(state.basket.single['qty'], 2);
      },
    );

    test('test_uc11_product_without_nutrition_uses_zero_defaults', () {
      // UC11 extension 1a: a recognized product lacking nutrition values
      // receives zero-valued defaults rather than failing to add.
      final added = state.addItem(
        upc: '555',
        name: 'Receipt Juice',
        category: 'JUICE',
      );
      expect(added, isTrue);
      final nutrition =
          state.basket.single['nutrition'] as Map<String, dynamic>;
      expect(nutrition['calories'], 0.0);
      expect(nutrition['protein'], 0.0);
    });
  });

  group('UC12 — Review basket', () {
    late MockAppState state;

    setUp(() {
      state = MockAppState();
      when(state.canAdd(any)).thenReturn(true);
    });

    Future<void> pumpBasket(WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const MaterialApp(home: BasketScreen()),
        ),
      );
    }

    testWidgets('test_uc12_basket_displays_items_quantities_and_categories', (
      WidgetTester tester,
    ) async {
      when(state.basket).thenReturn([
        {
          'upc': '1',
          'name': 'Whole Milk',
          'category': 'MILK',
          'qty': 2,
          'nutrition': const {'calories': 150.0},
        },
        {
          'upc': '2',
          'name': 'Wheat Bread',
          'category': 'BREAD',
          'qty': 1,
          'nutrition': const {'calories': 90.0},
        },
      ]);
      await pumpBasket(tester);
      // ASSERT: each product's name and category appear, proving the basket
      // presents current selections as UC12's main scenario requires.
      expect(find.text('Whole Milk'), findsOneWidget);
      expect(find.text('MILK'), findsOneWidget);
      expect(find.text('Wheat Bread'), findsOneWidget);
      expect(find.text('BREAD'), findsOneWidget);
      expect(find.text('Total Items:'), findsOneWidget);
    });

    testWidgets('test_uc12_empty_basket_shows_empty_state', (
      WidgetTester tester,
    ) async {
      // UC12 extension 1a: an empty basket explains its state and offers to
      // begin product identification rather than showing a blank screen.
      when(state.basket).thenReturn([]);
      await pumpBasket(tester);
      expect(find.text('Your basket is empty'), findsOneWidget);
      expect(find.text('Start Scanning'), findsOneWidget);
    });

    testWidgets(
      'test_uc12_covered_and_paid_lines_for_same_upc_display_separately',
      (WidgetTester tester) async {
        // UC12 extension 1c: a product with both covered and shopper-paid
        // quantities is presented as separate selections, not merged.
        when(state.basket).thenReturn([
          {
            'upc': '9',
            'name': 'Whole Milk',
            'category': 'MILK',
            'qty': 3,
            'nutrition': const <String, dynamic>{},
          },
          {
            'upc': '9',
            'name': 'Whole Milk',
            'category': 'PAID',
            'qty': 1,
            'nutrition': const <String, dynamic>{},
          },
        ]);
        await pumpBasket(tester);
        expect(find.text('Whole Milk'), findsNWidgets(2));
        expect(find.text('MILK'), findsOneWidget);
        expect(find.text('PAID'), findsOneWidget);
      },
    );
  });

  group('UC13 — Review basket-product nutrition', () {
    late MockAppState state;

    setUp(() {
      state = MockAppState();
      when(state.canAdd(any)).thenReturn(true);
    });

    Future<void> pumpBasket(WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const MaterialApp(home: BasketScreen()),
        ),
      );
    }

    testWidgets('test_uc13_expanding_item_shows_nutrition_facts', (
      WidgetTester tester,
    ) async {
      when(state.basket).thenReturn([
        {
          'upc': '1',
          'name': 'Whole Milk',
          'category': 'MILK',
          'qty': 1,
          'nutrition': const {
            'calories': 150.0,
            'totalFat': 8.0,
            'saturatedFat': 5.0,
            'sodium': 120.0,
            'sugar': 12.0,
            'protein': 8.0,
          },
        },
      ]);
      await pumpBasket(tester);
      // ACT: the shopper requests detailed nutrition for the basket product.
      await tester.tap(find.text('Show Nutritional Info'));
      await tester.pumpAndSettle();
      // ASSERT: nutrition facts are visible with the stored values.
      expect(find.text('Nutrition Facts'), findsOneWidget);
      expect(find.text('150.0 cal'), findsOneWidget);
      expect(find.text('8.0g'), findsWidgets);
      expect(find.text('120.0mg'), findsOneWidget);
    });

    testWidgets(
      'test_uc13_missing_nutrition_map_shows_zero_defaults',
      (WidgetTester tester) async {
        // UC13 extension 2a: a basket product with no stored nutrition
        // information displays zero defaults instead of failing.
        when(state.basket).thenReturn([
          {'upc': '2', 'name': 'Mystery Item', 'category': 'CEREAL', 'qty': 1},
        ]);
        await pumpBasket(tester);
        await tester.tap(find.text('Show Nutritional Info'));
        await tester.pumpAndSettle();
        expect(find.text('0.0 cal'), findsOneWidget);
        expect(find.text('0.0mg'), findsWidgets);
      },
    );

    testWidgets('test_uc13_collapsing_hides_nutrition_facts', (
      WidgetTester tester,
    ) async {
      when(state.basket).thenReturn([
        {
          'upc': '1',
          'name': 'Whole Milk',
          'category': 'MILK',
          'qty': 1,
          'nutrition': const {'calories': 150.0},
        },
      ]);
      await pumpBasket(tester);
      await tester.tap(find.text('Show Nutritional Info'));
      await tester.pumpAndSettle();
      expect(find.text('Nutrition Facts'), findsOneWidget);
      // ACT: the shopper returns to the basket summary.
      await tester.tap(find.text('Hide Nutritional Info'));
      await tester.pumpAndSettle();
      expect(find.text('Nutrition Facts'), findsNothing);
      expect(find.text('Show Nutritional Info'), findsOneWidget);
    });
  });

  group('UC14 — Increase product quantity', () {
    late MockAppState state;

    setUp(() {
      state = MockAppState();
      when(state.basket).thenReturn([
        {
          'upc': '1',
          'name': 'Whole Milk',
          'category': 'MILK',
          'qty': 1,
          'nutrition': const <String, dynamic>{},
        },
      ]);
    });

    Future<void> pumpBasket(WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const MaterialApp(home: BasketScreen()),
        ),
      );
    }

    testWidgets(
      'test_uc14_increase_button_calls_increment_when_under_cap',
      (WidgetTester tester) async {
        // ARRANGE: the category has unused allowance.
        when(state.canAdd('MILK')).thenReturn(true);
        await pumpBasket(tester);
        // ACT: shopper presses the "+" control on the basket line.
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();
        // ASSERT: the real state method is invoked with the correct product.
        verify(state.incrementItem('1', 'MILK')).called(1);
      },
    );

    testWidgets(
      'test_uc14_increase_button_still_active_at_cap_and_reports_paid_intent',
      (WidgetTester tester) async {
        // UC14 extension 1a: when allowance is exhausted, the increase
        // control remains enabled (it is not disabled by the inherited UI)
        // and its tooltip signals the shopper-paid path continued in UC15,
        // rather than blocking the action outright.
        when(state.canAdd('MILK')).thenReturn(false);
        await pumpBasket(tester);
        final addButton = find.byIcon(Icons.add_circle_outline);
        expect(addButton, findsOneWidget);
        final tooltipWidget = tester.widget<Tooltip>(
          find.ancestor(
            of: addButton,
            matching: find.byType(Tooltip),
          ),
        );
        expect(tooltipWidget.message, 'Will add as paid');
        await tester.tap(addButton);
        await tester.pump();
        verify(state.incrementItem('1', 'MILK')).called(1);
      },
    );
  });

  group('UC15 — Add shopper-paid quantity (state-level)', () {
    late _SatwiMockStateStore store;
    late MockUser user;
    late AppState state;

    setUp(() async {
      user = MockUser();
      when(user.uid).thenReturn('paid-user');
      store = _SatwiMockStateStore(null);
      state = AppState(db: store.db);
      state.updateUser(user);
      await _waitForLoaded(state);
      // Seed a WIC-covered line that is already at its category cap.
      state.balances['MILK'] = {'allowed': 3, 'used': 3};
      state.basket.add({
        'upc': '777',
        'name': 'Whole Milk',
        'category': 'MILK',
        'qty': 3,
        'nutrition': const {'calories': 150.0},
      });
    });

    test('test_uc15_increment_at_cap_creates_separate_paid_line', () {
      // ACT: the shopper requests one more unit after coverage is exhausted.
      state.incrementItem('777', 'MILK');
      // ASSERT: a distinct PAID line exists; covered usage is unchanged.
      final paidLines = state.basket.where((e) => e['category'] == 'PAID');
      expect(paidLines, hasLength(1));
      expect(paidLines.single['qty'], 1);
      expect(state.balances['MILK']?['used'], 3);
      expect(state.balances['PAID']?['used'], 1);
    });

    test(
      'test_uc15_second_paid_request_increments_existing_paid_line',
      () {
        // UC15 extension 2a: a second shopper-paid request for the same
        // product increases the existing paid line instead of duplicating it.
        state.incrementItem('777', 'MILK');
        state.incrementItem('777', 'MILK');
        final paidLines = state.basket.where((e) => e['category'] == 'PAID');
        expect(paidLines, hasLength(1));
        expect(paidLines.single['qty'], 2);
        expect(state.balances['PAID']?['used'], 2);
      },
    );

    test(
      'test_uc15_paid_category_has_no_allowance_cap_confirming_unlimited_display',
      () {
        // UC15 extension 4a: PAID is derived as an uncapped category, which
        // is why the benefits screen displays it as "unlimited" even though
        // it is not an actual WIC benefit. This test confirms the underlying
        // cause of that documented quirk.
        state.incrementItem('777', 'MILK');
        expect(state.balances['PAID']?['allowed'], isNull);
      },
    );
  });
}

Future<void> _waitForLoaded(AppState state) async {
  for (var attempt = 0; attempt < 100 && !state.balancesLoaded; attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(state.balancesLoaded, isTrue);
}

class _SatwiMockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class _SatwiMockStateStore {
  _SatwiMockStateStore(Map<String, dynamic>? initialData) {
    when(db.collection('users')).thenReturn(collection);
    when(collection.doc(any)).thenReturn(document);
    when(document.get()).thenAnswer((_) async => snapshot);
    when(document.set(any, any)).thenAnswer((_) async {});
    setData(initialData);
  }

  final MockFirebaseFirestore db = MockFirebaseFirestore();
  final MockCollectionReference<Map<String, dynamic>> collection =
      MockCollectionReference<Map<String, dynamic>>();
  final MockDocumentReference<Map<String, dynamic>> document =
      MockDocumentReference<Map<String, dynamic>>();
  final _SatwiMockDocumentSnapshot snapshot = _SatwiMockDocumentSnapshot();

  void setData(Map<String, dynamic>? data) {
    when(snapshot.data()).thenReturn(data);
  }
}
