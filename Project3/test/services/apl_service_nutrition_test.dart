// AplService with the separate nutrition/{upc} collection, using real APL
// records and Open Food Facts nutrition from test/fixtures/m2_real_sample.json.
import 'dart:convert';
import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wolfbite/services/apl_service.dart';

final _fixture =
    jsonDecode(File('test/fixtures/m2_real_sample.json').readAsStringSync())
        as Map<String, dynamic>;

const _vanillaYogurt = '070253640353'; // 17 g added sugar
const _greekYogurt = '894700010199'; // 0 g added sugar
const _activia = '036632029393';
const _cornFlakes = '003800000120'; // real APL record, no nutrition anywhere

Future<FakeFirebaseFirestore> _seed({bool nutrition = true}) async {
  final db = FakeFirebaseFirestore();
  for (final doc in (_fixture['apl'] as List).cast<Map<String, dynamic>>()) {
    await db.collection('apl').doc(doc['upc'] as String).set(doc);
  }
  if (nutrition) {
    for (final doc
        in (_fixture['nutrition'] as List).cast<Map<String, dynamic>>()) {
      await db.collection('nutrition').doc(doc['upc'] as String).set(doc);
    }
  }
  return db;
}

double? _nutrient(Map<String, dynamic> product, String name) {
  final match = (product['foodNutrients'] as List?)
      ?.cast<Map<String, dynamic>>()
      .where((n) => n['name'] == name);
  return match == null || match.isEmpty
      ? null
      : (match.first['amount'] as num).toDouble();
}

void main() {
  group('findByUpc', () {
    test(
      'merges nutrition/{upc} into an APL record without nutrients',
      () async {
        final service = AplService(db: await _seed());
        final product = (await service.findByUpc(_vanillaYogurt))!;
        expect(product['name'], 'OUR FAMILY NONFAT YOGURT VANILLA 32 OZ');
        expect(product['eligible'], isTrue);
        expect(_nutrient(product, 'Sugars, added'), 17);
        expect(_nutrient(product, 'Sodium, Na'), 169);
        expect(product['servingBasis'], startsWith('per serving'));
        expect(product['nutritionSource']['provider'], 'Open Food Facts');
      },
    );

    test('leaves nutrition unknown when no nutrition doc exists', () async {
      final service = AplService(db: await _seed());
      final product = (await service.findByUpc(_cornFlakes))!;
      expect(product['foodNutrients'], isNull);
      expect(product['nutritionSource'], isNull);
    });

    test('returns a canonical category and keeps the source text', () async {
      final variant = (_fixture['apl'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((d) => d['category'] == 'MILK-FAT REDUCED');
      final service = AplService(db: await _seed());
      final product = (await service.findByUpc(variant['upc'] as String))!;
      expect(product['category'], 'MILK - FAT REDUCED');
      expect(product['sourceCategory'], 'MILK-FAT REDUCED');
    });

    test('unknown UPC is still null', () async {
      final service = AplService(db: await _seed());
      expect(await service.findByUpc('000'), isNull);
    });
  });

  group('balanceCandidates', () {
    test(
      'returns eligible same-category products that have nutrition',
      () async {
        final service = AplService(db: await _seed());
        final candidates = await service.balanceCandidates('YOGURT');
        expect(candidates.map((c) => c['upc']).toSet(), {
          _vanillaYogurt,
          _greekYogurt,
          _activia,
        });
        final greek = candidates.singleWhere((c) => c['upc'] == _greekYogurt);
        expect(greek['eligible'], isTrue);
        expect(greek['category'], 'YOGURT');
        expect(greek['nutrition']['addedSugar'], 0);
        expect(greek['source']['provider'], 'Open Food Facts');
      },
    );

    test('excludes nutrition docs whose APL record is not eligible', () async {
      final db = await _seed();
      await db.collection('apl').doc(_activia).update({'eligible': false});
      final candidates = await AplService(db: db).balanceCandidates('YOGURT');
      expect(candidates.map((c) => c['upc']), isNot(contains(_activia)));
    });

    test('excludes nutrition docs with no APL record at all', () async {
      final db = await _seed();
      await db.collection('apl').doc(_greekYogurt).delete();
      final candidates = await AplService(db: db).balanceCandidates('YOGURT');
      expect(candidates.map((c) => c['upc']), isNot(contains(_greekYogurt)));
    });

    test('is empty when no product in the category has nutrition', () async {
      final service = AplService(db: await _seed(nutrition: false));
      expect(await service.balanceCandidates('BREAKFAST CEREAL'), isEmpty);
    });
  });

  group('healthierSubstitutes', () {
    test(
      'offers measured products from nutrition/, never unknown ones',
      () async {
        final service = AplService(db: await _seed());
        final base = (await service.findByUpc(_vanillaYogurt))!;
        final results = await service.healthierSubstitutes(
          category: base['category'] as String,
          baseProduct: base,
        );
        expect(results, isNotEmpty);
        expect(results.map((r) => r['upc']), contains(_greekYogurt));
        for (final r in results) {
          expect(r['foodNutrients'], isNotEmpty);
        }
      },
    );

    test(
      'a scanned item with no nutrition gets no "healthier" claims',
      () async {
        final service = AplService(db: await _seed());
        final base = (await service.findByUpc(_cornFlakes))!;
        expect(
          await service.healthierSubstitutes(
            category: base['category'] as String,
            baseProduct: base,
          ),
          isEmpty,
        );
      },
    );
  });
}
