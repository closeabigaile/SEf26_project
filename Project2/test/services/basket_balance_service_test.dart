// M2 completion criteria (Project1b_Work/analysis/design_decisions.md):
// basket-dependent ranking, quantity effects, unchanged previews, confirmed
// swaps, recalculation, missing data, balance consistency, no-candidate cases.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wolfbite/services/basket_balance_service.dart';
import 'package:wolfbite/utils/nutritional_utils.dart';

const service = BasketBalanceService();

Map<String, dynamic> nutrition({num? sodium, num? addedSugar, num? fiber}) => {
  ...NutritionalUtils.unknownNutrition,
  'sodium': sodium,
  'addedSugar': addedSugar,
  'fiber': fiber,
};

Map<String, dynamic> line(
  String upc,
  String category, {
  int qty = 1,
  num? sodium,
  num? addedSugar,
  num? fiber,
}) => {
  'upc': upc,
  'name': 'Item $upc',
  'category': category,
  'qty': qty,
  'nutrition': nutrition(sodium: sodium, addedSugar: addedSugar, fiber: fiber),
};

Map<String, dynamic> candidate(
  String upc,
  String category, {
  bool eligible = true,
  num? sodium,
  num? addedSugar,
  num? fiber,
}) => {
  'upc': upc,
  'name': 'Candidate $upc',
  'category': category,
  'eligible': eligible,
  'nutrition': nutrition(sodium: sodium, addedSugar: addedSugar, fiber: fiber),
};

/// Balances that agree with [basket]: used == allocated, uncapped.
Map<String, Map<String, dynamic>> balancesFor(
  List<Map<String, dynamic>> basket,
) {
  final out = <String, Map<String, dynamic>>{};
  for (final l in basket) {
    final cat = l['category'] as String;
    out.putIfAbsent(cat, () => {'allowed': null, 'used': 0});
    out[cat]!['used'] = (out[cat]!['used'] as int) + (l['qty'] as int);
  }
  return out;
}

BasketBalanceReport analyze(
  List<Map<String, dynamic>> basket,
  Map<String, List<Map<String, dynamic>>> candidates, {
  Map<String, Map<String, dynamic>>? balances,
}) => service.analyze(
  basket: basket,
  balances: balances ?? balancesFor(basket),
  candidatesByCategory: candidates,
);

