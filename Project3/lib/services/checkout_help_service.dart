/// The information returned after checking an item's checkout-help evidence.
///
/// This class holds an answer; it does not decide what the answer should be.
/// The screen can read these three fields to display help to the shopper.
class CheckoutHelpResult {
  /// A label for code and tests, such as 'package_size_mismatch'.
  final String possibleCause;

  /// The friendly explanation shown to the shopper.
  final String explanation;

  /// Advice for the shopper. Returning this text does not perform the action.
  final String suggestedNextStep;

  /// Creates a result.
  const CheckoutHelpResult({
    required this.possibleCause,
    required this.explanation,
    required this.suggestedNextStep,
  });
}

/// Explains a possible checkout rejection using the supplied mock evidence.
///
/// This is M4 Issue 2's logic. The basket button and display belong to Issue 3.
/// No Firebase or Flutter imports are needed: this service only reads inputs
/// and creates a result. It never changes records, balances, or basket items.
///
/// References, from the repository root:
/// - Project3/assets/mock/checkout_help_scenarios.json
/// - Project2_Work/M0/m4_checkout_help_use_cases.md
/// - Project2_Work/M4/README.md
///
/// Results describe possible causes, never official checkout decisions.
class CheckoutHelpService {
  /// Examines the affected [item] and its mock [benefit] evidence.
  ///
  /// Pass the fixture's `input.item` and `input.benefit` maps separately.
  /// A `Map<String, dynamic>` holds text keys with values of different types.
  /// Missing keys return null; they are not treated as zero or false.
  ///
  /// This method needs no `async`: all evidence is already supplied.
  /// It does not load fixtures or use scenario IDs or expected answers.
  ///
  /// Example, using decoded fixture input maps:
  /// ```dart
  /// final service = CheckoutHelpService();
  /// final result = service.explain(item: item, benefit: benefit);
  /// print(result.explanation);
  /// ```
  CheckoutHelpResult explain({
    required Map<String, dynamic> item,
    required Map<String, dynamic> benefit,
  }) {
    // 1. Read freshness and category information.
    final itemFreshness = item['information_freshness'];
    final benefitFreshness = benefit['information_freshness'];
    final replacement = benefit['verified_current_replacement_available'];
    final category = _readCategory(item['original_benefit_category']);
    final benefitCategory = _readCategory(benefit['category']);

    // Reject malformed statuses or a known category conflict. Missing or
    // 'unknown' freshness is allowed here, but cannot prove records are current.
    if (!_isFreshnessStatus(itemFreshness) ||
        !_isFreshnessStatus(benefitFreshness) ||
        (replacement != null && replacement is! bool) ||
        (category != null &&
            benefitCategory != null &&
            category.toUpperCase() != benefitCategory.toUpperCase())) {
      return _unableToDetermine;
    }

    // 2. Check explicitly outdated evidence before comparing sizes or balances.
    if (itemFreshness == 'outdated' || benefitFreshness == 'outdated') {
      // The shared outdated scenario requires no verified current replacement.
      if (replacement != false) return _unableToDetermine;
      return _outdatedInformation;
    }

    // 3. Size and balance explanations need current, covered, matching records.
    // Use the original category even when the basket line is marked 'PAID'.
    // A separate replacement record is outside this method's two inputs; if
    // one is flagged, ask for verification instead of choosing between records.
    if (itemFreshness != 'current' ||
        benefitFreshness != 'current' ||
        category == null ||
        benefitCategory == null ||
        benefit['category_covered'] != true ||
        replacement == true) {
      return _unableToDetermine;
    }

    final quantity = _readNumber(item['quantity']);
    final requiredUnits = _readNumber(benefit['required_units']);
    final availableUnits = _readNumber(
      benefit['available_units_after_other_allocations'],
    );
    final allocatedUnits = _readNumber(
      benefit['units_allocated_to_affected_item'],
    );

    // Package quantities must be positive whole numbers. Benefit amounts use the
    // fixture's mock unit. This first version explains unallocated items, as in
    // the shared cases. Existing or unknown allocations need more context, so use the fallback.
    if (quantity == null ||
        quantity <= 0 ||
        quantity % 1 != 0 ||
        requiredUnits == null ||
        requiredUnits <= 0 ||
        availableUnits == null ||
        allocatedUnits != 0 ||
        benefit['unit'] != 'mock_benefit_unit') {
      return _unableToDetermine;
    }

    final packageSize = item['package_size'];
    final permittedSize = benefit['permitted_package_size'];

    // Check before reading nested keys so malformed input produces
    // helpful fallback text instead of an exception.
    if (packageSize is! Map || permittedSize is! Map) {
      return _unableToDetermine;
    }
    final selectedValue = _readNumber(packageSize['value']);
    final permittedValue = _readNumber(permittedSize['value']);
    final selectedUnit = _readSizeUnit(packageSize['unit']);
    final permittedUnit = _readSizeUnit(permittedSize['unit']);

    // Compare like units only. This service does not convert oz to g,
    // for example. Unknown or incompatible units cannot establish a mismatch.
    if (selectedValue == null ||
        selectedValue <= 0 ||
        permittedValue == null ||
        permittedValue <= 0 ||
        selectedUnit == null ||
        permittedUnit == null ||
        selectedUnit.toLowerCase() != permittedUnit.toLowerCase()) {
      return _unableToDetermine;
    }

    // 4. Consider both rules together. Required units already cover the whole
    // line, and availability is already after other allocations. Do not
    // multiply by quantity or subtract allocations a second time.
    final sizeComparison = _compareAmounts(selectedValue, permittedValue);
    final balanceComparison = _compareAmounts(requiredUnits, availableUnits);
    if (sizeComparison == null || balanceComparison == null) {
      return _unableToDetermine;
    }
    final sizeMismatch = sizeComparison != 0;
    final balanceShortfall = balanceComparison > 0;

    // Both true: two competing explanations. Both false: neither explains it.
    // In either situation, the evidence cannot identify one clear cause.
    if (sizeMismatch == balanceShortfall) return _unableToDetermine;

    // 5. Build the supported explanation using the supplied evidence.
    if (sizeMismatch) {
      final selected = '${_formatNumber(selectedValue)} $selectedUnit';
      final permitted = '${_formatNumber(permittedValue)} $permittedUnit';
      // This wording works for any size without choosing "a" or "an"
      // based on a particular number from the example data.
      return CheckoutHelpResult(
        possibleCause: 'package_size_mismatch',
        explanation:
            'Possible cause: this package is $selected, while the benefit '
            'information available here lists a permitted package size of '
            '$permitted. '
            'This may explain the rejection; it is not the checkout '
            "system's official reason.",
        suggestedNextStep:
            'Check the package label against current benefit information '
            'and look for an otherwise eligible $permitted package.',
      );
    }

    final categoryName = category.toLowerCase();
    final available = _formatUnits(availableUnits);
    final required = _formatUnits(requiredUnits);
    final zeroBalanceAdvice = availableUnits == 0
        ? ' With zero units available for this item, a same-category '
              'substitution alone should not be presented as restoring coverage.'
        : '';
    return CheckoutHelpResult(
      possibleCause: 'insufficient_category_balance',
      explanation:
          'Possible cause: the available $categoryName balance is $available, '
          'and this item needs $required. There may not be enough benefit '
          'balance to cover it. This is not the checkout '
          "system's official reason.",
      suggestedNextStep:
          'Review the current $categoryName balance and reduce the quantity '
          'intended for benefit coverage to fit it.$zeroBalanceAdvice',
    );
  }

