import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'qr_checkout_screen.dart';
import '../widgets/nutritional_badges.dart';
import '../utils/nutritional_utils.dart';

/// Screen displaying the user's current shopping basket with item management.
///
/// Shows all products added via [ScanScreen] with their quantities and
/// provides controls to:
/// - Increment quantity ([AppState.incrementItem])
/// - Decrement quantity ([AppState.decrementItem])
/// - View total item count
///
/// Items are grouped by product (UPC) with quantity controls. When quantity
/// reaches zero, the item is automatically removed from [AppState.basket].
///
/// This screen watches [AppState] for real-time updates when items are
/// modified from other screens or when barcode scanning adds new products.
///
/// Usage: Navigated to via `/basket` route or the basket summary card
/// in [ScanScreen].
class BasketScreen extends StatelessWidget {
  const BasketScreen({super.key});

  static const Color _primaryRed = Color(0xFFD1001C);

  void _showQRDialog(BuildContext context, AppState app) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must click a button to exit
      builder: (ctx) => AlertDialog(
        title: const Center(child: Text('Cashier Handoff')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Present this code to the cashier',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // Dummy QR Image (using a large Icon as a placeholder)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code_2,
                size: 200,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          // Cancel Button (Aborts checkout)
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),

          // Finish Button (Commits the transaction)
          FilledButton(
            onPressed: () async {
              // 1. Perform the actual DB checkout
              await app.checkout();

              // 2. Close the dialog
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }

              // 3. Show success and navigate away
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction Complete! Balances updated.'),
                    backgroundColor: Colors.green,
                  ),
                );

