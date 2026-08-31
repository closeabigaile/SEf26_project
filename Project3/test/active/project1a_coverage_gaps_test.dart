import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wolfbite/screens/basket_screen.dart';
import 'package:wolfbite/state/app_state.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  group('UC14 and UC15 quantity transitions', () {
    late AppState state;

    setUp(() async {
      state = await _loadedState();
      state.balances['MILK'] = {'allowed': 3, 'used': 1};
      state.basket.add({
        'upc': 'milk-1',
        'name': 'Whole Milk',
        'category': 'MILK',
        'qty': 1,
        'nutrition': const <String, dynamic>{},
      });
    });

    test('available allowance increments quantity and covered usage', () {
      state.incrementItem('milk-1', 'MILK');

      expect(state.basket.single['qty'], 2);
      expect(state.balances['MILK']?['used'], 2);
      expect(state.basket.where((item) => item['category'] == 'PAID'), isEmpty);
    });

    test('missing covered product leaves quantity and usage unchanged', () {
      state.incrementItem('missing', 'MILK');

      expect(state.basket.single['qty'], 1);
      expect(state.balances['MILK']?['used'], 1);
    });

    test('missing original product cannot create a shopper-paid line', () {
      state.balances['MILK'] = {'allowed': 1, 'used': 1};
      state.incrementItem('missing', 'MILK');

      expect(state.basket, hasLength(1));
      expect(state.basket.where((item) => item['category'] == 'PAID'), isEmpty);
      expect(state.balances['MILK']?['used'], 1);
    });
  });

  group('Persisted basket mutations', () {
    late FakeFirebaseFirestore firestore;
    late AppState state;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      state = await _loadedState(firestore: firestore, uid: 'mutations');
    });

    test('UC8 accepted addition persists basket and benefit usage', () async {
      expect(
        state.addItem(upc: 'milk-1', name: 'Milk', category: 'MILK'),
        isTrue,
      );

      final saved = await _waitForSavedDocument(
        firestore,
        'mutations',
        (data) => (data['basket'] as List).isNotEmpty,
      );
      expect(saved['basket'][0]['upc'], 'milk-1');
      expect(saved['balances']['MILK']['used'], 1);
    });

    test('UC14 quantity increase persists quantity and covered usage', () async {
      state.balances['MILK'] = {'allowed': 3, 'used': 1};
      state.basket.add({
        'upc': 'milk-1',
        'name': 'Milk',
        'category': 'MILK',
        'qty': 1,
      });

      state.incrementItem('milk-1', 'MILK');

      final saved = await _waitForSavedDocument(
        firestore,
        'mutations',
        (data) =>
            (data['basket'] as List).isNotEmpty &&
            data['basket'][0]['qty'] == 2,
      );
      expect(saved['balances']['MILK']['used'], 2);
    });

    test('UC16 quantity decrease persists quantity and released usage', () async {
      state.balances['MILK'] = {'allowed': 3, 'used': 2};
      state.basket.add({
        'upc': 'milk-1',
        'name': 'Milk',
        'category': 'MILK',
        'qty': 2,
      });

      state.decrementItem('milk-1', 'MILK');

      final saved = await _waitForSavedDocument(
        firestore,
        'mutations',
        (data) =>
            (data['basket'] as List).isNotEmpty &&
            data['basket'][0]['qty'] == 1,
      );
      expect(saved['balances']['MILK']['used'], 1);
    });

    test('UC17 clear persists empty basket and reversed usage', () async {
      state.balances['MILK'] = {'allowed': 3, 'used': 2};
      state.basket.add({
        'upc': 'milk-1',
        'name': 'Milk',
        'category': 'MILK',
        'qty': 2,
      });

      state.clearBasket();

      final saved = await _waitForSavedDocument(
        firestore,
        'mutations',
        (data) =>
            (data['basket'] as List).isEmpty &&
            data['balances']['MILK']['used'] == 0,
      );
      expect(saved['basket'], isEmpty);
    });
  });

  group('UC17 clear confirmation', () {
    late MockAppState state;

    setUp(() {
      state = MockAppState();
      when(state.basket).thenReturn([
        {
          'upc': 'milk-1',
          'name': 'Milk',
          'category': 'MILK',
          'qty': 1,
          'nutrition': const <String, dynamic>{},
        },
      ]);
      when(state.canAdd('MILK')).thenReturn(true);
      when(state.clearBasket()).thenAnswer((_) {});
    });

    Future<void> pumpBasket(WidgetTester tester) => tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: const BasketScreen(),
        ),
      ),
    );

    testWidgets('cancelling clear leaves the basket unchanged', (tester) async {
      await pumpBasket(tester);
      await tester.tap(find.text('Clear Cart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(state.clearBasket());
      expect(find.text('Milk'), findsOneWidget);
    });

    testWidgets('confirming clear invokes the state transition once', (
      tester,
    ) async {
      await pumpBasket(tester);
      await tester.tap(find.text('Clear Cart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      verify(state.clearBasket()).called(1);
    });
  });

  group('UC20 persisted checkout state', () {
    test('checkout saves an empty basket and retains used benefits', () async {
      final firestore = FakeFirebaseFirestore();
      final state = await _loadedState(firestore: firestore, uid: 'checkout');
      state.balances['MILK'] = {'allowed': 3, 'used': 2};
      state.basket.add({
        'upc': '11111',
        'name': 'Milk',
        'category': 'MILK',
        'qty': 2,
      });

      await state.checkout();

      final saved =
          (await firestore.collection('users').doc('checkout').get()).data()!;
      expect(saved['basket'], isEmpty);
      expect(saved['balances']['MILK']['used'], 2);
    });

    test('save failure leaves the local basket cleared and reports failure', () async {
      final harness = _FailingPersistenceHarness();
      final state = await harness.loadedState();
      state.balances['MILK'] = {'allowed': 3, 'used': 1};
      state.basket.add({
        'upc': '11111',
        'name': 'Milk',
        'category': 'MILK',
        'qty': 1,
      });
      harness.failWrites();

      await expectLater(state.checkout(), throwsA(isA<FirebaseException>()));

      expect(state.basket, isEmpty);
      expect(state.balances['MILK']?['used'], 1);
    });
  });
}

Future<AppState> _loadedState({
  FakeFirebaseFirestore? firestore,
  String uid = 'active-suite-user',
}) async {
  final db = firestore ?? FakeFirebaseFirestore();
  await db.collection('users').doc(uid).set({
    'balances': <String, dynamic>{},
    'basket': <Map<String, dynamic>>[],
  });
  final user = MockUser();
  when(user.uid).thenReturn(uid);
  final state = AppState(db: db)..updateUser(user);
  for (var attempt = 0; attempt < 100 && !state.balancesLoaded; attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(state.balancesLoaded, isTrue);
  return state;
}

Future<Map<String, dynamic>> _waitForSavedDocument(
  FakeFirebaseFirestore firestore,
  String uid,
  bool Function(Map<String, dynamic>) condition,
) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    final data = (await firestore.collection('users').doc(uid).get()).data();
    if (data != null && condition(data)) return data;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('Timed out waiting for persisted state');
}

class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class _FailingPersistenceHarness {
  final MockFirebaseFirestore firestore = MockFirebaseFirestore();
  final MockCollectionReference<Map<String, dynamic>> collection =
      MockCollectionReference<Map<String, dynamic>>();
  final MockDocumentReference<Map<String, dynamic>> document =
      MockDocumentReference<Map<String, dynamic>>();
  final _MockDocumentSnapshot snapshot = _MockDocumentSnapshot();

  _FailingPersistenceHarness() {
    when(firestore.collection('users')).thenReturn(collection);
    when(collection.doc(any)).thenReturn(document);
    when(document.get()).thenAnswer((_) async => snapshot);
    when(snapshot.data()).thenReturn({
      'balances': <String, dynamic>{},
      'basket': <Map<String, dynamic>>[],
    });
    when(document.set(any, any)).thenAnswer((_) async {});
  }

  Future<AppState> loadedState() async {
    final user = MockUser();
    when(user.uid).thenReturn('checkout-failure');
    final state = AppState(db: firestore)..updateUser(user);
    for (var attempt = 0; attempt < 100 && !state.balancesLoaded; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    expect(state.balancesLoaded, isTrue);
    return state;
  }

  void failWrites() {
    when(document.set(any, any)).thenThrow(
      FirebaseException(plugin: 'cloud_firestore', message: 'save failed'),
    );
  }
}