  /// Accepts the documented freshness labels, including unavailable evidence.
  bool _isFreshnessStatus(dynamic value) {
    return value == null ||
        value == 'current' ||
        value == 'outdated' ||
        value == 'unknown';
  }

  /// Reads nonempty text safely. `String?` means text OR null may be returned.
  String? _readText(dynamic value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }

  /// Payment classifications and missing-value labels are not benefit rules.
  /// Keep legitimate category names open-ended; the upstream record must still
  /// explicitly establish coverage and match the item's original category.
  String? _readCategory(dynamic value) {
    final text = _readText(value)?.replaceAll(RegExp(r'\s+'), ' ');
    const unavailable = {
      'PAID',
      'UNKNOWN',
      'UNCLASSIFIED',
      'UNSPECIFIED',
      'NONE',
      'NULL',
      'N/A',
    };
    if (text == null || unavailable.contains(text.toUpperCase())) return null;
    return text;
  }

  /// These are the size units this service understands. Equal unknown labels
  /// do not establish a measurement. Different units still need conversion
  /// by an evidence provider; this service never guesses a conversion.
  String? _readSizeUnit(dynamic value) {
    final text = _readText(value)?.replaceAll(RegExp(r'\s+'), ' ');
    const supported = {'oz', 'lb', 'g', 'kg', 'fl oz', 'ml', 'l', 'count'};
    if (text == null || !supported.contains(text.toLowerCase())) return null;
    return text;
  }

