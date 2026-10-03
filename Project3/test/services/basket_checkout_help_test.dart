import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wolfbite/services/apl_service.dart';
import 'package:wolfbite/services/basket_checkout_help.dart';

class _UnavailableCatalog extends AplService {
  _UnavailableCatalog() : super(db: FakeFirebaseFirestore());
  @override
  Future<Map<String, dynamic>?> findByUpc(String upc) async =>
      throw StateError('offline');
}

void main() {
  test(
    'an included item at the limit is valid, but inconsistent allocations are not',
    () {
      final line = <String, dynamic>{'category': 'JUICE 64', 'qty': 1};
      for (final used in [0, 1, 2]) {
        final result = BasketCheckoutHelp.explainIncluded(
          line: line,
          basket: [line],
          balances: {
            'JUICE 64': {'allowed': 1, 'used': used},
          },
        );
        expect(
          result.possibleCause,
          used == 1 ? 'app_included' : 'app_balance_unknown',
        );
      }
      final missing = BasketCheckoutHelp.explainIncluded(
        line: line,
        basket: [line],
        balances: {},
      );
      expect(missing.possibleCause, 'app_balance_unknown');
      final overflow = BasketCheckoutHelp.explainIncluded(
        line: line,
        basket: [line, line],
        balances: {
          'JUICE 64': {'allowed': 1, 'used': 1},
        },
      );
      expect(overflow.possibleCause, 'app_balance_unknown');
    },
  );
  test(
    'a full juice allowance explains self payment and replacement limits',
    () {
      final answer = BasketCheckoutHelp.explain(
        originalCategory: 'JUICE 64',
        balances: {
          'JUICE 64': {'allowed': 1, 'used': 1},
        },
      );
      expect(answer.possibleCause, 'app_category_limit');
      expect(answer.explanation, contains('1 of 1'));
      expect(answer.explanation, contains('you have not paid yet'));
      expect(
        answer.suggestedNextStep,
        contains('will not increase the allowance'),
      );
    },
  );

  test(
    'missing, uncapped or freed allowances do not claim a full category',
    () {
      for (final balance in [
        {},
        {'allowed': null, 'used': 1},
        {'allowed': 1, 'used': 0},
        {'allowed': -1, 'used': 0},
      ]) {
        final answer = BasketCheckoutHelp.explain(
          originalCategory: 'JUICE 64',
          balances: {'JUICE 64': Map<String, dynamic>.from(balance)},
        );
        expect(answer.possibleCause, 'app_paid_item');
        expect(answer.explanation, isNot(contains('already used')));
      }
    },
  );

  test('legacy paid category resolves only by exact UPC or saved source', () {
    final line = {'upc': '001', 'category': 'PAID'};
    expect(
      BasketCheckoutHelp.originalCategory(line, [
        {'upc': '001', 'category': 'JUICE 64'},
        {'upc': '002', 'category': 'MILK'},
      ]),
      'JUICE 64',
    );
    expect(
      BasketCheckoutHelp.originalCategory(line, [
        {'upc': '002', 'category': 'JUICE 64'},
      ]),
      isNull,
    );
  });

  test('legacy category lookup reads only the selected product', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('apl').doc('juice').set({
      'name': 'APPLE JUICE',
      'category': 'JUICE 64',
      'eligible': true,
    });
    final catalog = AplService(db: db);
    expect(
      await BasketCheckoutHelp.resolveOriginalCategory(catalog, {
        'upc': 'juice',
      }, null),
      'JUICE 64',
    );
    expect(
      await BasketCheckoutHelp.resolveOriginalCategory(catalog, {
        'upc': 'missing',
      }, null),
      isNull,
    );
    await db.collection('apl').doc('juice').update({'eligible': false});
    expect(
      await BasketCheckoutHelp.resolveOriginalCategory(catalog, {
        'upc': 'juice',
      }, null),
      isNull,
    );
  });

  test(
    'saved category needs no lookup, and failed legacy lookup stays unknown',
    () async {
      final catalog = _UnavailableCatalog();
      expect(
        await BasketCheckoutHelp.resolveOriginalCategory(catalog, {
          'upc': 'juice',
        }, 'JUICE 64'),
        'JUICE 64',
      );
      expect(
        await BasketCheckoutHelp.resolveOriginalCategory(catalog, {
          'upc': 'juice',
        }, null),
        isNull,
      );
    },
  );
}
