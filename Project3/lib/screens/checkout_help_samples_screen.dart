import 'package:flutter/material.dart';

import '../services/checkout_help_repository.dart';
import '../widgets/checkout_help_button.dart';

/// A read-only sample basket for demonstrating the complete per-item help flow.
/// It owns no AppState and cannot add items or replace a shopper's balances.
class CheckoutHelpSamplesScreen extends StatefulWidget {
  const CheckoutHelpSamplesScreen({
    super.key,
    this.repository = const CheckoutHelpRepository(),
  });
  final CheckoutHelpRepository repository;

  @override
  State<CheckoutHelpSamplesScreen> createState() =>
      _CheckoutHelpSamplesScreenState();
}

class _CheckoutHelpSamplesScreenState extends State<CheckoutHelpSamplesScreen> {
  late Future<List<CheckoutHelpExample>> _examples;

  @override
  void initState() {
    super.initState();
    _examples = widget.repository.loadExamples();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sample basket')),
      body: FutureBuilder<List<CheckoutHelpExample>>(
        future: _examples,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sample information could not be loaded.'),
                  TextButton(
                    onPressed: () => setState(() {
                      _examples = widget.repository.loadExamples();
                    }),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'These four basket items use synthetic information. Choose Get checkout help on an item, then Close to return here. Your saved basket and benefits are unchanged.',
                ),
              ),
              for (final example in snapshot.data!) _buildItem(example),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(CheckoutHelpExample example) {
    final line = example.toBasketLine();
    // Match the existing basket's Card/ListTile/button pattern. Samples omit
    // quantity controls and checkout because this basket is read-only.
    return Card(
      key: ValueKey('sample-basket-item-${example.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(line['name'] as String),
              subtitle: Text(
                '${example.title}\nQuantity: ${line['qty']} · Payment category: ${line['category']}',
              ),
            ),
            CheckoutHelpButton.sample(
              line: line,
              repository: widget.repository,
            ),
          ],
        ),
      ),
    );
  }
}