  /// Decimal evidence is compared at 15 significant decimal digits, rather
  /// than at a fixed number of decimal places. This removes typical binary
  /// arithmetic noise (0.1 + 0.2) without rounding tiny balances to zero.
  /// Integer-to-integer comparisons remain exact, including large counts.
  /// This is a data precision policy, not a tolerance for benefit eligibility.
  int? _compareAmounts(num left, num right) {
    if (left is int && right is int) return left.compareTo(right);
    final a = _decimalAmount(left);
    final b = _decimalAmount(right);
    if (!a.isFinite || !b.isFinite) return null;
    return a.compareTo(b);
  }

  num _decimalAmount(num value) {
    return value is int ? value : num.parse(value.toStringAsPrecision(15));
  }

  /// Accepts nonnegative, finite numbers. Numeric strings such as '1' are not
  /// silently converted. Infinity, NaN, and negative values are unusable here.
  /// `num` accepts both integers (1) and decimal numbers (1.5).
  num? _readNumber(dynamic value) {
    if (value is! num || !value.isFinite || value < 0) return null;
    return value;
  }

  /// Displays whole numbers as '18' instead of '18.0', keeping decimals intact.
  String _formatNumber(num value) {
    // A floating-point -0.0 represents the same available amount as zero.
    if (value == 0) return '0';
    // Remove only the display suffix. Converting a large double to an int
    // can overflow and silently change the amount shown to the shopper.
    final normalized = _decimalAmount(value);
    final text = (normalized.isFinite ? normalized : value).toString();
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  /// Uses '1 unit' and '0 units' so messages read naturally.
  String _formatUnits(num value) {
    final label = value == 1 ? 'unit' : 'units';
    return '${_formatNumber(value)} $label';
  }

  // `static const` lets all calls share these fixed, unchangeable results.
  // Only explicit outdated evidence supports this first message. Unknown
  // freshness alone must use the fallback below.
  static const _outdatedInformation = CheckoutHelpResult(
    possibleCause: 'outdated_information',
    explanation:
        'Possible cause: the product or benefit information available here '
        'may be outdated. WolfBite is unable to determine why checkout rejected '
        "this item. This is not the checkout system's official reason.",
    suggestedNextStep:
        "Verify current product and benefit information through the shopper's "
        'benefit information source, or ask the cashier to check before '
        'retrying. This does not assume WolfBite already provides a refresh '
        'feature.',
  );

  // 6. Shared fallback for missing, ambiguous, conflicting, or invalid evidence.
  static const _unableToDetermine = CheckoutHelpResult(
    possibleCause: 'unable_to_determine',
    explanation:
        'Unable to determine a possible cause from the information available. '
        "WolfBite does not have the checkout system's official rejection reason.",
    suggestedNextStep:
        'Ask the cashier to check the item and consult current benefit '
        'information before retrying.',
  );
}