                context.go('/scan');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: _primaryRed, // Match your app theme
            ),
            child: const Text('Finish Transaction'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the AppState and watch for changes
    final app = context.watch<AppState>();

    final basket = app.basket;

    final totalItems = basket.fold<int>(
      0,
      (sum, item) => sum + (item['qty'] as int? ?? 0),
    );

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      // Project 2 M3 UI update:
      // Match the updated Scan screen with a soft neutral background.
      backgroundColor: const Color(0xFFF7F7F8),

      appBar: AppBar(
        title: const Text('My Basket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (context.mounted) {
                context.go('/login');
              }
            },
          ),

          const SizedBox(width: 4),
        ],
      ),

      body: basket.isEmpty
          ? _buildEmptyState(context)
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Project 2 M3 UI update:
                        // Give the basket page the same page hierarchy
                        // as the updated Scan screen.
                        _buildPageHeader(basket.length, totalItems),

                        const SizedBox(height: 24),

                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Existing basket items.
                              Expanded(
                                flex: 7,
                                child: _buildBasketList(basket),
                              ),

                              const SizedBox(width: 24),

                              // Existing checkout actions moved into a
                              // dedicated summary card on desktop.
                              SizedBox(
                                width: 320,
                                child: _buildCheckoutSummary(
                                  context,
                                  app,
                                  totalItems,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildBasketList(basket),

                          const SizedBox(height: 20),

                          _buildCheckoutSummary(context, app, totalItems),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  /// Builds the page heading shown above the basket contents.
  ///
  /// This is a presentation update only and does not change basket state.
  Widget _buildPageHeader(int uniqueItems, int totalItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your basket',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF222222),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          totalItems == 1
              ? 'You currently have 1 item in your basket.'
              : 'You currently have $totalItems items in your basket.',
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Colors.grey.shade700,
          ),
        ),

        if (uniqueItems > 1) ...[
          const SizedBox(height: 4),

          Text(
            '$uniqueItems different products',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ],
    );
  }

  /// Builds the current list of basket items.
  ///
  /// Each item continues to use [_BasketItem] for quantity and nutrition
  /// management.
  Widget _buildBasketList(List<Map<String, dynamic>> basket) {
    return Column(
      children: [
        for (int index = 0; index < basket.length; index++) ...[
          _BasketItem(item: basket[index], index: index),

          if (index != basket.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  /// Builds the checkout summary and existing basket actions.
  ///
  /// The checkout destination and clear-cart behavior remain unchanged.
  Widget _buildCheckoutSummary(
    BuildContext context,
    AppState app,
    int totalItems,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.shopping_cart_checkout, color: _primaryRed),

                SizedBox(width: 10),

                Text(
                  'Basket Summary',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total items',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),

                Text(
                  '$totalItems',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _primaryRed,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Divider(color: Colors.grey.shade200),

            const SizedBox(height: 14),

            const Text(
              'Ready when you are',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            Text(
              'Review your products and nutrition information '
              'before continuing to checkout.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            // Existing checkout navigation.
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => const QRCheckoutScreen(),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: _primaryRed,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.qr_code),
              label: const Text('Ready to Checkout'),
            ),

            const SizedBox(height: 10),

            // Existing clear basket action.
            OutlinedButton.icon(
              onPressed: () {
                _showClearBasketDialog(context, app);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryRed,
                side: BorderSide(color: _primaryRed.withValues(alpha: 0.4)),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear Basket'),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the existing clear-cart confirmation in an updated dialog style.
  void _showClearBasketDialog(BuildContext context, AppState app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: _primaryRed),

            SizedBox(width: 10),

            Text('Clear Cart?'),
          ],
        ),
        content: const Text('This will remove all items from your basket.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),

          FilledButton(
            onPressed: () {
              app.clearBasket();
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: _primaryRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  /// Builds the UI shown when the basket is empty.
  ///
  /// Displays a centered message with an icon encouraging the user to
  /// scan products. Provides a button to navigate back to [ScanScreen].
  Widget _buildEmptyState(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 42,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: _primaryRed.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.shopping_basket_outlined,
                        size: 42,
                        color: _primaryRed,
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Your basket is empty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Scan a product to check its WIC eligibility '
                      'and add it to your basket.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 26),

                    FilledButton.icon(
                      onPressed: () => context.go('/scan'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _primaryRed,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Start Scanning'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual basket item tile with quantity controls.
///
/// Displays product information from [item] map:
/// - Name
/// - Category
/// - Current quantity
///
/// Provides increment/decrement buttons that call [AppState.incrementItem]
/// and [AppState.decrementItem] respectively. Buttons are styled with
/// visual feedback and disabled states based on category limits.
class _BasketItem extends StatefulWidget {
  const _BasketItem({required this.item, required this.index});

  /// The basket item data map containing 'upc', 'name', 'category', and 'qty'.
  final Map<String, dynamic> item;

  final int index;

  @override
  State<_BasketItem> createState() => _BasketItemState();
}

class _BasketItemState extends State<_BasketItem> {
  static const Color _primaryRed = Color(0xFFD1001C);

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final upc = widget.item['upc'] as String? ?? '';

    final name = widget.item['name'] as String? ?? 'Unknown';

    String category = widget.item['category'] as String? ?? 'Unknown';

    final qty = widget.item['qty'] as int? ?? 0;

    final canAdd = appState.canAdd(category);

    // Generate nutritional data if not present
    final nutrition =
        widget.item['nutrition'] as Map<String, dynamic>? ??
        const {
          'calories': 0.0,
          'totalFat': 0.0,
          'saturatedFat': 0.0,
          'transFat': 0.0,
          'sodium': 0.0,
          'sugar': 0.0,
          'addedSugar': 0.0,
          'protein': 0.0,
          'fiber': 0.0,
        };

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project 2 M3 UI update:
                    // Replace the old quantity avatar with a consistent
                    // product icon. Quantity now appears in the controls.
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _primaryRed.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: _primaryRed,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF222222),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          if (upc.isNotEmpty) ...[
                            const SizedBox(height: 3),

                            Text(
                              'UPC $upc',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Existing increment/decrement behavior displayed
                    // as a more compact quantity selector.
                    _buildQuantityControls(
                      appState,
                      upc,
                      category,
                      qty,
                      canAdd,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                NutritionalBadgesCompact(nutrition: nutrition),

                const SizedBox(height: 14),

                // Expandable nutritional info section
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu_outlined,
                          size: 18,
                          color: _primaryRed,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          _expanded
                              ? 'Hide nutrition details'
                              : 'View nutrition details',
                          style: const TextStyle(
                            color: _primaryRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),

                        const Spacer(),

                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: _primaryRed,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_expanded) _buildNutritionPanel(nutrition),
        ],
      ),
    );
  }

  /// Builds the quantity controls using the existing increment/decrement logic.
  Widget _buildQuantityControls(
    AppState appState,
    String upc,
    String category,
    int qty,
    bool canAdd,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            color: _primaryRed,
            onPressed: () => appState.decrementItem(upc, category),
            tooltip: 'Remove one',
          ),

          Container(
            constraints: const BoxConstraints(minWidth: 30),
            alignment: Alignment.center,
            child: Text(
              '$qty',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
          ),

          // Increment button
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            color: _primaryRed,
            onPressed: () => appState.incrementItem(upc, category),
            tooltip: canAdd ? 'Add one' : 'Will add as paid',
          ),
        ],
      ),
    );
  }

  /// Builds the expanded nutrition section for an item.
  ///
  /// Uses the same basket nutrition data that was previously displayed in
  /// the expandable section.
  Widget _buildNutritionPanel(Map<String, dynamic> nutrition) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F9),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Facts',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const Divider(height: 22),

          _NutritionRow(
            label: 'Calories',
            value: '${nutrition['calories']} cal',
            bold: true,
          ),

          const SizedBox(height: 8),

          _NutritionRow(label: 'Total Fat', value: '${nutrition['totalFat']}g'),

          const SizedBox(height: 8),

          _NutritionRow(
            label: 'Saturated Fat',
            value: '${nutrition['saturatedFat']}g',
            indent: true,
          ),

          const SizedBox(height: 8),

          _NutritionRow(label: 'Sodium', value: '${nutrition['sodium']}mg'),

          const SizedBox(height: 8),

          _NutritionRow(label: 'Total Sugars', value: '${nutrition['sugar']}g'),

          const SizedBox(height: 8),

          _NutritionRow(label: 'Protein', value: '${nutrition['protein']}g'),

          const SizedBox(height: 8),

          _NutritionRow(label: 'Fiber', value: '${nutrition['fiber']}g'),
        ],
      ),
    );
  }
}

/// Helper widget to display a nutrition fact row
class _NutritionRow extends StatelessWidget {
  const _NutritionRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.indent = false,
  });

  final String label;

  final String value;

  final bool bold;

  final bool indent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indent ? 12 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: indent ? 13 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: indent ? Colors.grey.shade700 : Colors.black,
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
