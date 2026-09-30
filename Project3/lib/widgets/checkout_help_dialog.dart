import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/checkout_help_repository.dart';
import '../services/checkout_help_service.dart';
import '../state/app_state.dart';

/// Opens information for this exact basket line, never for a saved list index.
/// Reading help does not load, reset, save, or check out application state.
/// [state] is null only for the isolated, read-only sample basket.
Future<void> showCheckoutHelpForItem(
  BuildContext context, {
  required AppState? state,
  required Map<String, dynamic> line,
  required CheckoutHelpRepository repository,
}) async {
  final name = line['name'] is String
      ? line['name'] as String
      : 'Selected item';
  final quantity = line['qty'];
  final classification = line['category'];
  String snapshot() =>
      jsonEncode({'basket': state?.basket, 'balances': state?.balances});
  final openedState = snapshot();
  final evidence = repository.forBasketItem(Map<String, dynamic>.from(line));
  final service = CheckoutHelpService();

  await showDialog<void>(
    context: context,
    builder: (context) => ListenableBuilder(
      // Immutable samples have no state changes to observe. The live basket
      // listens to its existing AppState; no second application state is made.
      listenable: state ?? const AlwaysStoppedAnimation<bool>(true),
      builder: (context, child) {
        // A quantity, allocation, removal, reload, or balance change invalidates
        // the open view. A fresh opening reads current evidence again.
        final stillCurrent =
            state == null ||
            (state.basket.any((entry) => identical(entry, line)) &&
                snapshot() == openedState);
        return FutureBuilder<CheckoutHelpExample?>(
          future: evidence,
          builder: (context, loaded) {
            final example = stillCurrent ? loaded.data : null;
            final loading =
                stillCurrent && loaded.connectionState != ConnectionState.done;
            final result = loading
                ? null
                : service.explain(
                    item: example?.item ?? const {},
                    benefit: example?.benefit ?? const {},
                  );
            final notice = !stillCurrent
                ? 'Your basket or benefit information changed. Close help and reopen it for the current item.'
                : loaded.hasError
                ? 'Help information could not be loaded. You can close this view and try again.'
                : example != null
                ? 'Synthetic example: sizes and balances below are sample information, not your live benefits.'
                : loading
                ? 'Loading help information…'
                : 'Verified product and benefit evidence is not available for this item.';
            return CheckoutHelpDialog(
              itemName: name,
              itemDetails:
                  'Quantity: $quantity · Payment category: $classification',
              notice: notice,
              result: result,
            );
          },
        );
      },
    ),
  );
}

/// The same readable presentation is used for basket help and labeled samples.
/// A scrollable dialog keeps long explanations usable on small screens.
class CheckoutHelpDialog extends StatelessWidget {
  const CheckoutHelpDialog({
    super.key,
    required this.itemName,
    required this.itemDetails,
    required this.notice,
    required this.result,
  });

  final String itemName;
  final String itemDetails;
  final String notice;
  final CheckoutHelpResult? result;

  @override
  Widget build(BuildContext context) {
    final answer = result;
    final cause = switch (answer?.possibleCause) {
      'package_size_mismatch' => 'Possible cause: package-size mismatch',
      'insufficient_category_balance' =>
        'Possible cause: insufficient category balance',
      'outdated_information' => 'Possible cause: outdated information',
      _ => 'Unable to determine the cause',
    };
    return AlertDialog(
      title: const Text('Checkout help'),
      scrollable: true,
      content: SizedBox(
        width: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              itemName,
              key: const ValueKey('checkout-help-item'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(itemDetails),
            const SizedBox(height: 12),
            Text(notice),
            const SizedBox(height: 8),
            const Text('This is guidance, not an official checkout decision.'),
            const SizedBox(height: 16),
            if (answer == null)
              const Center(child: CircularProgressIndicator())
            else ...[
              Text(cause, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(answer.explanation),
              const SizedBox(height: 16),
              Text(
                'Suggested next step',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(answer.suggestedNextStep),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
