import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wolfbite/services/checkout_help_service.dart';

// Focused review tests supplement the existing service suite. These originally
// exposed validation/precision weaknesses; keep their expected behavior stable
// as regression protection. See checkout_help_test_review.md for the history.
Map<String, dynamic> _scenario(String id) {
  final data =
      jsonDecode(
            File('assets/mock/checkout_help_scenarios.json').readAsStringSync(),
          )
          as Map<String, dynamic>;
  return (data['scenarios'] as List).cast<Map<String, dynamic>>().singleWhere(
    (entry) => entry['scenario_id'] == id,
  );
}

void main() {
  late Map<String, dynamic> item;
  late Map<String, dynamic> benefit;
  final service = CheckoutHelpService();

  void load(String id) {
    final input = _scenario(id)['input'] as Map<String, dynamic>;
    item = input['item'] as Map<String, dynamic>;
    benefit = input['benefit'] as Map<String, dynamic>;
  }

  CheckoutHelpResult explain() => service.explain(item: item, benefit: benefit);

  void expectFallback(CheckoutHelpResult result) {
    final expected = _scenario('M0-M4-F01')['expected_help'];
    expect(result.possibleCause, expected['possible_cause']);
    expect(result.explanation, expected['explanation']);
    expect(result.suggestedNextStep, expected['suggested_next_step']);
  }

  setUp(() => load('M0-M4-01'));

  test('A01 equivalent decimal package sizes should not invent a mismatch', () {
    // Arithmetic can produce 0.30000000000000004 instead of 0.3. These
    // represent the same intended decimal amount, not a different package.
    item['package_size'] = {'value': 0.1 + 0.2, 'unit': 'oz'};
    benefit['permitted_package_size'] = {'value': 0.3, 'unit': 'oz'};
    expectFallback(explain());
  });

  test('A02 decimal rounding alone should not invent a balance shortfall', () {
    load('M0-M4-02');
    benefit['required_units'] = 0.1 + 0.2;
    benefit['available_units_after_other_allocations'] = 0.3;
    // Decimal evidence now has a 15-significant-digit comparison policy.
    expectFallback(explain());
  });

  test('A03 a genuinely tiny positive balance still has a shortfall', () {
    load('M0-M4-02');
    benefit['available_units_after_other_allocations'] = 0.001;
    final result = explain();
    expect(result.possibleCause, 'insufficient_category_balance');
    expect(result.explanation, contains('balance is 0.001 units'));
    expect(result.explanation, contains('this item needs 1 unit'));
    expect(result.suggestedNextStep, contains('reduce the quantity'));
    expect(result.suggestedNextStep, isNot(contains('zero units')));
    expect(
      result.explanation,
      contains("not the checkout system's official reason"),
    );
  });

  test('A04 a real small size difference must not be rounded away', () {
    // This protects against fixing A01 with a tolerance so broad that actual
    // package differences disappear. The difference here is one hundredth oz.
    item['package_size'] = {'value': 18.01, 'unit': 'oz'};
    final result = explain();
    expect(result.possibleCause, 'package_size_mismatch');
    expect(result.explanation, contains('this package is 18.01 oz'));
    expect(result.suggestedNextStep, contains('eligible 18 oz package'));
  });

  test('A05 two unknown unit labels do not establish comparable sizes', () {
    item['package_size'] = {'value': 24, 'unit': 'unknown'};
    benefit['permitted_package_size'] = {'value': 18, 'unit': 'unknown'};
    // Two missing-unit placeholders matching each other is not evidence of
    // a common measurement unit. An importer could supply these placeholders.
    expectFallback(explain());
  });

  test(
    'A06 PAID is a payment classification, not an original benefit category',
    () {
      item['original_benefit_category'] = 'PAID';
      benefit['category'] = 'PAID';
      // Simulate an adapter incorrectly copying the basket's classification.
      // Even with category_covered true, these records contradict that meaning.
      expectFallback(explain());
    },
  );

  test('A07 matching UNKNOWN categories do not classify an item', () {
    item['original_benefit_category'] = 'UNKNOWN';
    benefit['category'] = 'UNKNOWN';
    // A matching label should not make an unclassified product eligible for
    // a size diagnosis. Treat this contradictory record conservatively.
    expectFallback(explain());
  });

  test(
    'A08 multiple permitted sizes require an explicit rule, not a guess',
    () {
      benefit['permitted_package_size'] = [
        {'value': 18, 'unit': 'oz'},
        {'value': 24, 'unit': 'oz'},
      ];
      // Real catalogs may have several permitted sizes. This service supports
      // one size only; it must not pick the first and tell the user to swap.
      expectFallback(explain());
    },
  );
}
