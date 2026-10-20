import 'package:flutter/material.dart';

import '../services/checkout_help_repository.dart';
import '../state/app_state.dart';
import 'checkout_help_dialog.dart';

/// The small integration point for checkout help on a basket item.
/// Keep the loading and dialog behavior here so the basket layout stays simple.
class CheckoutHelpButton extends StatefulWidget {
  const CheckoutHelpButton({
    super.key,
    required this.line,
    required AppState state,
    this.repository = const CheckoutHelpRepository(),
  }) : _state = state;

  /// Samples are immutable, separate basket lines with no shopper state.
  /// They use the synthetic evidence service and shared dialog; ordinary
  /// basket lines receive separate app-allowance explanations.
  const CheckoutHelpButton.sample({
    super.key,
    required this.line,
    this.repository = const CheckoutHelpRepository(),
  }) : _state = null;

  /// Exact basket-line map used to detect stale help and identify the selected product.
  final Map<String, dynamic> line;

  /// Repository used only to retrieve explicitly opted-in synthetic evidence.
  final CheckoutHelpRepository repository;
  final AppState? _state;

  @override
  State<CheckoutHelpButton> createState() => _CheckoutHelpButtonState();
}

class _CheckoutHelpButtonState extends State<CheckoutHelpButton> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Get checkout help for ${widget.line['name'] ?? 'this item'}',
      child: TextButton.icon(
        icon: const Icon(Icons.help_outline),
        label: const Text('Get checkout help'),
        onPressed: _open
            ? null
            : () async {
                // Block rapid repeated taps until this dialog has closed.
                if (_open) return;
                setState(() => _open = true);
                try {
                  await showCheckoutHelpForItem(
                    context,
                    state: widget._state,
                    line: widget.line,
                    repository: widget.repository,
                  );
                } finally {
                  if (mounted) setState(() => _open = false);
                }
              },
      ),
    );
  }
}
