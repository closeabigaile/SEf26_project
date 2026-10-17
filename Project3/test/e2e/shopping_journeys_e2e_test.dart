// End-to-end shopper journeys across the real screens.
//
// Real ScanScreen, BasketScreen, BalancesScreen and QRCheckoutScreen behind a
// real GoRouter, one AppState, and AplService over a fake Firestore seeded
// with real NC APL records and Open Food Facts nutrition
// (test/fixtures/m2_real_sample.json). Each journey also checks what was
// persisted to users/{uid}.
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
import 'package:wolfbite/screens/balances_screen.dart';
import 'package:wolfbite/screens/basket_screen.dart';
import 'package:wolfbite/screens/scan_screen.dart';
import 'package:wolfbite/services/apl_service.dart';
import 'package:wolfbite/state/app_state.dart';

import '../mocks/mocks.mocks.dart';
import 'e2e_helpers.dart';

const _uid = 'journey-shopper';

class _User extends Mock implements User {
  @override
  String get uid => _uid;
}

final _fixture =
    jsonDecode(File('test/fixtures/m2_real_sample.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> _apl(String upc) => (_fixture['apl'] as List)
    .cast<Map<String, dynamic>>()
    .singleWhere((d) => d['upc'] == upc);

const _vanillaYogurt = '070253640353';
const _greekYogurt = '894700010199';
const _beans = '011110717894';
const _cannellini = '028800145806';
const _cheerios = '016000224698';
const _milk1 = '041900077761'; // "MILK - FAT REDUCED"
const _soymilk = '036632081636'; // same code 52, spelled "MILK-FAT REDUCED"

void main() {
  late FakeFirebaseFirestore db;
  late AppState state;
  late GoRouter router;

  setUp(() async {
    db = FakeFirebaseFirestore();
    for (final d in (_fixture['apl'] as List).cast<Map<String, dynamic>>()) {
      await db.collection('apl').doc(d['upc'] as String).set(d);
    }
    for (final d
        in (_fixture['nutrition'] as List).cast<Map<String, dynamic>>()) {
      await db.collection('nutrition').doc(d['upc'] as String).set(d);
    }
  });

  Future<void> signIn({
    List<Map<String, dynamic>> basket = const [],
    Map<String, dynamic> balances = const {},
    Timestamp? updatedAt,
  }) async {
    await db.collection('users').doc(_uid).set({
      'basket': basket,
      'balances': balances,
      'updatedAt': updatedAt ?? Timestamp.now(),
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

  Future<Map<String, dynamic>> saved(WidgetTester tester) async {
    late Map<String, dynamic> data;
    await tester.runAsync(() async {
      data = (await db.collection('users').doc(_uid).get()).data()!;
    });
    return data;
  }

  Future<void> pumpApp(WidgetTester tester, {String start = '/scan'}) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final apl = AplService(db: db);
    router = GoRouter(
      initialLocation: start,
      routes: [
        GoRoute(
          path: '/scan',
          builder: (_, _) =>
              ScanScreen(aplService: apl, auth: MockFirebaseAuth()),
        ),
        GoRoute(path: '/basket', builder: (_, _) => const BasketScreen()),
        GoRoute(
          path: '/balances',
          builder: (_, _) => BalancesScreen(auth: MockFirebaseAuth()),
        ),
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

  Future<void> go(WidgetTester tester, String path) async {
    router.go(path);
    await tester.pumpAndSettle();
  }

  Future<void> check(WidgetTester tester, String upc) async {
    await enterUpc(tester, upc);
    await tester.tap(find.text('Check'));
    await waitFor(tester, find.text(_apl(upc)['name'] as String));
  }

  Finder addButton() => find.widgetWithText(FilledButton, 'Add');

  Future<void> scanAndAdd(WidgetTester tester, String upc) async {
    await check(tester, upc);
    await tester.ensureVisible(addButton());
    await tester.tap(addButton());
    await tester.pumpAndSettle();
  }

  Finder cardOf(String name) =>
      find.ancestor(of: find.text(name), matching: find.byType(Card)).first;

  Map<String, dynamic> line(String upc, String category) => state.basket
      .singleWhere((l) => l['upc'] == upc && l['category'] == category);

  testWidgets(
    'J1 full category: scan blocks a new product, "+" overflows to PAID, '
    'help explains it, Benefits shows the cap',
    (tester) async {
      await tester.runAsync(
        () => signIn(
          balances: {
            'LEGUMES': {'allowed': 1, 'used': 0},
          },
        ),
      );
      addTearDown(() => state.dispose());
      await pumpApp(tester);

      await scanAndAdd(tester, _beans);
      expect(state.balances['LEGUMES'], {'allowed': 1, 'used': 1});

      // A different legume while the allowance is full cannot be added.
      await check(tester, _cannellini);
      expect(tester.widget<FilledButton>(addButton()).onPressed, isNull);

      // "+" on the existing line overflows into a PAID line.
      await go(tester, '/basket');
      final beansName = _apl(_beans)['name'] as String;
      final plus = find.descendant(
        of: cardOf(beansName),
        matching: find.byIcon(Icons.add_circle_outline),
      );
      await tester.ensureVisible(plus);
      await tester.tap(plus);
      await tester.pumpAndSettle();
      expect(line(_beans, 'LEGUMES')['qty'], 1);
      expect(line(_beans, 'PAID')['qty'], 1);
      expect(line(_beans, 'PAID')['original_benefit_category'], 'LEGUMES');
      expect(state.balances['LEGUMES']!['used'], 1);

      // Checkout help on the PAID line explains the full allowance.
      final help = find.text('Get checkout help');
      expect(help, findsNWidgets(2));
      await tester.ensureVisible(help.last);
      await tester.tap(help.last);
      await tester.pumpAndSettle();
      expect(find.text('Why this item is marked PAID'), findsOneWidget);
      expect(find.textContaining('LEGUMES allowance is full'), findsOneWidget);
      await tester.tap(find.text('Close').first);
      await tester.pumpAndSettle();

      // Benefits screen shows the cap reached.
      await go(tester, '/balances');
      expect(find.text('Used: 1 of 1 items'), findsOneWidget);
      expect(find.text('0 remaining'), findsOneWidget);

      final doc = await saved(tester);
      expect((doc['basket'] as List), hasLength(2));
      expect(doc['balances']['LEGUMES'], {'allowed': 1, 'used': 1});
    },
  );

  testWidgets(
    'J2 scan screen healthier alternative (real data) is added to the basket',
    (tester) async {
      await tester.runAsync(signIn);
      addTearDown(() => state.dispose());
      await pumpApp(tester);

      await check(tester, _vanillaYogurt);
      final view = find.text('View 2 healthier alternatives');
      expect(view, findsOneWidget);
      await tester.ensureVisible(view);
      await tester.tap(view);
      await tester.pumpAndSettle();

      final greek = _apl(_greekYogurt)['name'] as String;
      expect(find.text(greek), findsOneWidget);
      final sheetAdd = find.descendant(
        of: cardOf(greek),
        matching: find.byIcon(Icons.add_circle_outline),
      );
      await tester.tap(sheetAdd);
      await tester.pumpAndSettle();

      expect(find.text('Added healthier item: $greek'), findsOneWidget);
      expect(state.basket.single['upc'], _greekYogurt);
      expect(state.basket.single['nutrition']['addedSugar'], 0);
      expect(state.balances['YOGURT']!['used'], 1);
    },
  );

  testWidgets(
    'J3 two spellings of one APL category share one allowance end to end',
    (tester) async {
      await tester.runAsync(signIn);
      addTearDown(() => state.dispose());
      await pumpApp(tester);

      await scanAndAdd(tester, _milk1);
      await scanAndAdd(tester, _soymilk);

      expect(state.basket.map((l) => l['category']).toSet(), {
        'MILK - FAT REDUCED',
      });
      expect(state.balances.keys, ['MILK - FAT REDUCED']);
      expect(state.balances['MILK - FAT REDUCED']!['used'], 2);

      await go(tester, '/balances');
      expect(find.text('MILK - FAT REDUCED'), findsOneWidget);
      expect(find.text('MILK-FAT REDUCED'), findsNothing);
      expect(find.text('Used: 2 of 3 items'), findsOneWidget);
    },
  );

  testWidgets(
    'J4 checkout: basket -> QR handoff -> finish clears basket, keeps usage',
    (tester) async {
      await tester.runAsync(signIn);
      addTearDown(() => state.dispose());
      await pumpApp(tester);
      await scanAndAdd(tester, _cheerios);
      await scanAndAdd(tester, _beans);

      await go(tester, '/basket');
      final ready = find.text('Ready to Checkout');
      await tester.ensureVisible(ready);
      await tester.tap(ready);
      await tester.pumpAndSettle();
      expect(find.text('QR Code Checkout'), findsOneWidget);

      await tester.tap(find.text('Finish Transaction'));
      await waitFor(tester, find.text('Check a product'));

      expect(state.basket, isEmpty);
      expect(state.balances['BREAKFAST CEREAL']!['used'], 1);
      expect(state.balances['LEGUMES']!['used'], 1);
      expect(find.text('Check a product'), findsOneWidget);

      final doc = await saved(tester);
      expect(doc['basket'], isEmpty);
      expect(doc['balances']['LEGUMES']['used'], 1);
    },
  );

  testWidgets(
    'J5 clear cart: cancel keeps everything, confirm releases usage',
    (tester) async {
      await tester.runAsync(signIn);
      addTearDown(() => state.dispose());
      await pumpApp(tester);
      await scanAndAdd(tester, _cheerios);
      await scanAndAdd(tester, _vanillaYogurt);
      await go(tester, '/basket');

      Future<void> openClear() async {
        final clear = find.text('Clear Cart');
        await tester.ensureVisible(clear);
        await tester.tap(clear);
        await tester.pumpAndSettle();
        expect(find.text('Clear Cart?'), findsOneWidget);
      }

      await openClear();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(state.basket, hasLength(2));

      await openClear();
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();
      expect(state.basket, isEmpty);
      expect(state.balances['BREAKFAST CEREAL']!['used'], 0);
      expect(state.balances['YOGURT']!['used'], 0);

      final doc = await saved(tester);
      expect(doc['basket'], isEmpty);
      expect(doc['balances']['YOGURT']['used'], 0);
    },
  );

  testWidgets(
    'J6 quantity controls keep basket, balances and storage consistent',
    (tester) async {
      await tester.runAsync(
        () => signIn(
          balances: {
            'BREAKFAST CEREAL': {'allowed': 2, 'used': 0},
          },
        ),
      );
      addTearDown(() => state.dispose());
      await pumpApp(tester);
      await scanAndAdd(tester, _cheerios);
      await go(tester, '/basket');

      final name = _apl(_cheerios)['name'] as String;
      Future<void> tapIcon(IconData icon) async {
        final target = find
            .descendant(of: cardOf(name), matching: find.byIcon(icon))
            .first;
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      await tapIcon(Icons.add_circle_outline); // 2 of 2
      await tapIcon(Icons.add_circle_outline); // overflow -> PAID 1
      expect(line(_cheerios, 'BREAKFAST CEREAL')['qty'], 2);
      expect(line(_cheerios, 'PAID')['qty'], 1);
      expect(state.balances['BREAKFAST CEREAL']!['used'], 2);

      await tapIcon(Icons.remove_circle_outline); // PAID removed first
      expect(state.basket, hasLength(1));
      expect(state.basket.single['qty'], 2);
      await tapIcon(Icons.remove_circle_outline); // back to 1
      expect(state.balances['BREAKFAST CEREAL']!['used'], 1);

      final doc = await saved(tester);
      expect((doc['basket'] as List).single['qty'], 1);
      expect(doc['balances']['BREAKFAST CEREAL']['used'], 1);
    },
  );

  testWidgets(
    'J7 a session from last month resets usage and clears the basket',
    (tester) async {
      final lastMonth = DateTime.now().subtract(const Duration(days: 40));
      await tester.runAsync(
        () => signIn(
          basket: [
            {
              'upc': _cheerios,
              'name': 'old',
              'category': 'BREAKFAST CEREAL',
              'qty': 2,
            },
          ],
          balances: {
            'BREAKFAST CEREAL': {'allowed': 2, 'used': 2},
          },
          updatedAt: Timestamp.fromDate(lastMonth),
        ),
      );
      addTearDown(() => state.dispose());
      await pumpApp(tester, start: '/balances');

      expect(state.basket, isEmpty);
      expect(state.balances['BREAKFAST CEREAL'], {'allowed': 2, 'used': 0});
      expect(find.text('Used: 0 of 2 items'), findsOneWidget);
      final doc = await saved(tester);
      expect(doc['basket'], isEmpty);
    },
  );

  testWidgets(
    'J8 resume: a saved basket reloads with real nutrition and M2 works',
    (tester) async {
      await tester.runAsync(signIn);
      await pumpApp(tester);
      await scanAndAdd(tester, _vanillaYogurt);
      await scanAndAdd(tester, '011110810106');
      final first = state;

      // Restart: a fresh AppState loads the persisted users/{uid} document.
      late AppState resumed;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        resumed = AppState(db: db);
        final loaded = Completer<void>();
        resumed.addListener(() {
          if (resumed.balancesLoaded && !loaded.isCompleted) {
            loaded.complete();
          }
        });
        resumed.updateUser(_User());
        await loaded.future;
      });
      state = resumed;
      addTearDown(() {
        first.dispose();
        resumed.dispose();
      });

      final yogurt = state.basket.singleWhere(
        (l) => l['upc'] == _vanillaYogurt,
      );
      expect(yogurt['nutrition']['addedSugar'], 17);
      expect(yogurt['nutrition']['sodium'], 169);
      expect(state.balances['YOGURT']!['used'], 1);

      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, start: '/basket');
      final balance = find.text('Check basket balance');
      await tester.ensureVisible(balance);
      await tester.tap(balance);
      await waitFor(
        tester,
        find.textContaining('for CHOBANI LOW-FAT PLAIN GREEK YOGURT'),
      );
    },
  );
}
