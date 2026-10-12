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
import 'package:wolfbite/screens/checkout_help_samples_screen.dart';
import 'package:wolfbite/services/checkout_help_repository.dart';
import 'package:wolfbite/state/app_state.dart';

class _User extends Mock implements User {
  @override
  String get uid => 'checkout-help-test';
}

/// Observe calls, but retain the real state behavior. A mistaken reload can
/// still reset old-month data, and a mistaken checkout can still clear items.
class _ObservedState extends AppState {
  _ObservedState(FakeFirebaseFirestore db) : super(db: db);
  int checkoutCalls = 0;
  int loadCalls = 0;
  int clearCalls = 0;

  @override
  Future<void> checkout() {
    checkoutCalls++;
    return super.checkout();
  }

  @override
  Future<void> loadUserState() {
    loadCalls++;
    return super.loadUserState();
  }

  @override
  void clearBasket() {
    clearCalls++;
    super.clearBasket();
  }

  void changed() => notifyListeners();
}

class _DelayedBundle extends CachingAssetBundle {
  final completion = Completer<ByteData>();
  @override
  Future<ByteData> load(String key) => completion.future;
}

/// Supply conflicting evidence through the real repository, not a fake answer.
class _EvidenceBundle extends CachingAssetBundle {
  _EvidenceBundle(this.text);
  final String text;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(text)));
}

String _fixtureText() =>
    File('assets/mock/checkout_help_scenarios.json').readAsStringSync();
