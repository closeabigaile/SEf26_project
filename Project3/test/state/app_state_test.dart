import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wolfbite/state/app_state.dart';

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid';
}

void main() {
  group('AppState', () {
    late AppState appState;
    late FakeFirebaseFirestore fakeFirestore;
    late MockUser mockUser;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      appState = AppState(db: fakeFirestore);
      mockUser = MockUser();
    });

    test('updateUser loads user data when logged in', () async {
      await fakeFirestore.collection('users').doc('test-uid').set({
        'balances': {
          'MILK': {'allowed': 3, 'used': 1},
        },
        'basket': [
          {'upc': '12345', 'name': 'Milk', 'category': 'MILK', 'qty': 1},
        ],
      });

      appState.updateUser(mockUser);

      await Future.delayed(Duration.zero); // allow async operations to complete

      expect(appState.balancesLoaded, isTrue);
      expect(appState.balances['MILK']!['used'], 1);
      expect(appState.basket.first['upc'], '12345');
    });

  });
}
