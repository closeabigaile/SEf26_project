import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wolfbite/services/checkout_help_service.dart';

/// Read a fresh copy each time so one test cannot change another test's data.
/// Run this suite from Project3; no Firebase connection or app asset loader
/// is needed for these service tests.
Map<String, dynamic> _readCase(String id) {
  final dataset =
      jsonDecode(
            File('assets/mock/checkout_help_scenarios.json').readAsStringSync(),
          )
          as Map<String, dynamic>;
  return (dataset['scenarios'] as List)
      .cast<Map<String, dynamic>>()
      .singleWhere((scenario) => scenario['scenario_id'] == id);
}

/// Compare all three public result fields, including the complete messages.
void _expectResult(CheckoutHelpResult actual, Map<String, dynamic> expected) {
  expect(actual.possibleCause, expected['possible_cause']);
  expect(actual.explanation, expected['explanation']);
  expect(actual.suggestedNextStep, expected['suggested_next_step']);
}

void _expectFallback(CheckoutHelpResult result) {
  _expectResult(
    result,
    _readCase('M0-M4-F01')['expected_help'] as Map<String, dynamic>,
  );
}

/// Make nested maps read-only too. Any attempt by the service to change even
/// a nested package size will throw and fail the test.
Map<String, dynamic> _readOnly(Map<String, dynamic> input) {
  return Map<String, dynamic>.unmodifiable(
    input.map(
      (key, value) => MapEntry(
        key,
        value is Map<String, dynamic> ? _readOnly(value) : value,
      ),
    ),
  );
}