Map<String, dynamic> _fixture(String id) =>
    (jsonDecode(_fixtureText())['scenarios'] as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((entry) => entry['scenario_id'] == id);

Map<String, dynamic> _sampleLine(String id) {
  final item = _fixture(id)['input']['item'];
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

void main() {
  late FakeFirebaseFirestore database;
  late _ObservedState state;

  // Each widget test uses its own fake clock/zone. Do not reuse an asset Future
  // cached by a previous test's zone, which can leave a loading view pending.
  setUp(rootBundle.clear);

  Future<void> loadState(List<Map<String, dynamic>> lines) async {
    database = FakeFirebaseFirestore();
    await database.collection('users').doc('checkout-help-test').set({
      'basket': lines,
      'balances': {
        'CEREAL': {'allowed': 2, 'used': 1},
        'PAID': {'allowed': null, 'used': 1},
      },
      'updatedAt': Timestamp.now(),
    });
    state = _ObservedState(database);
    addTearDown(state.dispose);
    final loaded = Completer<void>();
    void onLoad() {
      if (state.balancesLoaded && !loaded.isCompleted) loaded.complete();
    }

    state.addListener(onLoad);
    state.updateUser(_User());
    await loaded.future;
    state.removeListener(onLoad);
    state.loadCalls = 0;
    // A help implementation that unnecessarily reloads user data would now
    // trigger the real monthly reset. None of the help paths should do so.
    final now = DateTime.now();
    await database.collection('users').doc('checkout-help-test').update({
      'updatedAt': Timestamp.fromDate(DateTime(now.year, now.month - 1, 1)),
    });
  }

  String snapshot() =>
      jsonEncode({'basket': state.basket, 'balances': state.balances});
  Future<Map<String, dynamic>?> saved() async =>
      (await database.collection('users').doc('checkout-help-test').get())
          .data();

  Future<void> pumpBasket(
    WidgetTester tester, {
    CheckoutHelpRepository repository = const CheckoutHelpRepository(),
  }) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: BasketScreen(checkoutHelpRepository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openHelp(
    WidgetTester tester,
    String name, {
    bool settle = true,
  }) async {
    final card = find.ancestor(
      of: find.text(name),
      matching: find.byType(Card),
    );
    final action = find.descendant(
      of: card,
      matching: find.text('Get checkout help'),
    );
    await tester.ensureVisible(action);
    await tester.pump(); // Lay out the new scroll position before tapping.
    await tester.tap(action);
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  void expectAnswer(String id) {
    final expected = _fixture(id)['expected_help'];
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(expected['explanation']),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(expected['suggested_next_step']),
      ),
      findsOneWidget,
    );
    expect(expected['explanation'], contains("checkout system's official"));
    expect(
      find.text('This is guidance, not an official checkout decision.'),
      findsOneWidget,
    );
  }

  void expectNoStateOperations() {
    expect(state.checkoutCalls, 0);
    expect(state.loadCalls, 0);
    expect(state.clearCalls, 0);
  }

  for (final id in ['M0-M4-01', 'M0-M4-02', 'M0-M4-03', 'M0-M4-F01']) {
    testWidgets(
      '$id opens selected-item help and closes without state or database changes',
      (tester) async {
        final line = _sampleLine(id);
        await loadState([
          line,
          {
            'upc': 'other',
            'name': 'Other item',
            'category': 'CEREAL',
            'qty': 2,
          },
        ]);
        final before = snapshot();
        final storedBefore = await saved();
        await pumpBasket(tester);
        await openHelp(tester, line['name'] as String);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('checkout-help-item')))
              .data,
          line['name'],
        );
        expect(find.textContaining('Synthetic example:'), findsOneWidget);
        expectAnswer(id);
        expect(snapshot(), before);
        await tester.tap(find.widgetWithText(TextButton, 'Close'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('My Basket'), findsOneWidget);
        expect(snapshot(), before);
        expect(await saved(), storedBefore);
        expectNoStateOperations();
      },
    );
  }

  testWidgets('repeated openings on different items do not leak explanations', (
    tester,
  ) async {
    final first = _sampleLine('M0-M4-01');
    final second = _sampleLine('M0-M4-02');
    await loadState([first, second]);
    final before = snapshot();
    await pumpBasket(tester);
    for (final id in ['M0-M4-01', 'M0-M4-02', 'M0-M4-01']) {
      await openHelp(tester, _fixture(id)['input']['item']['name'] as String);
      expectAnswer(id);
      await tester.tap(find.widgetWithText(TextButton, 'Close'));
      await tester.pumpAndSettle();
    }
    expect(snapshot(), before);
    expectNoStateOperations();
  });

  testWidgets(
    'a real item sharing a sample UPC receives fallback without explicit sample linkage',
    (tester) async {
      final line = _sampleLine('M0-M4-01')..remove('checkout_help_source');
      await loadState([line]);
      await pumpBasket(tester);
      await openHelp(tester, line['name'] as String);
      expectAnswer('M0-M4-F01');
      expect(find.textContaining('Synthetic example:'), findsNothing);
    },
  );

  testWidgets(
    'a paid line sharing a UPC cannot inherit another lines sample evidence',
    (tester) async {
      final first = _sampleLine('M0-M4-01');
      final second = {...first, 'name': 'Paid copy', 'category': 'PAID'};
      await loadState([first, second]);
      await pumpBasket(tester);
      await openHelp(tester, 'Paid copy');
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('checkout-help-item')))
            .data,
        'Paid copy',
      );
      expectAnswer('M0-M4-F01');
    },
  );

  testWidgets(
    'balance changes invalidate an open explanation without undoing the change',
    (tester) async {
      final line = _sampleLine('M0-M4-01');
      await loadState([line]);
      await pumpBasket(tester);
      await openHelp(tester, line['name'] as String);
      expectAnswer('M0-M4-01');
      state.balances['CEREAL']!['used'] = 2;
      state.changed();
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Your basket or benefit information changed.'),
        findsOneWidget,
      );
      expectAnswer('M0-M4-F01');
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(state.balances['CEREAL']!['used'], 2);
      expectNoStateOperations();
    },
  );

  testWidgets(
    'removing the selected line does not switch help to the next item',
    (tester) async {
      final first = _sampleLine('M0-M4-01');
      await loadState([first, _sampleLine('M0-M4-02')]);
      await pumpBasket(tester);
      await openHelp(tester, first['name'] as String);
      state.basket.removeAt(0);
      state.changed();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('checkout-help-item')))
            .data,
        first['name'],
      );
      expectAnswer('M0-M4-F01');
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(state.basket.single['upc'], _sampleLine('M0-M4-02')['upc']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a changed quantity cannot reuse the original prepared evidence after reopening',
    (tester) async {
      final line = _sampleLine('M0-M4-01');
      await loadState([line]);
      state.basket.single['qty'] = 2;
      await pumpBasket(tester);
      await openHelp(tester, line['name'] as String);
      expectAnswer('M0-M4-F01');
    },
  );

  testWidgets(
    'a delayed load cannot show evidence for an item changed while loading',
    (tester) async {
      final line = _sampleLine('M0-M4-01');
      final bundle = _DelayedBundle();
      await loadState([line]);
      await pumpBasket(
        tester,
        repository: CheckoutHelpRepository(bundle: bundle),
      );
      await openHelp(tester, line['name'] as String, settle: false);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      state.basket.single['qty'] = 2;
      state.changed();
      bundle.completion.complete(
        ByteData.sublistView(Uint8List.fromList(utf8.encode(_fixtureText()))),
      );
      await tester.pumpAndSettle();
      expectAnswer('M0-M4-F01');
      expect(
        find.textContaining('Your basket or benefit information changed.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('load failure offers uncertainty and can still be closed', (
    tester,
  ) async {
    final line = _sampleLine('M0-M4-01');
    final bundle = _DelayedBundle();
    await loadState([line]);
    final before = snapshot();
    await pumpBasket(
      tester,
      repository: CheckoutHelpRepository(bundle: bundle),
    );
    await openHelp(tester, line['name'] as String, settle: false);
    bundle.completion.completeError(StateError('Unavailable asset'));
    await tester.pumpAndSettle();
    expectAnswer('M0-M4-F01');
    expect(find.textContaining('could not be loaded'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(snapshot(), before);
    expect(tester.takeException(), isNull);
  });

  testWidgets('back and outside-tap dismissals preserve state', (tester) async {
    final line = _sampleLine('M0-M4-01');
    await loadState([line]);
    final before = snapshot();
    await pumpBasket(tester);
    await openHelp(tester, line['name'] as String);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await openHelp(tester, line['name'] as String);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(snapshot(), before);
    expectNoStateOperations();
  });

  for (final problem in ['ambiguous causes', 'conflicting categories']) {
    testWidgets('$problem display closable fallback through the basket', (
      tester,
    ) async {
      final data = jsonDecode(_fixtureText());
      final benefit = (data['scenarios'] as List).singleWhere(
        (entry) => entry['scenario_id'] == 'M0-M4-01',
      )['input']['benefit'];
      if (problem == 'ambiguous causes') {
        // Both a size mismatch and a shortfall: neither can be singled out.
        benefit['available_units_after_other_allocations'] = 0;
      } else {
        benefit['category'] = 'MILK';
      }
      final line = _sampleLine('M0-M4-01');
      await loadState([line]);
      final before = snapshot();
      await pumpBasket(
        tester,
        repository: CheckoutHelpRepository(
          bundle: _EvidenceBundle(jsonEncode(data)),
        ),
      );
      await openHelp(tester, line['name'] as String);
      expect(find.text('Unable to determine the cause'), findsOneWidget);
      expectAnswer('M0-M4-F01');
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(snapshot(), before);
      expect(find.text('My Basket'), findsOneWidget);
      expectNoStateOperations();
    });
  }

  testWidgets(
    'sample basket opens per-item help for all scenarios without changing either basket',
    (tester) async {
      await loadState([
        {
          'upc': 'real',
          'name': 'My actual item',
          'category': 'CEREAL',
          'qty': 1,
        },
      ]);
      final before = snapshot();
      final storedBefore = await saved();
      await pumpBasket(tester);
      await tester.tap(find.byTooltip('Try sample checkout help'));
      await tester.pumpAndSettle();
      expect(find.text('Sample basket'), findsOneWidget);
      for (final id in ['M0-M4-01', 'M0-M4-02', 'M0-M4-03', 'M0-M4-F01']) {
        final card = find.byKey(ValueKey('sample-basket-item-$id'));
        await tester.scrollUntilVisible(card, 160);
        final beforeCard = tester
            .widgetList<Text>(
              find.descendant(of: card, matching: find.byType(Text)),
            )
            .map((text) => text.data)
            .toList();
        final name = _fixture(id)['input']['item']['name'] as String;
        await openHelp(tester, name);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('checkout-help-item')))
              .data,
          name,
        );
        expectAnswer(id);
        expect(find.textContaining('Synthetic example:'), findsOneWidget);
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Sample basket'), findsOneWidget);
        expect(
          tester
              .widgetList<Text>(
                find.descendant(of: card, matching: find.byType(Text)),
              )
              .map((text) => text.data)
              .toList(),
          beforeCard,
        );
        expect(snapshot(), before);
      }
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(snapshot(), before);
      expect(await saved(), storedBefore);
      expectNoStateOperations();
    },
  );

  testWidgets('rapid repeated help taps open only one dialog', (tester) async {
    final line = _sampleLine('M0-M4-01');
    await loadState([line]);
    await pumpBasket(tester);
    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Get checkout help'),
    );
    // Two taps can arrive before the button rebuilds in its disabled state.
    button.onPressed!();
    button.onPressed!();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog, skipOffstage: false), findsNothing);
    expect(find.text('My Basket'), findsOneWidget);
    expectNoStateOperations();
  });

  testWidgets('help remains scrollable and closable on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final line = _sampleLine('M0-M4-02');
    await loadState([line]);
    await pumpBasket(tester);
    await openHelp(tester, line['name'] as String);
    expectAnswer('M0-M4-02');
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('sample basket help works with large text on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutHelpSamplesScreen()),
    );
    await tester.pumpAndSettle();
    // Large text pushes the first item below the introductory instructions.
    // Scroll like a shopper so ListView builds it before looking for its button.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('sample-basket-item-M0-M4-01')),
      160,
    );
    await openHelp(tester, _fixture('M0-M4-01')['input']['item']['name']);
    expectAnswer('M0-M4-01');
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Sample basket'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'original category survives creating and reloading a paid line',
    () async {
      await loadState([
        {'upc': 'real', 'name': 'Cereal', 'category': 'CEREAL', 'qty': 1},
      ]);
      state.balances['CEREAL'] = {'allowed': 1, 'used': 1};
      state.incrementItem('real', 'CEREAL');
      await Future<void>.delayed(Duration.zero);
      final paid = state.basket.singleWhere(
        (line) => line['category'] == 'PAID',
      );
      expect(paid['original_benefit_category'], 'CEREAL');
      await state.loadUserState();
      expect(
        state.basket.singleWhere(
          (line) => line['category'] == 'PAID',
        )['original_benefit_category'],
        'CEREAL',
      );
    },
  );
}
