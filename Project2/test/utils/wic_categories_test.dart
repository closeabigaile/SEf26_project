import 'package:flutter_test/flutter_test.dart';
import 'package:wolfbite/utils/wic_categories.dart';

void main() {
  group('WicCategories.canonical', () {
    test('category code wins over the text', () {
      expect(WicCategories.canonical('MILK-WHOLE', code: '51'), 'MILK - WHOLE');
      expect(
        WicCategories.canonical('FROZEN', code: '19'),
        'FRUIT & VEGETABLE CVB',
      );
    });

    test('every spelling seen in the live APL maps to one name per code', () {
      const variants = {
        '12': [
          'INFANT FRUITS & VEGETABLES',
          'INFANT FRUIT & VEGETABLE',
          'INFANT FRUIT VEGETABLE',
        ],
        '16': ['WW BREAD OR WHOLE GRAINS', 'BREAD/WHOLE GRAINS'],
        '19': ['FRUIT & VEGETABLE CVB', 'FRUIT AND VEGETABLE CVB'],
        '51': ['MILK - WHOLE', 'MILK-WHOLE'],
        '52': ['MILK - FAT REDUCED', 'MILK-FAT REDUCED', 'MILK- FAT REDUCED'],
      };
      variants.forEach((code, names) {
        for (final name in names) {
          expect(
            WicCategories.canonical(name),
            WicCategories.nameByCode[code],
            reason: '$name without its code',
          );
        }
      });
    });

    test('normalizes case and whitespace and keeps unknown names', () {
      expect(WicCategories.canonical('  milk-whole '), 'MILK - WHOLE');
      expect(WicCategories.canonical('Cereal'), 'CEREAL');
      expect(WicCategories.canonical('paid'), 'PAID');
      expect(WicCategories.canonical(null), '');
    });

    test('an ambiguous word is only mapped through its code', () {
      expect(WicCategories.canonical('FROZEN'), 'FROZEN');
    });
  });
}
