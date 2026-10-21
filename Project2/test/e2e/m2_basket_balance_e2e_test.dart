// M2 end to end: real AppState + BasketScreen + basket balance sheet, backed
// by FakeFirebaseFirestore seeded with scripts/m2_catalog.json (the same file
// scripts/seed_m2.js writes to Firestore).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wolfbite/screens/basket_screen.dart';
import 'package:wolfbite/state/app_state.dart';
import 'package:wolfbite/utils/nutritional_utils.dart';

const _uid = 'm2-shopper';

class _User extends Mock implements User {
  @override
  String get uid => _uid;
}

final _catalog =
    (jsonDecode(File('scripts/m2_catalog.json').readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();

Map<String, dynamic> _product(String upc) =>
    _catalog.singleWhere((p) => p['upc'] == upc);

/// A basket line as AppState stores it after a scan of [upc].
Map<String, dynamic> _line(String upc, int qty) {
  final p = _product(upc);
  return {
    'upc': upc,
    'name': p['name'],
    'category': p['category'],
    'original_benefit_category': p['category'],
    'qty': qty,
    'nutrition': NutritionalUtils.buildNutritionFromFoodNutrients(p),
  };
}

const _flakes = '299900000101';
const _bran = '299900000103';
const _whiteBread = '299900000201';
const _wheatBread = '299900000202';

void main() {
  late FakeFirebaseFirestore db;

  setUp(() async {
    db = FakeFirebaseFirestore();
    for (final p in _catalog) {
      await db.collection('apl').doc(p['upc'] as String).set(p);
    }
  });

  Future<AppState> signIn(
    List<Map<String, dynamic>> basket,
    Map<String, dynamic> balances,
  ) async {
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

  Future<void> openSheet(WidgetTester tester, AppState state) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: BasketScreen()),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.text('Check basket balance');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Finder suggestionCard(String text) =>
      find.ancestor(of: find.text(text), matching: find.byType(Card));

  testWidgets(
    'M2-E2E-1 low-fiber basket: preview, confirm swap, persist, recalculate',
    (tester) async {
      late AppState state;
      await tester.runAsync(() async {
        state = await signIn(
          [_line(_flakes, 2), _line(_whiteBread, 1)],
          {
            'CEREAL': {'allowed': 2, 'used': 2},
            'BREAD': {'allowed': 2, 'used': 1},
          },
        );
      });
      addTearDown(state.dispose);
      final basketBefore = jsonEncode(state.basket);
      final balancesBefore = jsonEncode(state.balances);

      await openSheet(tester, state);

      // Fiber averages 0.9 g per serving over 3 items: the largest gap.
      expect(find.text('Basket balance'), findsOneWidget);
      expect(
        find.text('Fiber: 0.9 g per serving (largest gap)'),
        findsOneWidget,
      );
      expect(find.text('Suggested swaps for fiber'), findsOneWidget);

      const branSwap =
          'Swap Example Frosted Corn Flakes (×2) for Example Bran Flakes';
      const breadSwap =
          'Swap Example White Sandwich Bread for Example Whole Wheat Bread';
      expect(find.text(branSwap), findsOneWidget);
      expect(find.text(breadSwap), findsOneWidget);
      expect(
        find.text('Basket fiber average: 0.9 g → 3.9 g per serving'),
        findsOneWidget,
      );

      // Previewing changes nothing.
      expect(jsonEncode(state.basket), basketBefore);
      expect(jsonEncode(state.balances), balancesBefore);

      // Shopper confirms the top swap.
      await tester.tap(
        find.descendant(
          of: suggestionCard(branSwap),
          matching: find.text('Confirm swap'),
        ),
      );
      await tester.pumpAndSettle();

      final cereal = state.basket.singleWhere((l) => l['category'] == 'CEREAL');
      expect(cereal['upc'], _bran);
      expect(cereal['qty'], 2);
      expect(state.balances['CEREAL'], {'allowed': 2, 'used': 2});
      expect(state.basket, hasLength(2));

      // Recalculated in place: fiber is now within the example target.
      expect(find.text(branSwap), findsNothing);
      expect(
        find.text('Your basket is within the example per-serving targets.'),
        findsOneWidget,
      );

      // Persisted to the user's Firestore document.
      late Map<String, dynamic> saved;
      await tester.runAsync(() async {
        saved = (await db.collection('users').doc(_uid).get()).data()!;
      });
      final savedCereal = (saved['basket'] as List).cast<Map>().singleWhere(
        (l) => l['category'] == 'CEREAL',
      );
      expect(savedCereal['upc'], _bran);
      expect(savedCereal['qty'], 2);
    },
  );

  testWidgets(
    'M2-E2E-2 swapping into a product already in the basket merges quantity',
    (tester) async {
      late AppState state;
      await tester.runAsync(() async {
        state = await signIn(
          [_line(_whiteBread, 1), _line(_wheatBread, 1)],
          {
            'BREAD': {'allowed': 2, 'used': 2},
          },
        );
      });
      addTearDown(state.dispose);

      final swapped = state.swapItem(
        fromUpc: _whiteBread,
        category: 'BREAD',
        toUpc: _wheatBread,
        toName: _product(_wheatBread)['name'] as String,
      );
      expect(swapped, isTrue);
      expect(state.basket.single['upc'], _wheatBread);
      expect(state.basket.single['qty'], 2);
      expect(state.balances['BREAD'], {'allowed': 2, 'used': 2});
    },
  );

  testWidgets(
    'M2-E2E-3 basket without nutrition data (real APL items) abstains',
    (tester) async {
      late AppState state;
      await tester.runAsync(() async {
        // Real NC APL documents have no foodNutrients, so scanned lines
        // carry unknown nutrition.
        state = await signIn(
          [
            {
              'upc': '039400011606',
              'name': 'APL item without nutrition',
              'category': 'CEREAL',
              'qty': 1,
            },
          ],
          {
            'CEREAL': {'allowed': 2, 'used': 1},
          },
        );
      });
      addTearDown(state.dispose);

      await openSheet(tester, state);
      expect(
        find.textContaining('Not enough nutrition information'),
        findsOneWidget,
      );
      expect(find.text('Confirm swap'), findsNothing);
      expect(find.text('Sodium: Unknown per serving'), findsOneWidget);
    },
  );

  test('swapItem refuses PAID lines and unknown lines', () async {
    final state = await signIn(
      [
        _line(_flakes, 1),
        {..._line(_flakes, 1), 'category': 'PAID'},
      ],
      {
        'CEREAL': {'allowed': 1, 'used': 1},
        'PAID': {'allowed': null, 'used': 1},
      },
    );
    addTearDown(state.dispose);
    expect(
      state.swapItem(
        fromUpc: _flakes,
        category: 'PAID',
        toUpc: _bran,
        toName: 'x',
      ),
      isFalse,
    );
    expect(
      state.swapItem(
        fromUpc: 'missing',
        category: 'CEREAL',
        toUpc: _bran,
        toName: 'x',
      ),
      isFalse,
    );
    expect(state.basket.map((l) => l['upc']), [_flakes, _flakes]);
  });
}
