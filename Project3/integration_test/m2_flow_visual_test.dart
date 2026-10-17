// M2 flow rendered for real on a desktop build, with screenshots, against a
// fake Firestore seeded from test/fixtures/m2_real_sample.json (real APL
// records + Open Food Facts nutrition). No live Firebase access.
//
//   flutter test integration_test/m2_flow_visual_test.dart -d windows
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wolfbite/screens/basket_screen.dart';
import 'package:wolfbite/screens/scan_screen.dart';
import 'package:wolfbite/services/apl_service.dart';
import 'package:wolfbite/state/app_state.dart';

class _User extends Mock implements User {
  @override
  String get uid => 'visual-shopper';
}

class _Auth extends Mock implements FirebaseAuth {}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final shotsDir = Directory(
    Platform.environment['WOLFBITE_E2E_SHOTS'] ?? 'build/e2e_screenshots',
  )..createSync(recursive: true);
  var shotIndex = 0;

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    final view = binding.renderViews.first;
    final image = await (view.debugLayer! as OffsetLayer).toImage(view.paintBounds);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    shotIndex++;
    File(
      '${shotsDir.path}/m2_${shotIndex.toString().padLeft(2, '0')}_$name.png',
    ).writeAsBytesSync(png!.buffer.asUint8List());
  }

  testWidgets('M2 visual: scan two real products, balance, swap', (tester) async {
    final fixture =
        jsonDecode(File('test/fixtures/m2_real_sample.json').readAsStringSync())
            as Map<String, dynamic>;
    final db = FakeFirebaseFirestore();
    for (final d in (fixture['apl'] as List).cast<Map<String, dynamic>>()) {
      await db.collection('apl').doc(d['upc'] as String).set(d);
    }
    for (final d in (fixture['nutrition'] as List).cast<Map<String, dynamic>>()) {
      await db.collection('nutrition').doc(d['upc'] as String).set(d);
    }
    await db.collection('users').doc('visual-shopper').set({
      'basket': [],
      'balances': {},
      'updatedAt': Timestamp.now(),
    });

    final state = AppState(db: db);
    final loaded = Completer<void>();
    state.addListener(() {
      if (state.balancesLoaded && !loaded.isCompleted) loaded.complete();
    });
    state.updateUser(_User());
    await loaded.future;

    final apl = AplService(db: db);
    final router = GoRouter(
      initialLocation: '/scan',
      routes: [
        GoRoute(
          path: '/scan',
          builder: (_, _) => ScanScreen(aplService: apl, auth: _Auth()),
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

    /// Pumps until [finder] matches: lookups take real time on a device.
    Future<void> waitFor(Finder finder) async {
      for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      if (finder.evaluate().isEmpty) await shot(tester, 'FAILED_waiting');
      expect(finder, findsWidgets);
    }

    Future<void> scan(String upc, String name) async {
      final field = find.byType(TextField).first;
      await tester.tap(field);
      await tester.pumpAndSettle();
      await tester.enterText(field, upc);
      await tester.pumpAndSettle();
      if (find.text(upc).evaluate().isEmpty) await shot(tester, 'FAILED_typing');
      expect(find.text(upc), findsWidgets);
      await tester.tap(find.text('Check'));
      await waitFor(find.text(name));
      await tester.pumpAndSettle();
    }

    await scan('070253640353', 'OUR FAMILY NONFAT YOGURT VANILLA 32 OZ');
    await shot(tester, 'scanned_yogurt');
    final add = find.widgetWithText(FilledButton, 'Add');
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();

    await scan('011110810106', 'KROGER LIVING WELL WHOLE GRAIN OAT CEREAL');
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();

    router.go('/basket');
    await tester.pumpAndSettle();
    await shot(tester, 'basket');

    await tester.tap(find.text('Show Nutritional Info').first);
    await shot(tester, 'nutrition_panel');

    final balance = find.text('Check basket balance');
    await tester.ensureVisible(balance);
    await tester.tap(balance);
    await waitFor(find.textContaining('CHOBANI LOW-FAT PLAIN GREEK YOGURT'));
    await shot(tester, 'balance_sheet');

    await tester.tap(find.text('Confirm swap').first);
    await tester.pumpAndSettle();
    await shot(tester, 'after_swap');

    expect(
      state.basket.map((l) => l['upc']),
      containsAll(['894700010199', '011110810106']),
    );
  });
}