void main() {
  // Cereal X is high in both sodium and added sugar.
  Map<String, dynamic> cerealX() =>
      line('X', 'CEREAL', sodium: 300, addedSugar: 24, fiber: 3);
  final cerealCandidates = {
    'CEREAL': [
      candidate('LOW-SUGAR', 'CEREAL', sodium: 320, addedSugar: 2, fiber: 3),
      candidate('LOW-SODIUM', 'CEREAL', sodium: 50, addedSugar: 24, fiber: 3),
    ],
  };

  group('basket-dependent ranking', () {
    test('the same item gets a different swap in a different basket', () {
      // Salty soup makes sodium the basket's largest gap.
      final salty = analyze([
        cerealX(),
        line('SOUP', 'SOUP', sodium: 900, addedSugar: 0, fiber: 3),
      ], cerealCandidates);
      expect(salty.focus!.key, 'sodium');
      expect(salty.suggestions.single.toUpc, 'LOW-SODIUM');

      // Plain rice leaves added sugar as the largest gap.
      final sweet = analyze([
        cerealX(),
        line('RICE', 'RICE', sodium: 0, addedSugar: 0, fiber: 3),
      ], cerealCandidates);
      expect(sweet.focus!.key, 'addedSugar');
      expect(sweet.suggestions.single.toUpc, 'LOW-SUGAR');
    });

    test('a candidate that worsens the focus nutrient is not offered', () {
      final report = analyze([
        cerealX(),
        line('SOUP', 'SOUP', sodium: 900, addedSugar: 0, fiber: 3),
      ], cerealCandidates);
      expect(
        report.suggestions.map((s) => s.toUpc),
        isNot(contains('LOW-SUGAR')),
      );
    });
  });

  group('quantity effects', () {
    final candidates = {
      'CEREAL': [
        candidate('C1', 'CEREAL', sodium: 100, addedSugar: 0, fiber: 3),
      ],
      'BREAD': [candidate('B1', 'BREAD', sodium: 100, addedSugar: 0, fiber: 3)],
    };

    test('the higher-quantity line ranks first', () {
      final cerealHeavy = analyze([
        line('X', 'CEREAL', qty: 3, sodium: 600, addedSugar: 0, fiber: 3),
        line('Z', 'BREAD', qty: 1, sodium: 600, addedSugar: 0, fiber: 3),
      ], candidates);
      expect(cerealHeavy.suggestions.map((s) => s.fromUpc), ['X', 'Z']);

      final breadHeavy = analyze([
        line('X', 'CEREAL', qty: 1, sodium: 600, addedSugar: 0, fiber: 3),
        line('Z', 'BREAD', qty: 3, sodium: 600, addedSugar: 0, fiber: 3),
      ], candidates);
      expect(breadHeavy.suggestions.map((s) => s.fromUpc), ['Z', 'X']);
    });

    test('before/after averages are weighted by quantity', () {
      final report = analyze([
        line('X', 'CEREAL', qty: 3, sodium: 600, addedSugar: 0, fiber: 3),
        line('Z', 'BREAD', qty: 1, sodium: 600, addedSugar: 0, fiber: 3),
      ], candidates);
      final first = report.suggestions.first;
      expect(first.qty, 3);
      expect(first.before, 600);
      expect(first.after, closeTo((100 * 3 + 600) / 4, 1e-9));
    });
  });

  test('previews leave the basket and balances unchanged', () {
    final basket = [
      cerealX(),
      line('SOUP', 'SOUP', sodium: 900, addedSugar: 0, fiber: 3),
    ];
    final balances = balancesFor(basket);
    final basketBefore = jsonEncode(basket);
    final balancesBefore = jsonEncode(balances);
    final report = analyze(basket, cerealCandidates, balances: balances);
    expect(report.suggestions, isNotEmpty);
    expect(jsonEncode(basket), basketBefore);
    expect(jsonEncode(balances), balancesBefore);
  });

  group('recalculation after a swap', () {
    test('the next largest gap is ranked after a swap, with tradeoffs', () {
      final basket = [
        cerealX(),
        line('SOUP', 'SOUP', sodium: 900, addedSugar: 0, fiber: 3),
      ];
      final s = analyze(basket, cerealCandidates).suggestions.single;
      final swapped = [
        {
          ...basket[0],
          'upc': s.toUpc,
          'name': s.toName,
          'nutrition': s.toNutrition,
        },
        basket[1],
      ];
      final after = analyze(swapped, cerealCandidates);
      final sodium = after.summaries.firstWhere(
        (x) => x.target.key == 'sodium',
      );
      expect(sodium.averagePerServing, closeTo(s.after, 1e-9));

      // Sodium is now nearly on target, so added sugar is the largest gap.
      expect(after.focus!.key, 'addedSugar');
      final next = after.suggestions.single;
      expect(next.fromUpc, 'LOW-SODIUM');
      expect(next.toUpc, 'LOW-SUGAR');
      expect(next.tradeoffs.single, contains('Sodium average rises'));
    });
  });

  group('missing data', () {
    test('unknown values are excluded from averages and flagged', () {
      final report = analyze([
        line('A', 'CEREAL', qty: 2, sodium: 600, addedSugar: 0, fiber: 3),
        line('B', 'BREAD', qty: 1, addedSugar: 0, fiber: 3),
      ], const {});
      final sodium = report.summaries.firstWhere(
        (x) => x.target.key == 'sodium',
      );
      expect(sodium.averagePerServing, 600);
      expect(sodium.measuredQty, 2);
      expect(sodium.totalQty, 3);
      expect(sodium.incomplete, isTrue);
    });

    test('a basket line with an unknown focus value is not swapped', () {
      final report = analyze(
        [
          line('A', 'CEREAL', sodium: 900, addedSugar: 0, fiber: 3),
          line('B', 'BREAD', addedSugar: 0, fiber: 3),
          line('C', 'RICE', sodium: 900, addedSugar: 0, fiber: 3),
        ],
        {
          'BREAD': [
            candidate('B1', 'BREAD', sodium: 0, addedSugar: 0, fiber: 3),
          ],
          'CEREAL': [
            candidate('A1', 'CEREAL', sodium: 0, addedSugar: 0, fiber: 3),
          ],
        },
      );
      expect(report.focus!.key, 'sodium');
      expect(report.suggestions.map((s) => s.fromUpc), ['A']);
    });

    test('a candidate without the focus value is excluded', () {
      final report = analyze(
        [line('A', 'CEREAL', sodium: 900, addedSugar: 0, fiber: 3)],
        {
          'CEREAL': [candidate('NO-SODIUM', 'CEREAL', addedSugar: 0, fiber: 3)],
        },
      );
      expect(report.suggestions, isEmpty);
      expect(report.message, contains('No same-category swap'));
    });

    test('a candidate missing a secondary value reports it as a tradeoff', () {
      final report = analyze(
        [line('A', 'CEREAL', sodium: 900, addedSugar: 0, fiber: 3)],
        {
          'CEREAL': [candidate('A1', 'CEREAL', sodium: 100, addedSugar: 0)],
        },
      );
      expect(
        report.suggestions.single.tradeoffs,
        contains('Fiber is unknown for Candidate A1.'),
      );
    });

    test('mostly unknown data abstains instead of guessing', () {
      final report = analyze([
        line('A', 'CEREAL', sodium: 900),
        line('B', 'BREAD', qty: 3),
      ], cerealCandidates);
      expect(report.focus, isNull);
      expect(report.suggestions, isEmpty);
      expect(report.message, contains('Not enough nutrition information'));
    });
  });

  group('balance consistency', () {
    final basket = [
      line('A', 'CEREAL', qty: 2, sodium: 900, addedSugar: 0, fiber: 3),
    ];
    final candidates = {
      'CEREAL': [candidate('A1', 'CEREAL', sodium: 0, addedSugar: 0, fiber: 3)],
    };

    test('used below the basket quantity blocks swaps', () {
      final report = analyze(
        basket,
        candidates,
        balances: {
          'CEREAL': {'allowed': 2, 'used': 1},
        },
      );
      expect(report.suggestions, isEmpty);
      expect(report.message, contains('allowance does not match'));
    });

    test('used above allowed blocks swaps', () {
      final report = analyze(
        basket,
        candidates,
        balances: {
          'CEREAL': {'allowed': 1, 'used': 2},
        },
      );
      expect(report.suggestions, isEmpty);
    });

    test('a missing balance blocks swaps', () {
      expect(analyze(basket, candidates, balances: {}).suggestions, isEmpty);
    });

    test(
      'a full but consistent allowance still allows a same-category swap',
      () {
        final report = analyze(
          basket,
          candidates,
          balances: {
            'CEREAL': {'allowed': 2, 'used': 2},
          },
        );
        expect(report.suggestions.single.toUpc, 'A1');
      },
    );
  });

  group('no-candidate and boundary cases', () {
    test('empty basket', () {
      final report = analyze([], cerealCandidates);
      expect(report.suggestions, isEmpty);
      expect(report.message, contains('Add items'));
    });

    test('a basket within every target gets no suggestions', () {
      final report = analyze([
        line('A', 'CEREAL', sodium: 100, addedSugar: 2, fiber: 4),
      ], cerealCandidates);
      expect(report.focus, isNull);
      expect(report.suggestions, isEmpty);
      expect(report.message, contains('within the example'));
    });

    test('no improving candidate gives an explicit message', () {
      final report = analyze([
        line('A', 'CEREAL', sodium: 900, addedSugar: 0, fiber: 3),
      ], const {});
      expect(report.focus!.key, 'sodium');
      expect(report.suggestions, isEmpty);
      expect(report.message, contains('No same-category swap'));
    });

    test('other categories, ineligible items and PAID lines are excluded', () {
      final report = analyze(
        [
          line('A', 'CEREAL', sodium: 900, addedSugar: 0, fiber: 3),
          {...line('A', 'PAID', sodium: 900, addedSugar: 0, fiber: 3)},
        ],
        {
          'CEREAL': [
            candidate('OTHER-CAT', 'BREAD', sodium: 0, addedSugar: 0, fiber: 3),
            candidate(
              'INELIGIBLE',
              'CEREAL',
              eligible: false,
              sodium: 0,
              addedSugar: 0,
              fiber: 3,
            ),
          ],
          'PAID': [candidate('P1', 'PAID', sodium: 0, addedSugar: 0, fiber: 3)],
        },
        balances: {
          'CEREAL': {'allowed': 1, 'used': 1},
          'PAID': {'allowed': null, 'used': 1},
        },
      );
      expect(report.suggestions, isEmpty);
    });

    test('at most three suggestions, ties broken by UPC', () {
      final basket = [
        for (final c in ['D', 'C', 'B', 'A'])
          line(c, 'CAT$c', sodium: 900, addedSugar: 0, fiber: 3),
      ];
      final candidates = {
        for (final c in ['A', 'B', 'C', 'D'])
          'CAT$c': [
            candidate('${c}2', 'CAT$c', sodium: 100, addedSugar: 0, fiber: 3),
            candidate('${c}1', 'CAT$c', sodium: 100, addedSugar: 0, fiber: 3),
          ],
      };
      final report = analyze(basket, candidates);
      expect(report.suggestions.map((s) => s.fromUpc), ['A', 'B', 'C']);
      expect(report.suggestions.map((s) => s.toUpc), ['A1', 'B1', 'C1']);
    });
  });
}
