import 'dart:convert';

import 'package:flutter/services.dart';

/// A prepared example contains evidence only. Expected test answers are never
/// passed to the decision service or used to choose the explanation.
class CheckoutHelpExample {
  final String id;
  final String title;
  final Map<String, dynamic> item;
  final Map<String, dynamic> benefit;

  CheckoutHelpExample({
    required this.id,
    required this.title,
    required Map<String, dynamic> item,
    required Map<String, dynamic> benefit,
  }) : item = _freeze(item),
       benefit = _freeze(benefit);

  /// Translate an example into the same fields used by a basket card.
  /// This returns a read-only sample; it never adds it to AppState or storage.
  Map<String, dynamic> toBasketLine() => Map.unmodifiable({
    'upc': item['id'],
    'name': item['name'],
    'qty': item['quantity'],
    'category': item['basket_category'],
    'original_benefit_category': item['original_benefit_category'],
    'checkout_help_source': 'synthetic',
    'checkout_help_scenario_id': id,
  });

  static Map<String, dynamic> _freeze(Map<String, dynamic> data) {
    return Map.unmodifiable(
      data.map(
        (key, value) => MapEntry(
          key,
          value is Map<String, dynamic> ? _freeze(value) : value,
        ),
      ),
    );
  }
}

/// Keeps demonstration evidence separate from a shopper's real basket data.
///
/// Official benefit evidence is not connected yet. Ordinary basket items receive
/// no invented size rules or balances here. The dialog separately explains PAID
/// allocation using the app's saved demo allowance. Product suggestions belong to M2.
/// A prepared basket line may explicitly opt into a synthetic scenario. Its
/// identity, quantity, and classifications must match that scenario exactly.
class CheckoutHelpRepository {
  const CheckoutHelpRepository({this.bundle});

  final AssetBundle? bundle;

  Future<List<CheckoutHelpExample>> loadExamples() async {
    final text = await (bundle ?? rootBundle).loadString(
      'assets/mock/checkout_help_scenarios.json',
    );
    final data = jsonDecode(text);
    if (data is! Map ||
        data['synthetic'] != true ||
        data['schema_version'] != 1) {
      throw const FormatException('Unsupported checkout-help example data.');
    }
    return (data['scenarios'] as List)
        .map((raw) {
          if (raw['synthetic'] != true) {
            throw const FormatException(
              'An example must be labeled synthetic.',
            );
          }
          return CheckoutHelpExample(
            id: raw['scenario_id'] as String,
            title: raw['title'] as String,
            item: Map<String, dynamic>.from(raw['input']['item'] as Map),
            benefit: Map<String, dynamic>.from(raw['input']['benefit'] as Map),
          );
        })
        .toList(growable: false);
  }

  Future<CheckoutHelpExample?> forBasketItem(Map<String, dynamic> line) async {
    if (line['checkout_help_source'] != 'synthetic' ||
        line['checkout_help_scenario_id'] is! String) {
      return null;
    }
    final examples = await loadExamples();
    for (final example in examples) {
      final item = example.item;
      if (example.id == line['checkout_help_scenario_id'] &&
          item['id'] == line['upc'] &&
          item['quantity'] == line['qty'] &&
          item['basket_category'] == line['category'] &&
          item['original_benefit_category'] ==
              line['original_benefit_category']) {
        return example;
      }
    }
    return null;
  }
}
