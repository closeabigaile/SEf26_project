// IMPORTS
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wolfbite/screens/balances_screen.dart';
import 'package:wolfbite/state/app_state.dart';
import 'package:wolfbite/screens/qr_checkout_screen.dart';

import '../mocks/mocks.mocks.dart';


class MockUser extends Mock implements User {
    @override
    String get uid => 'supreme-test-uid';
}

// 
void main() {
    group('UC16 - Decrease product quantity', () {

        // Declare what every UC16 test needs
        late AppState appState;
        late FakeFirebaseFirestore fakeFirestore;
        late MockUser mockUser;

        // Runs fresh before every test
        setUp(() {
            fakeFirestore = FakeFirebaseFirestore();
            appState = AppState(db: fakeFirestore);
            mockUser = MockUser();

            // Have WolfBite think fake shopper is signed in
            appState.updateUser(mockUser);
        });

        test('test_uc16_decrease_covered_quantity_updates_quantity_and_usage', () {
            // ARRANGE: add two covered units of the same product.
            appState.addItem(
                upc: '12345',
                name: 'Milk',
                category: 'MILK',
            );

            appState.incrementItem('12345', 'MILK');

            expect(appState.basket.first['qty'], 2);
            expect(appState.balances['MILK']!['used'], 2);

            // ACT: shopper removes one unit.
            appState.decrementItem('12345', 'MILK');

            // ASSERT: quantity and covered benefit usage both decrease by one.
            expect(appState.basket.first['qty'], 1);
            expect(appState.balances['MILK']!['used'], 1);
        });


        test('test_uc16_quantity_reaching_zero_removes_selection', () {
            // ARRANGE: basket contains one covered unit.
            appState.addItem(
                upc: '12345',
                name: 'Milk',
                category: 'MILK',
            );

            // ACT: remove the only unit.
            appState.decrementItem('12345', 'MILK');

            // ASSERT: selection is removed and usage returns to zero.
            expect(appState.basket, isEmpty);
            expect(appState.balances['MILK']!['used'], 0);
        });


        test('test_uc16_paid_quantity_is_decreased_before_covered_quantity', () {
            // ARRANGE: fill the MILK allowance with covered units.
            appState.addItem(
                upc: '12345',
                name: 'Milk',
                category: 'MILK',
            );
            appState.incrementItem('12345', 'MILK');
            appState.incrementItem('12345', 'MILK');

            // Allowance is now full, so another increment becomes PAID.
            appState.incrementItem('12345', 'MILK');

            expect(appState.balances['MILK']!['used'], 3);
            expect(appState.balances['PAID']!['used'], 1);

            // ACT: decrease the product.
            appState.decrementItem('12345', 'MILK');

            // ASSERT: PAID quantity is removed first.
            expect(appState.balances['MILK']!['used'], 3);
            expect(appState.balances['PAID']!['used'], 0);

            final coveredItem = appState.basket.firstWhere(
                (item) => item['category'] == 'MILK',
            );

            expect(coveredItem['qty'], 3);
            expect(
                appState.basket.where((item) => item['category'] == 'PAID'),
                isEmpty,
            );
        });


        test('test_uc16_missing_product_causes_no_quantity_change', () {
            // ARRANGE: basket contains one product.
            appState.addItem(
                upc: '12345',
                name: 'Milk',
                category: 'MILK',
            );

            // ACT: attempt to decrease a different product.
            appState.decrementItem('99999', 'MILK');

            // ASSERT: existing basket and benefit usage are unchanged.
            expect(appState.basket.length, 1);
            expect(appState.basket.first['upc'], '12345');
            expect(appState.basket.first['qty'], 1);
            expect(appState.balances['MILK']!['used'], 1);
        });


        test('test_uc16_benefit_usage_does_not_go_below_zero', () {
            // ARRANGE: product exists but recorded usage is already zero.
            appState.addItem(
                upc: '12345',
                name: 'Milk',
                category: 'MILK',
            );

            appState.balances['MILK']!['used'] = 0;

            // ACT: remove the product.
            appState.decrementItem('12345', 'MILK');

            // ASSERT: usage remains zero rather than becoming negative.
            expect(appState.basket, isEmpty);
            expect(appState.balances['MILK']!['used'], 0);
        });
    });

    group('UC17 — Clear basket', () {
        late AppState appState;
        late FakeFirebaseFirestore fakeFirestore;
        late MockUser mockUser;

        setUp(() {
            fakeFirestore = FakeFirebaseFirestore();
            appState = AppState(db: fakeFirestore);
            mockUser = MockUser();

            appState.updateUser(mockUser);
        });

        test('test_uc17_clear_removes_all_products_and_reverses_usage', () {
            // ARRANGE: basket contains multiple covered products.
            appState.addItem(
            upc: '11111',
            name: 'Milk',
            category: 'MILK',
            );

            appState.incrementItem('11111', 'MILK');

            expect(appState.basket.first['qty'], 2);
            expect(appState.balances['MILK']!['used'], 2);

            // ACT: clear the basket.
            appState.clearBasket();

            // ASSERT: all selections are removed and provisional usage is reversed.
            expect(appState.basket, isEmpty);
            expect(appState.balances['MILK']!['used'], 0);
        });


        test('test_uc17_clear_reverses_usage_across_multiple_categories', () {
            // ARRANGE: basket contains products from different benefit categories.
            appState.addItem(
                upc: '11111',
                name: 'Milk',
                category: 'MILK',
            );

            appState.addItem(
                upc: '22222',
                name: 'Bread',
                category: 'BREAD',
            );

            expect(appState.balances['MILK']!['used'], 1);
            expect(appState.balances['BREAD']!['used'], 1);

            // ACT
            appState.clearBasket();

            // ASSERT
            expect(appState.basket, isEmpty);
            expect(appState.balances['MILK']!['used'], 0);
            expect(appState.balances['BREAD']!['used'], 0);
        });


        test('test_uc17_missing_category_balance_still_removes_product', () {
            // ARRANGE
            appState.addItem(
                upc: '11111',
                name: 'Milk',
                category: 'MILK',
            );

            // Simulate missing balance information for the basket category.
            appState.balances.remove('MILK');

            // ACT
            appState.clearBasket();

            // ASSERT: product is still removed.
            expect(appState.basket, isEmpty);
            expect(appState.balances.containsKey('MILK'), isFalse);
        });


        test('test_uc17_clear_does_not_make_usage_negative', () {
            // ARRANGE
            appState.addItem(
                upc: '11111',
                name: 'Milk',
                category: 'MILK',
            );

            appState.incrementItem('11111', 'MILK');

            // Simulate inconsistent saved state: qty 2 but recorded usage only 1.
            appState.balances['MILK']!['used'] = 1;

            // ACT
            appState.clearBasket();

            // ASSERT
            expect(appState.basket, isEmpty);
            expect(appState.balances['MILK']!['used'], 0);
        });
    });

    group('UC18 — Review benefit balances', () {
        late MockAppState mockAppState;
        late MockFirebaseAuth mockAuth;

        setUp(() {
            mockAppState = MockAppState();
            mockAuth = MockFirebaseAuth();
        });

        Future<void> pumpBalancesScreen(WidgetTester tester) async {
            await tester.pumpWidget(
            ChangeNotifierProvider<AppState>.value(
                value: mockAppState,
                child: MaterialApp(
                home: BalancesScreen(auth: mockAuth),
                ),
            ),
            );
        }

        testWidgets('test_uc18_paid_category_is_displayed_as_unlimited', (
            WidgetTester tester,
        ) async {
            // ARRANGE
            when(mockAppState.balancesLoaded).thenReturn(true);
            when(mockAppState.balances).thenReturn({
            'PAID': {'allowed': null, 'used': 2},
            });

            // ACT
            await pumpBalancesScreen(tester);

            // ASSERT
            expect(find.text('PAID'), findsOneWidget);
            expect(find.text('Unlimited'), findsOneWidget);
            expect(find.text('Used: 2 items'), findsOneWidget);
        });


        testWidgets('test_uc18_usage_at_allowance_shows_full_progress', (
            WidgetTester tester,
        ) async {
            // ARRANGE
            when(mockAppState.balancesLoaded).thenReturn(true);
            when(mockAppState.balances).thenReturn({
            'MILK': {'allowed': 3, 'used': 3},
            });

            // ACT
            await pumpBalancesScreen(tester);

            // ASSERT
            expect(find.text('MILK'), findsOneWidget);
            expect(find.text('Used: 3 of 3 items'), findsOneWidget);

            final progress = tester.widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
            );

            expect(progress.value, 1.0);
        });
    });

    group('UC19 — Prepare checkout handoff', () {
        testWidgets('test_uc19_qr_code_contains_current_basket_data', (
            WidgetTester tester,
        ) async {
            // ARRANGE
            final appState = AppState(db: FakeFirebaseFirestore());

            appState.basket.add({
            'upc': '11111',
            'name': 'Milk',
            'category': 'MILK',
            'qty': 2,
            });

            await tester.pumpWidget(
            ChangeNotifierProvider<AppState>.value(
                value: appState,
                child: const MaterialApp(
                home: QRCheckoutScreen(),
                ),
            ),
            );

            await tester.pumpAndSettle();

            // ASSERT: a scannable representation of the basket is displayed.
            expect(find.byType(QrImageView), findsOneWidget);
        });
    });

    group('UC20 — Finish shopping session', () {
        late AppState appState;
        late FakeFirebaseFirestore fakeFirestore;
        late MockUser mockUser;

        setUp(() {
            fakeFirestore = FakeFirebaseFirestore();
            appState = AppState(db: fakeFirestore);
            mockUser = MockUser();

            appState.updateUser(mockUser);
        });

        test('test_uc20_checkout_clears_basket_but_retains_benefit_usage', () async {
            // ARRANGE
            appState.addItem(
            upc: '11111',
            name: 'Milk',
            category: 'MILK',
            );

            appState.incrementItem('11111', 'MILK');

            expect(appState.basket.first['qty'], 2);
            expect(appState.balances['MILK']!['used'], 2);

            // ACT
            await appState.checkout();

            // ASSERT
            expect(appState.basket, isEmpty);
            expect(appState.balances['MILK']!['used'], 2);
        });
    });
}