void main() {
  late CheckoutHelpService service;
  late Map<String, dynamic> item;
  late Map<String, dynamic> benefit;

  void loadInput(String id) {
    final input = _readCase(id)['input'] as Map<String, dynamic>;
    item = input['item'] as Map<String, dynamic>;
    benefit = input['benefit'] as Map<String, dynamic>;
  }

  CheckoutHelpResult explain() => service.explain(item: item, benefit: benefit);

  // setUp runs before EACH test. Most edge cases start with valid size-mismatch
  // evidence and change one detail to show why the answer should change.
  setUp(() {
    service = CheckoutHelpService();
    loadInput('M0-M4-01');
  });

  group('Shared M0/M4 scenarios', () {
    for (final id in ['M0-M4-01', 'M0-M4-02', 'M0-M4-03', 'M0-M4-F01']) {
      test('$id returns the expected cause, explanation, and next step', () {
        loadInput(id);
        final expected = _readCase(id)['expected_help'] as Map<String, dynamic>;
        _expectResult(explain(), expected);
      });

      test('$id preserves inputs and accepts read-only nested records', () {
        loadInput(id);
        final before = jsonEncode({'item': item, 'benefit': benefit});
        final expected = _readCase(id)['expected_help'] as Map<String, dynamic>;

        // Check writable records before freezing them. This catches changes
        // even if an implementation tries to catch a write-related exception.
        _expectResult(explain(), expected);
        expect(jsonEncode({'item': item, 'benefit': benefit}), before);
        _expectResult(
          service.explain(item: _readOnly(item), benefit: _readOnly(benefit)),
          expected,
        );
        _expectResult(explain(), expected); // Repeated calls are consistent.
      });
    }
  });

  group('Evidence determines the answer', () {
    test('uses original category even when the basket line is PAID', () {
      loadInput('M0-M4-02');
      expect(item['basket_category'], 'PAID');
      final result = explain();
      expect(result.possibleCause, 'insufficient_category_balance');
      expect(result.explanation, contains('cereal balance is 0 units'));
      expect(result.suggestedNextStep, contains('same-category substitution'));
      expect(item['basket_category'], 'PAID');
    });

    test('ignores misleading IDs, names, and expected-answer fields', () {
      item['id'] = 'mock-cereal-balance-18oz';
      item['name'] = 'Outdated cereal';
      item['scenario_id'] = 'M0-M4-03';
      item['expected_help'] = {'possible_cause': 'outdated_information'};
      _expectResult(
        explain(),
        _readCase('M0-M4-01')['expected_help'] as Map<String, dynamic>,
      );
    });

    test('supports other categories, decimal sizes, and matching units', () {
      item['original_benefit_category'] = 'GRAINS';
      benefit['category'] = 'GRAINS';
      item['package_size'] = {'value': 500.5, 'unit': 'g'};
      benefit['permitted_package_size'] = {'value': 400.0, 'unit': 'g'};
      final result = explain();
      expect(result.possibleCause, 'package_size_mismatch');
      expect(result.explanation, contains('this package is 500.5 g'));
      expect(result.explanation, contains('permitted package size of 400 g'));
      expect(result.suggestedNextStep, contains('eligible 400 g package'));
      expect(result.explanation, isNot(contains('18 oz')));
    });

    test('uses supplied total units without multiplying by quantity again', () {
      loadInput('M0-M4-02');
      item['original_benefit_category'] = 'GRAINS';
      benefit['category'] = 'GRAINS';
      item['quantity'] = 3;
      benefit['required_units'] = 3;
      benefit['available_units_after_other_allocations'] = 1;
      final result = explain();
      expect(result.possibleCause, 'insufficient_category_balance');
      expect(result.explanation, contains('grains balance is 1 unit'));
      expect(result.explanation, contains('this item needs 3 units'));
      expect(result.suggestedNextStep, contains('current grains balance'));
      expect(result.suggestedNextStep, isNot(contains('zero units')));
    });

    test('equal available and required units do not establish a shortfall', () {
      loadInput('M0-M4-02');
      benefit['available_units_after_other_allocations'] = 1;
      _expectFallback(explain());
    });

    test('both size mismatch and shortfall are ambiguous', () {
      benefit['available_units_after_other_allocations'] = 0;
      _expectFallback(explain());
    });

    test('matching size and sufficient balance do not explain a rejection', () {
      item['package_size'] = {'value': 18, 'unit': 'oz'};
      benefit['available_units_after_other_allocations'] = 2;
      _expectFallback(explain());
    });
  });

  group('Freshness', () {
    for (final record in ['item', 'benefit']) {
      test(
        'explicitly outdated $record takes priority over size and balance',
        () {
          final evidence = record == 'item' ? item : benefit;
          evidence['information_freshness'] = 'outdated';
          benefit['available_units_after_other_allocations'] = 0;
          _expectResult(
            explain(),
            _readCase('M0-M4-03')['expected_help'] as Map<String, dynamic>,
          );
        },
      );

      for (final status in [null, 'unknown', 'invalid', true]) {
        test('$record freshness $status cannot support a diagnosis', () {
          final evidence = record == 'item' ? item : benefit;
          evidence['information_freshness'] = status;
          _expectFallback(explain());
        });
      }
    }

    for (final replacement in [null, true, 'false']) {
      test(
        'outdated evidence with replacement flag ${jsonEncode(replacement)} is uncertain',
        () {
          loadInput('M0-M4-03');
          benefit['verified_current_replacement_available'] = replacement;
          _expectFallback(explain());
        },
      );
    }
  });

  group('Missing, conflicting, or unsupported evidence', () {
    test('empty records return the complete fallback', () {
      _expectFallback(service.explain(item: {}, benefit: {}));
    });

    for (final key in [
      'original_benefit_category',
      'quantity',
      'package_size',
      'information_freshness',
    ]) {
      test('missing item $key does not produce a guess', () {
        item.remove(key);
        _expectFallback(explain());
      });
    }

    for (final key in [
      'category',
      'category_covered',
      'permitted_package_size',
      'required_units',
      'available_units_after_other_allocations',
      'units_allocated_to_affected_item',
      'unit',
      'information_freshness',
    ]) {
      test('missing benefit $key does not produce a guess', () {
        benefit.remove(key);
        _expectFallback(explain());
      });
    }

    test('different item and benefit categories conflict', () {
      benefit['category'] = 'MILK';
      _expectFallback(explain());
    });

    test('uncovered category is outside the three supported causes', () {
      benefit['category_covered'] = false;
      _expectFallback(explain());
    });

    test('different size units cannot be compared without conversion', () {
      item['package_size'] = {'value': 24, 'unit': 'g'};
      _expectFallback(explain());
    });

    test('unknown size units cannot establish a mismatch', () {
      item['package_size'] = {'value': 24, 'unit': ' '};
      _expectFallback(explain());
    });

    test('malformed nested package information does not throw', () {
      item['package_size'] = '24 oz';
      _expectFallback(explain());
    });

    // These cases document the current mock-evidence contract, not support
    // for real benefit units or partially allocated real-world basket lines.
    test('existing affected-item allocation requires more context', () {
      loadInput('M0-M4-02');
      benefit['units_allocated_to_affected_item'] = 1;
      _expectFallback(explain());
    });

    test('real benefit units are not silently treated as mock counts', () {
      benefit['unit'] = 'dollars';
      _expectFallback(explain());
    });

    test(
      'a flagged separate current replacement needs its actual evidence',
      () {
        benefit['verified_current_replacement_available'] = true;
        _expectFallback(explain());
      },
    );
  });

  group('Invalid numbers', () {
    for (final value in [null, '1', -1, double.nan, double.infinity]) {
      test(
        'invalid selected size $value (${value.runtimeType}) returns fallback',
        () {
          item['package_size'] = {'value': value, 'unit': 'oz'};
          _expectFallback(explain());
        },
      );

      test(
        'invalid available balance $value (${value.runtimeType}) is not assumed to be zero',
        () {
          loadInput('M0-M4-02');
          benefit['available_units_after_other_allocations'] = value;
          _expectFallback(explain());
        },
      );
    }

    test('zero required units do not explain an insufficient balance', () {
      loadInput('M0-M4-02');
      benefit['required_units'] = 0;
      _expectFallback(explain());
    });

    test('zero package size is unusable', () {
      item['package_size'] = {'value': 0, 'unit': 'oz'};
      _expectFallback(explain());
    });

    test('fractional package quantity is unusable', () {
      item['quantity'] = 1.5;
      _expectFallback(explain());
    });
  });

  group('Additional edge and unusual cases', () {
    test(
      'smaller packages can mismatch too; only exact permitted size matches',
      () {
        item['package_size'] = {'value': 12, 'unit': 'oz'};
        final result = explain();
        expect(result.possibleCause, 'package_size_mismatch');
        expect(result.explanation, contains('this package is 12 oz'));
        expect(result.suggestedNextStep, contains('eligible 18 oz package'));
      },
    );

    test('whole-number doubles compare like integers', () {
      loadInput('M0-M4-02');
      item['package_size'] = {'value': 18.0, 'unit': 'oz'};
      item['quantity'] = 1.0;
      benefit['required_units'] = 1.0;
      benefit['available_units_after_other_allocations'] = 0.0;
      benefit['units_allocated_to_affected_item'] = 0.0;
      _expectResult(
        explain(),
        _readCase('M0-M4-02')['expected_help'] as Map<String, dynamic>,
      );
    });

    test('category and unit spaces/case do not create a false conflict', () {
      item['original_benefit_category'] = ' cereal ';
      benefit['category'] = 'Cereal';
      item['package_size'] = {'value': 24, 'unit': ' OZ '};
      benefit['permitted_package_size'] = {'value': 18, 'unit': 'oz'};
      final before = jsonEncode({'item': item, 'benefit': benefit});
      expect(explain().possibleCause, 'package_size_mismatch');
      // Normalizing text for comparison must not rewrite the original records.
      expect(jsonEncode({'item': item, 'benefit': benefit}), before);
    });

    test(
      'missing original category cannot be replaced by basket classification',
      () {
        loadInput('M0-M4-02');
        item.remove('original_benefit_category');
        item['basket_category'] = 'CEREAL';
        _expectFallback(explain());
      },
    );

    test('display identity is not evidence for the cause', () {
      item.remove('id');
      item.remove('name');
      expect(explain().possibleCause, 'package_size_mismatch');
      // The later UI must still identify its selected item; that is not this
      // service's responsibility and is not established by this test.
    });

    for (final invalidCoverage in [null, 'true', 1]) {
      test(
        'coverage ${jsonEncode(invalidCoverage)} must not be treated as true',
        () {
          benefit['category_covered'] = invalidCoverage;
          _expectFallback(explain());
        },
      );
    }

    for (final invalidText in ['', '   ', 42, <String>[]]) {
      test('invalid category ${jsonEncode(invalidText)} does not throw', () {
        item['original_benefit_category'] = invalidText;
        _expectFallback(explain());
      });
    }

    for (final invalidSize in [<String>[], <String, dynamic>{}, true]) {
      test(
        'invalid permitted size ${jsonEncode(invalidSize)} returns fallback',
        () {
          benefit['permitted_package_size'] = invalidSize;
          _expectFallback(explain());
        },
      );
    }

    // The original tests exercised selected sizes and available balances.
    // Check the other numeric inputs too: they come from separate fields.
    for (final value in [0, -1, '1', true, double.nan, double.infinity]) {
      test(
        'invalid required units $value (${value.runtimeType}) return fallback',
        () {
          benefit['required_units'] = value;
          _expectFallback(explain());
        },
      );
      test(
        'invalid permitted size $value (${value.runtimeType}) returns fallback',
        () {
          benefit['permitted_package_size'] = {'value': value, 'unit': 'oz'};
          _expectFallback(explain());
        },
      );
    }

    for (final value in [0, -1, '1', true, double.infinity]) {
      test(
        'invalid quantity $value (${value.runtimeType}) returns fallback',
        () {
          item['quantity'] = value;
          _expectFallback(explain());
        },
      );
    }

    test(
      'one explicitly outdated record still matters when the other is unknown',
      () {
        loadInput('M0-M4-03');
        item['information_freshness'] = 'unknown';
        _expectResult(
          explain(),
          _readCase('M0-M4-03')['expected_help'] as Map<String, dynamic>,
        );
      },
    );

    test(
      'both outdated records return uncertainty, not a size or balance cause',
      () {
        item['information_freshness'] = 'outdated';
        benefit['information_freshness'] = 'outdated';
        _expectResult(
          explain(),
          _readCase('M0-M4-03')['expected_help'] as Map<String, dynamic>,
        );
      },
    );

    test('unrelated calls cannot leak an earlier answer into the next case', () {
      // Reuse the same service instance while moving between all four answers.
      for (final id in ['M0-M4-02', 'M0-M4-F01', 'M0-M4-03', 'M0-M4-01']) {
        loadInput(id);
        _expectResult(
          explain(),
          _readCase(id)['expected_help'] as Map<String, dynamic>,
        );
      }
    });

    test(
      'ambiguous evidence stays unchanged, including extra nested metadata',
      () {
        benefit['available_units_after_other_allocations'] = 0;
        item['notes'] = {
          'labels': ['keep', 'these'],
        };
        final before = jsonEncode({'item': item, 'benefit': benefit});
        _expectFallback(explain());
        expect(jsonEncode({'item': item, 'benefit': benefit}), before);
      },
    );

    test('a later input change cannot rewrite an already returned result', () {
      final result = explain();
      item['package_size']['value'] = 30;
      benefit['permitted_package_size']['value'] = 20;
      _expectResult(
        result,
        _readCase('M0-M4-01')['expected_help'] as Map<String, dynamic>,
      );
      expect(explain().explanation, contains('this package is 30 oz'));
    });

    test('negative floating-point zero is displayed as an empty balance', () {
      loadInput('M0-M4-02');
      benefit['available_units_after_other_allocations'] = -0.0;
      _expectResult(
        explain(),
        _readCase('M0-M4-02')['expected_help'] as Map<String, dynamic>,
      );
    });

    test('large required amounts are displayed without integer overflow', () {
      loadInput('M0-M4-02');
      benefit['required_units'] = 1e20;
      final result = explain();
      expect(result.possibleCause, 'insufficient_category_balance');
      final amount = RegExp(
        r'this item needs (\S+) units',
      ).firstMatch(result.explanation);
      expect(amount, isNotNull);
      expect(num.parse(amount!.group(1)!), 1e20);
    });

    test('very large finite sizes are displayed without integer overflow', () {
      // An intentionally unrealistic size checks numeric safety, not a real
      // benefit rule. The reported number must still match the supplied one.
      item['package_size'] = {'value': 1e20, 'unit': 'oz'};
      final result = explain();
      expect(result.possibleCause, 'package_size_mismatch');
      // Both ordinary and scientific notation are fine. Check the numeric
      // meaning so the test catches overflow without dictating display style.
      final size = RegExp(
        r'this package is (\S+) oz',
      ).firstMatch(result.explanation);
      expect(size, isNotNull);
      expect(num.parse(size!.group(1)!), 1e20);
    });
  });
}
