import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/basket_balance_service.dart';
import '../state/app_state.dart';

/// Opens the M2 basket balance sheet over the current screen.
Future<void> showBasketBalanceSheet(BuildContext context) {
  final app = context.read<AppState>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ChangeNotifierProvider<AppState>.value(
      value: app,
      child: const BasketBalanceSheet(),
    ),
  );
}

/// M2: shows basket-wide nutrient averages and up to three one-swap previews.
///
/// Previews never change the basket. A swap happens only when the shopper
/// taps "Confirm swap", and the report is recalculated afterwards.
class BasketBalanceSheet extends StatefulWidget {
  const BasketBalanceSheet({
    super.key,
    this.service = const BasketBalanceService(),
  });

  /// Analysis engine for previews; confirmed swaps are applied through AppState.
  final BasketBalanceService service;

  @override
  State<BasketBalanceSheet> createState() => _BasketBalanceSheetState();
}

class _BasketBalanceSheetState extends State<BasketBalanceSheet> {
  static const Color _primaryRed = Color(0xFFD1001C);

  Future<Map<String, List<Map<String, dynamic>>>>? _candidates;

  /// Swaps the shopper dismissed with "Not now" while the sheet is open.
  final Set<String> _rejected = {};

  @override
  void initState() {
    super.initState();
    _candidates = _loadCandidates();
  }

  Future<Map<String, List<Map<String, dynamic>>>> _loadCandidates() async {
    final app = context.read<AppState>();
    final categories = {
      for (final line in app.basket)
        BasketBalanceService.canon(line['category']),
    }..removeWhere((c) => c.isEmpty || c == 'PAID');
    final catalog = app.productCatalog;
    return {
      for (final category in categories)
        category: await catalog.balanceCandidates(category),
    };
  }

  void _confirm(SwapSuggestion s) {
    final swapped = context.read<AppState>().swapItem(
      fromUpc: s.fromUpc,
      category: s.category,
      toUpc: s.toUpc,
      toName: s.toName,
      toNutrition: s.toNutrition,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          swapped
              ? 'Swapped ${s.fromName} for ${s.toName}'
              : 'Could not swap ${s.fromName}. Try again.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
          future: _candidates,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load alternatives.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () =>
                          setState(() => _candidates = _loadCandidates()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final report = widget.service.analyze(
              basket: app.basket,
              balances: app.balances,
              candidatesByCategory: snapshot.data ?? const {},
              rejected: _rejected,
            );
            return _buildReport(context, report);
          },
        ),
      ),
    );
  }

  Widget _buildReport(BuildContext context, BasketBalanceReport report) {
    final theme = Theme.of(context);
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Text('Basket balance', style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          'Average per serving across everything in your basket, compared '
          'with example label targets. A basket is not a diet, and these are '
          'not personal nutrition goals.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        for (final s in report.summaries) _buildSummary(context, s, report),
        if (report.message != null) ...[
          const SizedBox(height: 12),
          Text(report.message!, style: theme.textTheme.bodyMedium),
        ],
        if (report.suggestions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Suggested swaps for ${report.focus!.label.toLowerCase()}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final s in report.suggestions) _buildSuggestion(context, s),
        ],
      ],
    );
  }

  Widget _buildSummary(
    BuildContext context,
    NutrientSummary s,
    BasketBalanceReport report,
  ) {
    final t = s.target;
    final average = s.averagePerServing;
    final isFocus = identical(report.focus, t);
    final comparison = t.lowerIsBetter ? 'at most' : 'at least';
    return Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              average == null
                  ? Icons.help_outline
                  : s.gap > 0
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline,
              size: 20,
              color: s.gap > 0 ? _primaryRed : Colors.grey.shade700,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${t.label}: ${average == null ? 'Unknown' : BasketBalanceService.formatAmount(average, t.unit)} per serving'
                    '${isFocus ? ' (largest gap)' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Example target: $comparison '
                    '${BasketBalanceService.formatAmount(t.perServing, t.unit)}. ${t.basis}.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  if (s.incomplete)
                    Text(
                      'Based on ${s.measuredQty} of ${s.totalQty} items; '
                      'the rest have no ${t.label.toLowerCase()} value.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestion(BuildContext context, SwapSuggestion s) {
    final t = s.focus;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Swap ${s.fromName}${s.qty > 1 ? ' (×${s.qty})' : ''} for ${s.toName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Basket ${t.label.toLowerCase()} average: '
              '${BasketBalanceService.formatAmount(s.before, t.unit)} → '
              '${BasketBalanceService.formatAmount(s.after, t.unit)} per serving',
            ),
            for (final note in s.tradeoffs)
              Text(
                'Tradeoff: $note',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
              ),
            if (s.source?['provider'] is String)
              Text(
                'Nutrition data: ${s.source!['provider']}'
                '${s.source!['url'] is String ? ' (${s.source!['url']})' : ''}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => setState(() => _rejected.add(s.key)),
                  child: const Text('Not now'),
                ),
                FilledButton(
                  onPressed: () => _confirm(s),
                  style: FilledButton.styleFrom(backgroundColor: _primaryRed),
                  child: const Text('Confirm swap'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
