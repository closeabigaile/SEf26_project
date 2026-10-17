// Drives the real app (real Firebase project wolfbyte-proj1) on a desktop
// build, the way a shopper would, and saves a screenshot of each step.
//
//   flutter test integration_test/live_app_test.dart -d windows
//
// Credentials come from a JSON file outside the repo, {"email", "password"}:
// WOLFBITE_E2E_CREDS, else %USERPROFILE%\.wolfbite_e2e.json. Never committed.
// Screenshots go to WOLFBITE_E2E_SHOTS (default build/e2e_screenshots).
//
// The account's users/{uid} document is backed up before the app loads it
// and restored exactly afterwards, even if a step fails.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wolfbite/firebase_options.dart';
import 'package:wolfbite/main.dart';

/// A real NC APL product (General Mills Cheerios).
const _upc = String.fromEnvironment('E2E_UPC', defaultValue: '016000224698');

Map<String, String> _credentials() {
  final path =
      Platform.environment['WOLFBITE_E2E_CREDS'] ??
      '${Platform.environment['USERPROFILE'] ?? Platform.environment['HOME']}'
          '${Platform.pathSeparator}.wolfbite_e2e.json';
  final file = File(path);
  if (!file.existsSync()) {
    throw StateError('Missing credentials file $path ({"email", "password"})');
  }
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return {'email': json['email'] as String, 'password': json['password'] as String};
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final shotsDir = Directory(
    Platform.environment['WOLFBITE_E2E_SHOTS'] ?? 'build/e2e_screenshots',
  )..createSync(recursive: true);
  var shotIndex = 0;

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    final view = binding.renderViews.first;
    final layer = view.debugLayer! as OffsetLayer;
    final image = await layer.toImage(view.paintBounds);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    shotIndex++;
    final file = File(
      '${shotsDir.path}/${shotIndex.toString().padLeft(2, '0')}_$name.png',
    );
    file.writeAsBytesSync(png!.buffer.asUint8List());
  }

  /// Pumps until [finder] matches or [timeout] passes (network-backed steps).
  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isNotEmpty) return;
    }
    throw TestFailure('Timed out waiting for $finder');
  }

  testWidgets('live: sign in, scan, basket, nutrition, M2 balance, help, benefits', (
    tester,
  ) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;
    final creds = _credentials();

    // Back up users/{uid} before AppState can touch it (monthly reset etc.).
    final signedIn = await auth.signInWithEmailAndPassword(
      email: creds['email']!,
      password: creds['password']!,
    );
    final userDoc = db.collection('users').doc(signedIn.user!.uid);
    final backup = (await userDoc.get()).data();
    addTearDown(() async {
      if (auth.currentUser == null) {
        await auth.signInWithEmailAndPassword(
          email: creds['email']!,
          password: creds['password']!,
        );
      }
      if (backup == null) {
        await userDoc.delete();
      } else {
        await userDoc.set(backup);
      }
      await auth.signOut();
    });
    await auth.signOut();

    await tester.pumpWidget(const MyApp());
    await waitFor(tester, find.text('Sign In'));
    await shot(tester, 'login');

    await tester.enterText(find.widgetWithText(TextField, 'Email'), creds['email']!);
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      creds['password']!,
    );
    await tester.tap(find.text('Sign In'));
    await waitFor(tester, find.widgetWithText(TextField, 'UPC Code'));
    await shot(tester, 'scan');

    await tester.enterText(find.widgetWithText(TextField, 'UPC Code'), _upc);
    await tester.tap(find.text('Check'));
    final add = find.widgetWithText(FilledButton, 'Add');
    await waitFor(tester, add);
    await shot(tester, 'lookup');

    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pump(const Duration(seconds: 1));
    await shot(tester, 'added');

    await tester.tap(find.text('Cart'));
    await waitFor(tester, find.text('Check basket balance'));
    await shot(tester, 'basket');

    final toggle = find.text('Show Nutritional Info').first;
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await shot(tester, 'nutrition');

    final balance = find.text('Check basket balance');
    await tester.ensureVisible(balance);
    await tester.tap(balance);
    await waitFor(tester, find.text('Basket balance'));
    await tester.pump(const Duration(seconds: 3));
    await shot(tester, 'basket_balance');
    // Dismiss the sheet by tapping above it.
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    final help = find.text('Get checkout help');
    if (help.evaluate().isNotEmpty) {
      await tester.ensureVisible(help.first);
      await tester.tap(help.first);
      await tester.pumpAndSettle();
      await shot(tester, 'checkout_help');
      final close = find.text('Close');
      if (close.evaluate().isNotEmpty) {
        await tester.tap(close.first);
        await tester.pumpAndSettle();
      }
    }

    await tester.tap(find.text('Benefits'));
    await tester.pump(const Duration(seconds: 2));
    await shot(tester, 'benefits');
  });
}
