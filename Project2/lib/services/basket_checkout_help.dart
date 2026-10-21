import 'apl_service.dart';
import 'checkout_help_service.dart';

/// Explains the app's allocation, never an official WIC benefit decision.
class BasketCheckoutHelp {
  /// Explains whether [line] fits the app allowance represented by [balances].
  ///
  /// Checks positive quantity, category consistency, and allocation totals in
  /// [basket]. Returns `app_included` when those checks support inclusion, or
  /// `app_balance_unknown` when information is insufficient or inconsistent.
  /// Reads the supplied maps without changing them; no official benefits are queried.
  static CheckoutHelpResult explainIncluded({
    required Map<String, dynamic> line,
    required List<Map<String, dynamic>> basket,
    required Map<String, Map<String, dynamic>> balances,
  }) {
    final cat = category(line['category']);
    final balance = balances[cat];
    final allowed = balance?['allowed'];
    final used = balance?['used'];
    final qty = line['qty'];
    final original = category(line['original_benefit_category']);
    var allocated = 0;
    var validRows = true;
    for (final entry in basket.where(
      (entry) => category(entry['category']) == cat,
    )) {
      final quantity = entry['qty'];
      if (quantity is! int || quantity <= 0) {
        validRows = false;
      } else {
        allocated += quantity;
      }
    }
    // Used includes the selected line already: equality with the limit is OK.
    if (cat != null &&
        (original == null || original == cat) &&
        qty is int &&
        qty > 0 &&
        validRows &&
        allocated >= qty &&
        balance != null &&
        balance.containsKey('allowed') &&
        used is int &&
        used >= allocated &&
        (allowed == null || (allowed is int && used <= allowed))) {
      return CheckoutHelpResult(
        possibleCause: 'app_included',
        explanation: allowed == null
            ? 'This item is included in your basket. The demo has no limit set for $cat.'
            : 'This item fits your saved $cat allowance ($used of $allowed items used, including this item).',
        suggestedNextStep: 'You can keep this item in your basket.',
      );
    }
    return const CheckoutHelpResult(
      possibleCause: 'app_balance_unknown',
      explanation:
          'There is not enough consistent balance information to check this item.',
      suggestedNextStep: 'Check your current WIC balance before checkout.',
    );
  }

  /// Returns a trimmed, whitespace-normalized, uppercase category from [value].
  ///
  /// Returns null for non-string, blank, or `PAID` values. This helper does not
  /// map APL spelling variants; PAID is a payment label, not a benefit category.
  static String? category(Object? value) {
    if (value is! String) return null;
    final normalized = value
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toUpperCase();
    return normalized.isEmpty || normalized == 'PAID' ? null : normalized;
  }

  /// Finds [line]'s original benefit category without a catalog lookup.
  ///
  /// Uses its saved `original_benefit_category` first. Otherwise, searches
  /// [basket] for the same nonempty UPC and returns its sole distinct non-PAID
  /// category. Returns null when no unambiguous category can be established.
  static String? originalCategory(
    Map<String, dynamic> line,
    List<Map<String, dynamic>> basket,
  ) {
    final saved = category(line['original_benefit_category']);
    if (saved != null) return saved;
    // Older PAID rows lost their source category. Match by UPC, never by name.
    final matches = basket
        .where(
          (other) =>
              line['upc'] is String &&
              (line['upc'] as String).isNotEmpty &&
              other['upc'] == line['upc'],
        )
        .map((other) => category(other['category']))
        .whereType<String>()
        .toSet();
    return matches.length == 1 ? matches.single : null;
  }

  /// Explains a PAID line using its [originalCategory] and saved [balances].
  ///
  /// A nonnegative integer allowance reached by an integer used count produces
  /// `app_category_limit`. Otherwise returns `app_paid_item` without asserting
  /// why the allocation occurred. Does not change balances or perform payment.
  static CheckoutHelpResult explain({
    required String? originalCategory,
    required Map<String, Map<String, dynamic>> balances,
  }) {
    final balance = balances[originalCategory];
    final allowed = balance?['allowed'];
    final used = balance?['used'];
    const payment =
        'PAID means pay for this item yourself; you have not paid yet.';
    if (allowed is int && allowed >= 0 && used is int && used >= allowed) {
      return CheckoutHelpResult(
        possibleCause: 'app_category_limit',
        explanation:
            'Your $originalCategory allowance is full ($used of $allowed items used). '
            '$payment',
        suggestedNextStep:
            'Remove this extra item or pay for it yourself. '
            'Changing brands will not increase the allowance.',
      );
    }
    return CheckoutHelpResult(
      possibleCause: 'app_paid_item',
      explanation: '$payment The app cannot confirm why it was marked PAID.',
      suggestedNextStep:
          'Check your current WIC balance, then decide whether to keep or remove this item.',
    );
  }

  /// Recovers a legacy PAID row's category through an exact UPC catalog lookup.
  ///
  /// Returns [savedCategory] immediately when supplied. Otherwise, [line]
  /// must contain a nonempty string UPC, and [catalog] must return an eligible
  /// product. Returns null for unavailable data, errors, or an eight-second
  /// timeout. No basket state is written and no substitute is selected.
  static Future<String?> resolveOriginalCategory(
    AplService catalog,
    Map<String, dynamic> line,
    String? savedCategory,
  ) async {
    if (savedCategory != null) return savedCategory;
    final upc = line['upc'];
    if (upc is! String || upc.isEmpty) return null;
    try {
      final product = await catalog
          .findByUpc(upc)
          .timeout(const Duration(seconds: 8));
      return product?['eligible'] == true
          ? category(product?['category'])
          : null;
    } catch (_) {
      return null;
    }
  }
}
