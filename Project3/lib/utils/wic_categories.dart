/// One name per WIC category, so allowances and same-category swaps do not
/// split across spelling variants in the NC APL.
///
/// The APL's two-digit `categoryCode` is consistent; its `category` text is
/// not (e.g. code 51 is both "MILK - WHOLE" and "MILK-WHOLE"). Names below are
/// the most common spelling per code in the 2026-09-02 APL import.
class WicCategories {
  const WicCategories._();

  static const Map<String, String> nameByCode = {
    '02': 'CHEESE',
    '03': 'EGGS',
    '05': 'BREAKFAST CEREAL',
    '06': 'LEGUMES',
    '08': 'FISH',
    '12': 'INFANT FRUITS & VEGETABLES',
    '13': 'INFANT MEATS',
    '16': 'WW BREAD OR WHOLE GRAINS',
    '19': 'FRUIT & VEGETABLE CVB',
    '21': 'INFANT FORMULA (IF)',
    '31': 'EXEMPT INFANT FORMULA (EXF)',
    '41': 'WIC ELIGIBLE NUTRITIONALS (WEN)',
    '50': 'YOGURT',
    '51': 'MILK - WHOLE',
    '52': 'MILK - FAT REDUCED',
    '54': 'JUICE 64',
  };

  /// Spelling variants that unambiguously mean one category. ("FROZEN" is
  /// only mapped through its code, since the word alone is ambiguous.)
  static const Map<String, String> _variants = {
    'MILK-WHOLE': 'MILK - WHOLE',
    'MILK-FAT REDUCED': 'MILK - FAT REDUCED',
    'MILK- FAT REDUCED': 'MILK - FAT REDUCED',
    'MILK -FAT REDUCED': 'MILK - FAT REDUCED',
    'FRUIT AND VEGETABLE CVB': 'FRUIT & VEGETABLE CVB',
    'BREAD/WHOLE GRAINS': 'WW BREAD OR WHOLE GRAINS',
    'INFANT FRUIT & VEGETABLE': 'INFANT FRUITS & VEGETABLES',
    'INFANT FRUIT VEGETABLE': 'INFANT FRUITS & VEGETABLES',
  };

  /// Trims, collapses whitespace and uppercases.
  static String normalize(Object? raw) => (raw ?? '')
      .toString()
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ')
      .toUpperCase();

  /// The single canonical name for a category, preferring [code] when known.
  static String canonical(Object? name, {Object? code}) {
    final byCode = nameByCode[(code ?? '').toString().trim()];
    if (byCode != null) return byCode;
    final n = normalize(name);
    return _variants[n] ?? n;
  }
}
