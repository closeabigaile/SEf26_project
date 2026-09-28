import 'dart:convert';
import 'dart:io';

import 'package:wolfbite/services/nutrition_recommender.dart';

/// Run from Project3: dart scripts/nutrition_cli.dart --catalog file.csv
/// --request request.json. This command reads local files and never contacts Firebase.
void main(List<String> args) {
  try {
    String option(String name) {
      final index = args.indexOf(name);
      if (index < 0 || index + 1 >= args.length) {
        throw FormatException('Pass $name <path>.');
      }
      return args[index + 1];
    }

    final catalog = readCatalog(File(option('--catalog')));
    final request =
        jsonDecode(File(option('--request')).readAsStringSync())
            as Map<String, dynamic>;
    final rawContext = request['context'] as Map<String, dynamic>;
    final rawTargets = rawContext['targets'] as Map<String, dynamic>?;
    final context = NutritionContext(
      mode: NutritionMode.values.byName(rawContext['mode'] as String),
      lifeStage: LifeStage.values.byName(rawContext['lifeStage'] as String),
      targets: rawTargets == null
          ? null
          : NutritionTargets(
              sourceUrl: rawTargets['sourceUrl'] as String,
              lifeStage: LifeStage.values.byName(
                rawTargets['lifeStage'] as String,
              ),
              caloriesPerDay: (rawTargets['caloriesPerDay'] as num?)
                  ?.toDouble(),
              proteinGramsPerDay: (rawTargets['proteinGramsPerDay'] as num?)
                  ?.toDouble(),
              sodiumMgMaxPerDay: (rawTargets['sodiumMgMaxPerDay'] as num?)
                  ?.toDouble(),
            ),
      budgetPerMeal: (rawContext['budgetPerMeal'] as num?)?.toDouble(),
      mealsPerDay: rawContext['mealsPerDay'] as int? ?? 3,
      training: rawContext['training'] as bool? ?? false,
      clinicianWeightPlan: rawContext['clinicianWeightPlan'] as bool? ?? false,
      useHistory: rawContext['useHistory'] as bool? ?? false,
      excludedUpcs: (rawContext['excludedUpcs'] as List<dynamic>? ?? [])
          .cast<String>()
          .toSet(),
    );
    final history = (request['history'] as List<dynamic>? ?? []).map((entry) {
      final record = entry as Map<String, dynamic>;
      return PurchaseRecord(
        DateTime.parse(record['date'] as String),
        (record['products'] as List<dynamic>)
            .map((p) => NutritionProduct.fromMap(p as Map<String, dynamic>))
            .toList(),
      );
    }).toList();
    final result = const NutritionRecommender().recommend(
      catalog: catalog,
      basketUpcs: (request['basketUpcs'] as List<dynamic>)
          .cast<String>()
          .toSet(),
      context: context,
      history: history,
      now: request['asOf'] == null
          ? null
          : DateTime.parse(request['asOf'] as String),
    );
    Map<String, dynamic> evidence(String id) {
      final source = nutritionEvidence[id];
      if (source == null) throw StateError('Missing evidence for $id');
      return {
        'id': id,
        'claim': source.claim,
        'title': source.title,
        'url': source.url,
      };
    }

    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert({
        'testProfile': request['testProfile'],
        'testOnlyAssumptions': request['testOnlyAssumptions'],
        'blockedReason': result.blockedReason,
        'mealIdeas': [
          for (final meal in result.meals)
            {
              'products': [
                for (final product in meal.products)
                  {
                    'upc': product.upc,
                    'name': product.name,
                    'servingGrams': product.servingGrams,
                    'nutritionSource': product.sourceUrl,
                    'addedSugarSource': product.addedSugarSourceUrl,
                    'portionBasis': product.portionBasis,
                    'priceSource': product.priceSourceUrl,
                    'priceObservedAt': product.priceObservedAt
                        ?.toIso8601String(),
                    'priceMappingNote': product.priceMappingNote,
                  },
              ],
              'calories': meal.calories,
              'proteinGrams': meal.proteinGrams,
              'sodiumMg': meal.sodiumMg,
              'addedSugarGrams': meal.products.fold<double>(
                0,
                (sum, p) => sum + p.addedSugarGrams!,
              ),
              'pricePerServing':
                  meal.products.every((p) => p.pricePerServing != null)
                  ? meal.pricePerServing
                  : null,
              'targetSource': context.targets?.sourceUrl,
              'replacedBasketUpcs': meal.replacedBasketUpcs,
              'evidence': meal.claimIds.map(evidence).toList(),
            },
        ],
        'purchaseHistoryNotices': [
          for (final notice in result.historyMessages)
            {
              'message': notice.message,
              'evidence': notice.claimIds.map(evidence).toList(),
            },
        ],
      }),
    );
  } catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}

List<NutritionProduct> readCatalog(File file) {
  final rows = _parseCsv(file.readAsStringSync());
  if (rows.length < 2) {
    throw const FormatException('CSV needs a header and rows.');
  }
  final headers = rows.first;
  final products = <NutritionProduct>[];
  final upcs = <String>{};
  for (final row in rows.skip(1)) {
    if (row.length != headers.length) {
      throw const FormatException('CSV row has a different number of columns.');
    }
    final product = NutritionProduct.fromMap({
      for (var i = 0; i < headers.length; i++) headers[i]: row[i],
    });
    if (product.upc.isEmpty || !upcs.add(product.upc)) {
      throw FormatException('Missing or duplicate UPC: ${product.upc}');
    }
    products.add(product);
  }
  return products;
}

List<List<String>> _parseCsv(String input) {
  final rows = <List<String>>[];
  var row = <String>[];
  var field = StringBuffer();
  var quoted = false;
  for (var i = 0; i < input.length; i++) {
    final char = input[i];
    if (char == '"') {
      if (quoted && i + 1 < input.length && input[i + 1] == '"') {
        field.write('"');
        i++;
      } else {
        quoted = !quoted;
      }
    } else if (char == ',' && !quoted) {
      row.add(field.toString());
      field = StringBuffer();
    } else if ((char == '\n' || char == '\r') && !quoted) {
      if (char == '\r' && i + 1 < input.length && input[i + 1] == '\n') i++;
      row.add(field.toString());
      if (row.any((value) => value.isNotEmpty)) rows.add(row);
      row = [];
      field = StringBuffer();
    } else {
      field.write(char);
    }
  }
  if (quoted) throw const FormatException('Unclosed CSV quote.');
  row.add(field.toString());
  if (row.any((value) => value.isNotEmpty)) rows.add(row);
  return rows;
}
