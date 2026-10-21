import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:wolfbite/screens/qr_checkout_screen.dart';
import 'package:wolfbite/state/app_state.dart';

class TestAppState extends AppState {
  TestAppState() : super(db: FakeFirebaseFirestore());

  void tick() => notifyListeners();

  @override
  Future<void> checkout() async {
    balances.forEach((_, v) => v['used'] = 0);
    basket.clear();
    notifyListeners();
  }
}

Widget _app({required AppState app}) {
  return ChangeNotifierProvider.value(
    value: app,
    child: const MaterialApp(home: QRCheckoutScreen()),
  );
}

void main() {
  group('QRCheckoutScreen', () {
    testWidgets('renders QR code using basket JSON', (tester) async {
      final app = TestAppState();

      app.basket.add({
        'upc': '111',
        'name': 'Test Milk',
        'category': 'MILK',
        'qty': 1,
      });
      app.tick();

      await tester.pumpWidget(_app(app: app));
      await tester.pumpAndSettle();

      expect(find.byType(QrImageView), findsOneWidget);
    });
  });
}
