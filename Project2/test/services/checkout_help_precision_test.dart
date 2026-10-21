import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wolfbite/services/checkout_help_service.dart';

void main() {
  Map<String, dynamic> input(String id) =>
      (jsonDecode(
                    File(
                      'assets/mock/checkout_help_scenarios.json',
                    ).readAsStringSync(),
                  )['scenarios']
                  as List)
              .singleWhere((entry) => entry['scenario_id'] == id)['input']
          as Map<String, dynamic>;

  test('very small decimal amounts retain meaningful shortfalls', () {
    final data = input('M0-M4-02');
    data['benefit']['required_units'] = 2e-20;
    data['benefit']['available_units_after_other_allocations'] = 1e-20;
    final result = CheckoutHelpService().explain(
      item: data['item'],
      benefit: data['benefit'],
    );
    expect(result.possibleCause, 'insufficient_category_balance');
    expect(result.explanation, contains('1e-20 units'));
    expect(result.suggestedNextStep, isNot(contains('zero units')));
  });

  test('large integer amounts keep exact comparisons and displayed values', () {
    final data = input('M0-M4-02');
    data['benefit']['required_units'] = 9007199254740993;
    data['benefit']['available_units_after_other_allocations'] =
        9007199254740992;
    final result = CheckoutHelpService().explain(
      item: data['item'],
      benefit: data['benefit'],
    );
    expect(result.possibleCause, 'insufficient_category_balance');
    expect(result.explanation, contains('needs 9007199254740993 units'));
  });

  test('a representable small decimal size difference remains a mismatch', () {
    final data = input('M0-M4-01');
    data['item']['package_size']['value'] = 18.000000000001;
    final result = CheckoutHelpService().explain(
      item: data['item'],
      benefit: data['benefit'],
    );
    expect(result.possibleCause, 'package_size_mismatch');
  });

  test(
    'placeholder categories are rejected after whitespace and case normalization',
    () {
      for (final category in [' paid ', 'Unknown', 'UNCLASSIFIED', 'n/a']) {
        final data = input('M0-M4-01');
        data['item']['original_benefit_category'] = category;
        data['benefit']['category'] = category;
        final result = CheckoutHelpService().explain(
          item: data['item'],
          benefit: data['benefit'],
        );
        expect(result.possibleCause, 'unable_to_determine', reason: category);
      }
    },
  );

  test('matching unsupported measurement labels do not imply usable units', () {
    final data = input('M0-M4-01');
    data['item']['package_size']['unit'] = 'scoops';
    data['benefit']['permitted_package_size']['unit'] = 'scoops';
    final result = CheckoutHelpService().explain(
      item: data['item'],
      benefit: data['benefit'],
    );
    expect(result.possibleCause, 'unable_to_determine');
  });
}
