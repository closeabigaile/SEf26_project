import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../services/apl_service.dart';
import 'receipt_scanner_screen.dart';
import '../widgets/nutritional_badges.dart';
import '../utils/nutritional_utils.dart';

/// Barcode scanning screen for WIC eligibility checking.
///
/// Features:
/// - Live camera barcode scanning on mobile devices
/// - Manual UPC entry via text field on desktop
/// - WIC eligibility verification via [AplService]
/// - Add eligible items to shopping basket
/// - Diagnostic test for Firestore connectivity
///
/// Uses [MobileScanner] widget for camera-based scanning.
/// Falls back to text input on web/desktop platforms.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, this.aplService, this.auth});

  final AplService? aplService;
  final FirebaseAuth? auth;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const Color _primaryRed = Color(0xFFD1001C);

  final _input = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  late final AplService _apl;
  late final FirebaseAuth _auth;

  String? _lastScanned;
  Map<String, dynamic>? _lastInfo;
  bool _busy = false;

  List<Map<String, dynamic>>? _healthierOptions;
  bool _loadingHealthier = false;

  @override
  void initState() {
    super.initState();
    _apl = widget.aplService ?? AplService();
    _auth = widget.auth ?? FirebaseAuth.instance;
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  /// Shows a [SnackBar] with the provided message.
  ///
  /// Checks [mounted] before showing to prevent errors after disposal.
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // --- New Function to Show Scanner in Dialog ---
  void _showScanDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          title: const Row(
            children: [
              Icon(Icons.qr_code_scanner, color: _primaryRed),
              SizedBox(width: 10),
              Text('Scan Barcode'),
            ],
          ),
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Center the product barcode inside the camera view.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: MobileScanner(
                      // Using a minimal callback that navigates away immediately upon detection
                      onDetect: (capture) {
                        final barcode = capture.barcodes.firstOrNull;

                        if (barcode?.rawValue != null) {
                          // Pass the scanned value back to the main screen
                          _checkEligibility(barcode!.rawValue!);

                          // Close the dialog immediately
                          Navigator.of(context).pop();

                          // Update the text field for visual confirmation
                          _input.text = barcode.rawValue!;
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Tests Firestore connectivity by querying a known UPC.
  ///
  /// Uses test UPC `000000743266` to verify [AplService] can read from Firestore.
  /// Displays success or error message via [_snack].
  // Future<void> _diagnose() async {
  //   const testUpc = '000000743266';
  //   try {
  //     final info = await _apl.findByUpc(testUpc);
  //     if (!mounted) return;
  //     _snack(
  //       info == null
  //           ? 'Firestore MISSING: $testUpc'
  //           : 'Firestore OK: $testUpc → ${info['name']}',
  //     );
  //   } catch (e) {
  //     _snack('Firestore ERROR: $e');
  //   }
  // }

  /// Checks WIC eligibility for the scanned/entered barcode.
  ///
  /// Process:
  /// 1. Validates UPC format
  /// 2. Queries Firestore APL via [AplService.findByUpc]
  /// 3. Displays product info and eligibility status
  ///
  /// Does NOT add item to basket - use [_addToBasket] for that.
  /// Sets [_busy] to prevent concurrent scans.
  Future<void> _checkEligibility(String code) async {
    final upc = code.trim();

    if (upc.isEmpty || _busy) return;

    _busy = true;

    try {
      final info = await _apl.findByUpc(upc);

      if (!mounted) return;

      if (info == null) {
        _snack('UPC $upc not found in APL');

        setState(() {
          _lastScanned = upc;
          _lastInfo = null;
        });

        return;
      }

      setState(() {
        _lastScanned = upc;
        _lastInfo = info;
      });

      _loadHealthierOptions();

      final name = info['name'] ?? 'Unknown';
      final cat = info['category'] ?? '?';

      //_snack('$name ($cat) - Eligible!');
    } catch (e) {
      _snack('Error: $e');
    } finally {
      _busy = false;
    }
  }

  /// Adds the currently scanned item to the shopping basket.
  ///
  /// Requires [_lastInfo] to be set (item must be scanned/checked first).
  /// Extracts [upc], [name], and [category] from [_lastInfo] and passes them
  /// to [AppState.addItem] as named parameters.
  ///
  /// Shows confirmation [SnackBar] after successful addition.
  void _addToBasket() {
    if (_lastInfo == null) {
      _snack('No item scanned yet');
      return;
    }

    final appState = context.read<AppState>();

    String category = _lastInfo!['category'] ?? 'Unknown';

    final nutrition = NutritionalUtils.buildNutritionFromFoodNutrients(
      _lastInfo!,
    );

    // Check if item can be added
    if (!appState.canAdd(category)) {
      category = 'Paid';
    }

    appState.addItem(
      upc: _lastScanned ?? '',
      name: _lastInfo!['name'] ?? 'Unknown',
      category: category,
      nutrition: nutrition,
    );

    _snack('Added ${_lastInfo!['name']} to basket');

    // Clear the scanned item after adding
    setState(() {
      _lastScanned = null;
      _lastInfo = null;
      _input.clear();
    });
  }

  /// Loads healthier substitute options for the currently scanned product.
  ///
  /// Requires [_lastInfo] to describe a valid product, including a non-empty
  /// category field, otherwise the function returns early without changes.
  ///
  /// Calls the APL backend to fetch up to [max] healthier substitutes in the
  /// same category via healthierSubstitutes, then stores the results in
  /// [_healthierOptions] and toggles [_loadingHealthier] to drive the UI.
  ///
  /// If no options are returned or an error occurs, shows a [SnackBar] message
  /// indicating either that no healthier alternatives are available or that
  /// an error occurred while loading them.
  Future<void> _loadHealthierOptions() async {
    if (_lastInfo == null) return;

    final category = (_lastInfo!['category'] ?? '') as String;

    if (category.isEmpty) return;

    setState(() {
      _loadingHealthier = true;
      _healthierOptions = null;
    });

    try {
      final options = await _apl.healthierSubstitutes(
        category: category,
        baseProduct: _lastInfo!,
        max: 5,
      );

      if (!mounted) return;

      if (options.isEmpty) {
        _snack('No healthier alternatives available.');
      }

      setState(() {
        _healthierOptions = options;
      });
    } catch (e) {
      if (!mounted) return;

      _snack('Error loading healthier options: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loadingHealthier = false;
        });
      }
    }
  }

  /// Shows a modal bottom sheet listing healthier substitute options for the
  /// currently loaded product in [_healthierOptions].
  ///
  /// Requires [_healthierOptions] to be non-null and non-empty; otherwise the
  /// function returns immediately and no sheet is shown.
  ///
  /// Presents each alternative with name, category, UPC, and a computed health
  /// score where lower (more negative) values indicate healthier choices
  /// based on penalties (sugar, fat, sodium) and bonuses (fiber, protein).
  ///
  /// Allows the user to add a selected healthier item to the shopping basket
  /// via [AppState.addItem], and shows a confirmation [SnackBar] on success.
  void _showHealthierOptions() {
    if (_healthierOptions == null || _healthierOptions!.isEmpty) return;

    final appState = context.read<AppState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Row(
                    children: [
                      Icon(Icons.eco, color: Colors.green),
                      SizedBox(width: 10),
                      Text(
                        'Healthier Alternatives',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _primaryRed,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Health score is based on penalties (sugar, fat, and sodium) '
                    'and bonuses (fiber and protein).\nLower scores indicate '
                    'healthier choices.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  ..._healthierOptions!.map((item) {
                    final name = item['name'] ?? 'Unknown';
                    final cat = item['category'] ?? '';
                    final upc = item['upc'] ?? '';

                    final score = (item['healthScore'] is num)
                        ? (item['healthScore'] as num).toStringAsFixed(1)
                        : '-';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.eco_outlined,
                                color: Colors.green,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    'Category: $cat',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),

                                  Text(
                                    'UPC: $upc',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    'Health Score: $score',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            FilledButton(
                              onPressed: () {
                                appState.addItem(
                                  upc: upc,
                                  name: name,
                                  category: cat,
                                  nutrition:
                                      NutritionalUtils.buildNutritionFromFoodNutrients(
                                        item,
                                      ),
                                );

                                Navigator.of(ctx).pop();

                                _snack('Added healthier item: $name');
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: _primaryRed,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Handles barcode detection from [MobileScanner].
  ///
  /// Extracts first barcode from [capture] and calls [_checkEligibility].
  /// Prevents multiple concurrent scans via [_busy] flag.
  void _onDetect(BarcodeCapture capture) {
    if (_busy) return;

    final barcode = capture.barcodes.firstOrNull;

    if (barcode?.rawValue != null) {
      _checkEligibility(barcode!.rawValue!);
    }
  }

  /// Builds the main scan screen UI for both mobile and desktop layouts.
  ///
  /// On mobile, shows a live barcode scanner, actions to re-check eligibility
  /// and add the last scanned product to the basket, plus a summary card with
  /// product details, category-limit warnings, and a shortcut to healthier
  /// alternatives when available.
  ///
  /// On larger screens, replaces the scanner with a manual UPC entry form,
  /// while still allowing eligibility checks, basket addition, and viewing
  /// healthier alternatives for the last checked product.
  ///
  /// Uses [AppState] to determine whether the current product can be added,
  /// and conditionally shows loading indicators and the healthier-options
  /// icon based on [_loadingHealthier] and [_healthierOptions].
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final isMobile = MediaQuery.of(context).size.width < 700;

    final canAdd =
        _lastInfo != null && appState.canAdd(_lastInfo!['category'] ?? '');

    return Scaffold(
      // Project 2 M3 UI update:
      // Use a soft neutral background so the shopping controls stand out.
      backgroundColor: const Color(0xFFF7F7F8),

      appBar: AppBar(
        title: const Text('Scan Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Scan Receipt',
            onPressed: () async {
              // 1. Stop the barcode scanner so it releases the camera
              await _scannerController.stop();

              if (!context.mounted) return;

              // 2. Go to the receipt screen
              // await Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (_) => const ReceiptScannerScreen(),
              //   ),
              // );
              context.go('/receipt');

              // 3. Restart the barcode scanner when we come back
              _scannerController.start();
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () async {
              // await FirebaseAuth.instance.signOut();
              await _auth.signOut();

              if (context.mounted) {
                context.go('/login');
              }
            },
          ),

          const SizedBox(width: 4),
        ],
      ),

      body: SafeArea(
        child: isMobile
            ? _buildMobileLayout(appState, canAdd)
            : _buildDesktopLayout(appState, canAdd),
      ),
    );
  }

  /// Builds the updated desktop/web layout.
  ///
  /// The original UPC entry, camera scan, nutrition, healthier-alternative,
  /// and add-to-basket features are preserved and presented in two cards.
  Widget _buildDesktopLayout(AppState appState, bool canAdd) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageIntro(),

              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildLookupCard(showCameraButton: true),
                  ),

                  const SizedBox(width: 24),

                  Expanded(
                    flex: 4,
                    child: _lastInfo != null
                        ? _buildProductResult(appState, canAdd)
                        : _buildShoppingTips(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the updated mobile layout.
  ///
  /// Mobile users keep the live barcode scanner first, with manual UPC entry
  /// and product results stacked below it.
  Widget _buildMobileLayout(AppState appState, bool canAdd) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPageIntro(),

          const SizedBox(height: 20),

          _buildScannerCard(),

          const SizedBox(height: 16),

          _buildLookupCard(showCameraButton: false),

          if (_lastInfo != null) ...[
            const SizedBox(height: 16),

            _buildProductResult(appState, canAdd),
          ],
        ],
      ),
    );
  }

  /// Builds the short introduction above the scan controls.
  Widget _buildPageIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Check a product',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF222222),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Scan a barcode or enter the UPC to check WIC eligibility, '
          'review nutrition details, and add the item to your basket.',
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  /// Builds the manual UPC entry section.
  ///
  /// Desktop users also receive the existing camera-scanning action.
  Widget _buildLookupCard({required bool showCameraButton}) {
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
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _primaryRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.numbers, color: _primaryRed),
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter UPC code',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 2),

                      Text(
                        'Use the number printed beneath the barcode.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            TextField(
              controller: _input,
              decoration: InputDecoration(
                labelText: 'UPC Code',
                hintText: '000000000000',
                prefixIcon: const Icon(Icons.qr_code_2),
                filled: true,
                fillColor: const Color(0xFFF8F8F9),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _primaryRed, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _checkEligibility(value);
                }
              },
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: () {
                final upc = _input.text.trim();

                if (upc.isNotEmpty) {
                  _checkEligibility(upc);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: _primaryRed,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.search),
              label: const Text('Check Eligibility'),
            ),

            if (showCameraButton) ...[
              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: _showScanDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryRed,
                  side: const BorderSide(color: _primaryRed),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Scan with Camera'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the existing live mobile scanner inside the updated card layout.
  Widget _buildScannerCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.qr_code_scanner, color: _primaryRed),

                SizedBox(width: 8),

                Text(
                  'Scan barcode',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 14),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _onDetect,
                    ),

                    // Visual scan guide only; barcode detection remains unchanged.
                    IgnorePointer(
                      child: Container(
                        margin: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          border: Border.all(color: _primaryRed, width: 3),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Center the barcode inside the red frame.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays guidance before the user has checked a product.
  ///
  /// This is a presentation-only addition for the Project 2 shopping UI.
  Widget _buildShoppingTips() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.shopping_basket_outlined,
              size: 34,
              color: _primaryRed,
            ),

            const SizedBox(height: 16),

            const Text(
              'Shop with confidence',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'After a product is found, you will see its category, '
              'nutrition details, benefit status, and healthier alternatives '
              'when available.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 20),

            _tipRow(
              Icons.verified_outlined,
              'Check whether the product is in the approved list.',
            ),

            const SizedBox(height: 12),

            _tipRow(
              Icons.restaurant_menu_outlined,
              'Review nutrition information before adding it.',
            ),

            const SizedBox(height: 12),

            _tipRow(
              Icons.eco_outlined,
              'Compare healthier alternatives when they are available.',
            ),
          ],
        ),
      ),
    );
  }

  /// Helper row for the informational shopping tips.
  Widget _tipRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: _primaryRed),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the product result using the existing lookup and basket data.
  ///
  /// Nutritional badges, category limits, healthier alternatives, and
  /// add-to-basket behavior all continue to use the original logic above.
  Widget _buildProductResult(AppState appState, bool canAdd) {
    final nutrition = NutritionalUtils.buildNutritionFromFoodNutrients(
      _lastInfo!,
    );

    final name = _lastInfo!['name'] ?? 'Unknown';

    final category = _lastInfo!['category'] ?? 'Unknown';

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primaryRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: _primaryRed,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Product found',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _primaryRed,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            NutritionalBadgesCompact(nutrition: nutrition),

            const SizedBox(height: 18),

            _infoRow('Category', category),

            const SizedBox(height: 8),

            _infoRow('UPC', _lastScanned ?? '-'),

            if (!canAdd) ...[
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade800,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Category limit reached',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_loadingHealthier) ...[
              const SizedBox(height: 18),

              const LinearProgressIndicator(),

              const SizedBox(height: 8),

              Text(
                'Checking for healthier alternatives...',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ] else if (_healthierOptions != null &&
                _healthierOptions!.isNotEmpty) ...[
              const SizedBox(height: 18),

              // Same existing healthier-alternative action, made more visible.
              OutlinedButton.icon(
                onPressed: _showHealthierOptions,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                  side: BorderSide(color: Colors.green.shade300),
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.eco_outlined),
                label: Text(
                  'View ${_healthierOptions!.length} healthier alternative'
                  '${_healthierOptions!.length == 1 ? '' : 's'}',
                ),
              ),
            ],

            const SizedBox(height: 18),

            FilledButton.icon(
              onPressed: canAdd ? _addToBasket : null,
              style: FilledButton.styleFrom(
                backgroundColor: canAdd ? _primaryRed : Colors.grey.shade300,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Basket'),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper row for product metadata in the result card.
  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
