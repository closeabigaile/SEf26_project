import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wolfbite/screens/basket_screen.dart';
import 'package:wolfbite/state/app_state.dart';

void main() {
  testWidgets('A09 intended basket item exposes Get checkout help', (
    tester,
  ) async {
    // Exercise the real basket widget and state. These are display records in
    // the existing basket format, not a made-up implementation of the help UI.
    final state = AppState(db: FakeFirebaseFirestore());
    addTearDown(state.dispose);
    state.balances.addAll({
      'CEREAL': {'allowed': 2, 'used': 1},
      'PAID': {'allowed': null, 'used': 1},
    });
    state.basket.addAll([
      {
        'upc': 'mock-size',
        'name': 'Size case cereal',
        'category': 'CEREAL',
        'qty': 1,
      },
      {
        'upc': 'mock-balance',
        'name': 'Balance case cereal',
        'category': 'PAID',
        'qty': 1,
      },
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: BasketScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Size case cereal'), findsOneWidget);
    expect(find.text('Balance case cereal'), findsOneWidget);

    final intendedCard = find.ancestor(
      of: find.text('Size case cereal'),
      matching: find.byType(Card),
    );
    expect(intendedCard, findsOneWidget);
    expect(
      find.descendant(
        of: intendedCard,
        matching: find.text('Get checkout help'),
      ),
      findsOneWidget,
      reason:
          'Issue 3 must provide an item-specific help action before the '
          'open, selected-item, close, and state-preservation flow can be tested.',
    );
    // Full open/close, selected-item, and state-preservation checks are in
    // test/screens/checkout_help_screen_test.dart. Keep this focused check as
    // the regression test for the originally missing per-item entry point.
  });
}
