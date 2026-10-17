// Integration: the real ScanScreen and BasketScreen behind a real GoRouter,
// one AppState and AplService over a fake Firestore seeded with real APL
// records and Open Food Facts nutrition (test/fixtures/m2_real_sample.json).
//
// Flow: scan two real UPCs -> nutrition comes from nutrition/{upc} -> basket ->
// M1 nutrition panel -> M2 basket balance -> confirm swap -> persisted.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wolfbite/screens/basket_screen.dart';
import 'package:wolfbite/screens/scan_screen.dart';
import 'package:wolfbite/services/apl_service.dart';
import 'package:wolfbite/state/app_state.dart';

import '../mocks/mocks.mocks.dart';

const _uid = 'scan-shopper';

class _User extends Mock implements User {
  @override
  String get uid => _uid;
}

final _fixture =
    jsonDecode(File('test/fixtures/m2_real_sample.json').readAsStringSync())
        as Map<String, dynamic>;

const _vanillaYogurt = '070253640353';
const _oatCereal = '011110810106';
const _greekYogurt = '894700010199';
const _cornFlakes = '003800000120';

void main() {
  late FakeFirebaseFirestore db;
  late AppState state;
  late GoRouter router;

  setUp(() async {
    db = FakeFirebaseFirestore();
    for (final doc in (_fixture['apl'] as List).cast<Map<String, dynamic>>()) {
      await db.collection('apl').doc(doc['upc'] as String).set(doc);
    }
    for (final doc
        in (_fixture['nutrition'] as List).cast<Map<String, dynamic>>()) {
      await db.collection('nutrition').doc(doc['upc'] as String).set(doc);
    }
  });

  Future<void> signIn() async {
    await db.collection('users').doc(_uid).set({
      'basket': [],
      'balances': {},
      'updatedAt': Timestamp.now(),
    });
    state = AppState(db: db);
    final loaded = Completer<void>();
    void onChange() {
      if (state.balancesLoaded && !loaded.isCompleted) loaded.complete();
    }

    state.addListener(onChange);
    state.updateUser(_User());
    await loaded.future;
    state.removeListener(onChange);
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final apl = AplService(db: db);
    router = GoRouter(
      initialLocation: '/scan',
      routes: [
        GoRoute(
          path: '/scan',
          builder: (_, _) =>
              ScanScreen(aplService: apl, auth: MockFirebaseAuth()),
        ),
        GoRoute(path: '/basket', builder: (_, _) => const BasketScreen()),
      ],
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Types [upc] into the manual entry field, checks it, and adds it.
  Future<void> scanAndAdd(WidgetTester tester, String upc, String name) async {
    await tester.enterText(find.widgetWithText(TextField, 'UPC Code'), upc);
    await tester.tap(find.text('Check'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(find.text(name), findsWidgets);
    final add = find.widgetWithText(FilledButton, 'Add');
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'M2-INT-1 scan real UPCs -> nutrition from nutrition/ -> balance -> swap',
    (tester) async {
      await tester.runAsync(signIn);
      addTearDown(() => state.dispose());
      await pumpApp(tester);

      await scanAndAdd(
        tester,
        _vanillaYogurt,
        'OUR FAMILY NONFAT YOGURT VANILLA 32 OZ',
      );
      await scanAndAdd(
        tester,
        _oatCereal,
        'KROGER LIVING WELL WHOLE GRAIN OAT CEREAL',
      );

      // Scanned lines carry the real nutrition and canonical categories.
      expect(state.basket, hasLength(2));
      final yogurt = state.basket.singleWhere(
        (l) => l['upc'] == _vanillaYogurt,
      );
      expect(yogurt['category'], 'YOGURT');
      expect(yogurt['nutrition']['addedSugar'], 17);
      expect(yogurt['nutrition']['sodium'], 169);
      expect(yogurt['nutrition']['servingBasis'], startsWith('per serving'));
      final cereal = state.basket.singleWhere((l) => l['upc'] == _oatCereal);
      expect(cereal['category'], 'BREAKFAST CEREAL');
      expect(cereal['nutrition']['addedSugar'], isNull);

      // Basket screen, M1 nutrition panel shows the measured value.
      router.go('/basket');
      await tester.pumpAndSettle();
      final yogurtCard = find
          .ancestor(
            of: find.text('OUR FAMILY NONFAT YOGURT VANILLA 32 OZ'),
            matching: find.byType(Card),
          )
          .first;
      final toggle = find.descendant(
        of: yogurtCard,
        matching: find.text('Show Nutritional Info'),
      );
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.text('169mg'), findsWidgets);

      // M2: added sugar is the largest gap; plain Greek yogurt is suggested.
      final balance = find.text('Check basket balance');
      await tester.ensureVisible(balance);
      await tester.tap(balance);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Added sugar: 17 g per serving (largest gap)'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Based on 1 of 2 items; the rest have no added sugar value',
        ),
        findsOneWidget,
      );
      const swap =
          'Swap OUR FAMILY NONFAT YOGURT VANILLA 32 OZ for CHOBANI LOW-FAT PLAIN GREEK YOGURT';
      expect(find.text(swap), findsOneWidget);
      expect(
        find.textContaining('Nutrition data: Open Food Facts'),
        findsWidgets,
      );

      final card = find.ancestor(
        of: find.text(swap),
        matching: find.byType(Card),
      );
      await tester.tap(
        find.descendant(of: card, matching: find.text('Confirm swap')),
      );
      await tester.pumpAndSettle();

      expect(state.basket.map((l) => l['upc']).toSet(), {
        _greekYogurt,
        _oatCereal,
      });
      expect(state.balances['YOGURT']!['used'], 1);
      expect(find.text(swap), findsNothing);

      late Map<String, dynamic> saved;
      await tester.runAsync(() async {
        saved = (await db.collection('users').doc(_uid).get()).data()!;
      });
      expect(
        (saved['basket'] as List).cast<Map>().map((l) => l['upc']).toSet(),
        {_greekYogurt, _oatCereal},
      );
    },
  );

  testWidgets(
    'M2-INT-2 "Not now" hides a suggestion for the rest of the session',
    (tester) async {
      await tester.runAsync(signIn);
      addTearDown(() => state.dispose());
      await pumpApp(tester);
      await scanAndAdd(
        tester,
        _vanillaYogurt,
        'OUR FAMILY NONFAT YOGURT VANILLA 32 OZ',
      );
      // Cereal adds fiber so added sugar, not fiber, is the largest gap.
      await scanAndAdd(
        tester,
        _oatCereal,
        'KROGER LIVING WELL WHOLE GRAIN OAT CEREAL',
      );

      router.go('/basket');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check basket balance'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();

      final first = find.textContaining(
        'for CHOBANI LOW-FAT PLAIN GREEK YOGURT',
      );
      expect(first, findsOneWidget);
      final card = find.ancestor(of: first, matching: find.byType(Card));
      await tester.tap(
        find.descendant(of: card, matching: find.text('Not now')),
      );
      await tester.pumpAndSettle();

      expect(first, findsNothing);
      // The next-best real option (Activia, 6 g added sugar) takes its place.
      expect(
        find.textContaining(
          'Swap OUR FAMILY NONFAT YOGURT VANILLA 32 OZ for ACTIVIA',
        ),
        findsOneWidget,
      );
      // Activia has no fiber value in Open Food Facts: shown as a tradeoff.
      expect(
        find.textContaining('Fiber is unknown for ACTIVIA'),
        findsOneWidget,
      );
      expect(
        state.basket.map((l) => l['upc']),
        containsAll([_vanillaYogurt, _oatCereal]),
      );
    },
  );

  testWidgets(
    'M2-INT-3 a real APL product with no nutrition anywhere stays Unknown',
    (tester) async {
      await tester.runAsync(signIn);
      addTearDown(() => state.dispose());
      await pumpApp(tester);
      await scanAndAdd(tester, _cornFlakes, "KELLOGG'S CORN FLAKES");

      final line = state.basket.single;
      expect(line['category'], 'BREAKFAST CEREAL');
      expect(line['nutrition']['sodium'], isNull);

      router.go('/basket');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check basket balance'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Not enough nutrition information'),
        findsOneWidget,
      );
      expect(find.text('Confirm swap'), findsNothing);
    },
  );
}
