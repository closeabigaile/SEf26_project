// AppState fixes that M2 depends on: legacy all-zero nutrition and category
// spelling variants.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wolfbite/state/app_state.dart';

class _User extends Mock implements User {
  @override
  String get uid => 'shopper';
}

Future<AppState> _load(
  FakeFirebaseFirestore db,
  Map<String, dynamic> doc,
) async {
  await db.collection('users').doc('shopper').set({
    ...doc,
    'updatedAt': Timestamp.now(),
  });
  final state = AppState(db: db);
  final loaded = Completer<void>();
  void onChange() {
    if (state.balancesLoaded && !loaded.isCompleted) loaded.complete();
  }

  state.addListener(onChange);
  state.updateUser(_User());
  await loaded.future;
  state.removeListener(onChange);
  return state;
}

const _zeros = {
  'calories': 0,
  'totalFat': 0,
  'saturatedFat': 0,
  'transFat': 0,
  'sodium': 0,
  'sugar': 0,
  'addedSugar': 0,
  'protein': 0,
  'fiber': 0,
  'wicEligible': true,
};

void main() {
  test('the old all-zero nutrition placeholder loads as unknown', () async {
    final state = await _load(FakeFirebaseFirestore(), {
      'basket': [
        {
          'upc': '1',
          'name': 'Legacy',
          'category': 'LEGUMES',
          'qty': 1,
          'nutrition': _zeros,
        },
      ],
      'balances': {
        'LEGUMES': {'allowed': 2, 'used': 1},
      },
    });
    final nutrition = state.basket.single['nutrition'] as Map;
    expect(nutrition['sodium'], isNull);
    expect(nutrition['calories'], isNull);
  });

  test('a real measurement with some zeros is kept', () async {
    final state = await _load(FakeFirebaseFirestore(), {
      'basket': [
        {
          'upc': '1',
          'name': 'Milk',
          'category': 'MILK - WHOLE',
          'qty': 1,
          'nutrition': {..._zeros, 'calories': 150, 'sodium': 105},
        },
      ],
      'balances': {
        'MILK - WHOLE': {'allowed': 3, 'used': 1},
      },
    });
    final nutrition = state.basket.single['nutrition'] as Map;
    expect(nutrition['sodium'], 105);
    expect(nutrition['fiber'], 0);
  });

  test('balances saved under spelling variants merge on load', () async {
    final state = await _load(FakeFirebaseFirestore(), {
      'basket': [
        {'upc': '1', 'name': 'A', 'category': 'MILK-WHOLE', 'qty': 1},
        {'upc': '2', 'name': 'B', 'category': 'MILK - WHOLE', 'qty': 1},
      ],
      'balances': {
        'MILK-WHOLE': {'allowed': 3, 'used': 1},
        'MILK - WHOLE': {'allowed': 3, 'used': 1},
      },
    });
    expect(state.balances.keys, ['MILK - WHOLE']);
    expect(state.balances['MILK - WHOLE'], {'allowed': 3, 'used': 2});
    expect(state.basket.map((l) => l['category']).toSet(), {'MILK - WHOLE'});
  });

  test('items added under different spellings share one allowance', () async {
    final state = await _load(FakeFirebaseFirestore(), {});
    expect(
      state.addItem(upc: '1', name: 'A', category: 'MILK-FAT REDUCED'),
      isTrue,
    );
    expect(
      state.addItem(upc: '2', name: 'B', category: 'MILK - FAT REDUCED'),
      isTrue,
    );
    expect(state.balances.keys, ['MILK - FAT REDUCED']);
    expect(state.balances['MILK - FAT REDUCED']!['used'], 2);
  });
}
