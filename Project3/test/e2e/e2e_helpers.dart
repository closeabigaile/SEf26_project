// Helpers shared by the end-to-end tests so the same tests run both in the
// test VM (fake async) and on a device/desktop build (real time), where
// Firestore lookups and focus changes take real time.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps until [finder] matches, letting real async work (fake Firestore
/// futures) run between frames. Fails after about [maxTries] rounds.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  int maxTries = 60,
}) async {
  for (var i = 0; i < maxTries && finder.evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsWidgets);
  await tester.pumpAndSettle();
}

/// Focuses the scan screen's UPC field and types [upc]. Tapping first matters
/// on desktop, where the field loses focus after the screen clears it.
Future<void> enterUpc(WidgetTester tester, String upc) async {
  final field = find.widgetWithText(TextField, 'UPC Code');
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pump();
  await tester.enterText(field, upc);
  await tester.pump();
  expect(find.text(upc), findsWidgets);
}
