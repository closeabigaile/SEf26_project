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
          title: const Text('Scan QR/Barcode'),
          content: SizedBox(
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
      category = "Paid";
    }

    appState.addItem(
      upc: _lastScanned ?? '',
      name: _lastInfo!['name'] ?? 'Unknown',
      category: category,
      originalBenefitCategory: _lastInfo!['category'] ?? 'Unknown',
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Healthier Alternatives',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFFD1001C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Health score is based on penalties (sugar, fat, and sodium) and bonuses (fiber and protein).\nLower scores indicate healthier choices.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  ..._healthierOptions!.map((item) {
                    final name = item['name'] ?? 'Unknown';
                    final cat = item['category'] ?? '';
                    final upc = item['upc'] ?? '';
                    final score = (item['healthScore'] is num)
                        ? item['healthScore'].toStringAsFixed(1)
                        : '-';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
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
                                    const SizedBox(height: 2),
                                    Text(
                                      'Category: $cat',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'UPC: $upc',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
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
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.green,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    int quantity() => appState.basket
                                        .where((line) => line['upc'] == upc)
                                        .fold<int>(0, (total, line) => total + (line['qty'] as int? ?? 0));
                                    final before = quantity();
                                    final created = appState.addItem(
                                      upc: upc,
                                      name: name,
                                      category: cat,
                                      nutrition:
                                          NutritionalUtils.buildNutritionFromFoodNutrients(
                                            item,
                                          ),
                                    );
                                    // addItem also returns false for a successful
                                    // increment, so check the actual quantity.
                                    if (!created && quantity() <= before) {
                                      _snack('Could not add $name. Check your allowance and try again.');
                                      return;
                                    }
                                    Navigator.of(ctx).pop();
                                    _snack('Added healthier item: $name');
                                  },
                                  tooltip: 'Add to basket',
                                ),
                              ),
                            ],
                          ),
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final canAdd =
        _lastInfo != null && appState.canAdd(_lastInfo!['category'] ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt),
            tooltip: 'Scan Receipt',
            onPressed: () async {
              // 1. Stop the barcode scanner so it releases the camera
              await _scannerController.stop();

              if (!context.mounted) return;

              // 2. Go to the receipt screen
              // await Navigator.of(context).push(
              //   MaterialPageRoute(builder: (_) => const ReceiptScannerScreen()),
              // );
              context.go('/receipt');

              // 3. Restart the barcode scanner when we come back
              _scannerController.start();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // await FirebaseAuth.instance.signOut();
              await _auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: isMobile
          ? SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Place barcode inside the square',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD1001C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFD1001C),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: MobileScanner(
                            controller: _scannerController,
                            onDetect: _onDetect,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: (_lastInfo != null)
                                  ? () => _checkEligibility(_lastScanned ?? '')
                                  : null,
                              child: const Text('Re-check'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: canAdd ? _addToBasket : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: canAdd
                                    ? const Color(0xFFD1001C)
                                    : Colors.grey.shade300,
                              ),
                              child: const Text('Add to Basket'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_lastInfo != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _lastInfo!['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFFD1001C),
                                      ),
                                    ),
                                  ),
                                  if (_loadingHealthier)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else if (_healthierOptions != null &&
                                      _healthierOptions!.isNotEmpty)
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.eco,
                                          color: Colors.green,
                                          size: 24,
                                        ),
                                        iconSize: 24,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: _showHealthierOptions,
                                        tooltip:
                                            'View healthier alternatives (${_healthierOptions!.length})',
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              NutritionalBadgesCompact(
                                nutrition:
                                    NutritionalUtils.buildNutritionFromFoodNutrients(
                                      _lastInfo!,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Category: ${_lastInfo!['category']}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              Text(
                                'UPC: $_lastScanned',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              if (!canAdd) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        size: 16,
                                        color: Colors.orange.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Category limit reached',
                                        style: TextStyle(
                                          color: Colors.orange.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 4,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 64,
                            color: const Color(0xFFD1001C),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Enter UPC Code',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD1001C),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Type the barcode number manually',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            controller: _input,
                            decoration: InputDecoration(
                              labelText: 'UPC Code',
                              hintText: '000000000000',
                              prefixIcon: const Icon(
                                Icons.numbers,
                                color: Color(0xFFD1001C),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD1001C),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD1001C),
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                _checkEligibility(value);
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () {
                                    final upc = _input.text.trim();
                                    if (upc.isNotEmpty) {
                                      _checkEligibility(upc);
                                    }
                                  },
                                  icon: const Icon(Icons.search),
                                  label: const Text('Check'),
                                ),
                              ),
                              // --- START NEW BUTTON ---
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  // Used OutlinedButton for contrast
                                  onPressed: _showScanDialog,
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Scan with Camera'),
                                ),
                              ),

                              // --- END NEW BUTTON ---
                              if (_lastInfo != null) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: canAdd ? _addToBasket : null,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: canAdd
                                          ? const Color(0xFFD1001C)
                                          : Colors.grey.shade300,
                                    ),
                                    icon: const Icon(Icons.add_shopping_cart),
                                    label: const Text('Add'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_lastInfo != null) ...[
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFD1001C,
                                ).withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFFD1001C,
                                  ).withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _lastInfo!['name'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFFD1001C),
                                          ),
                                        ),
                                      ),
                                      if (_loadingHealthier)
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      else if (_healthierOptions != null &&
                                          _healthierOptions!.isNotEmpty)
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(
                                              alpha: 0.1,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.eco,
                                              color: Colors.green,
                                              size: 24,
                                            ),
                                            iconSize: 24,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: _showHealthierOptions,
                                            tooltip:
                                                'View healthier alternatives (${_healthierOptions!.length})',
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  NutritionalBadgesCompact(
                                    nutrition:
                                        NutritionalUtils.buildNutritionFromFoodNutrients(
                                          _lastInfo!,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Category: ${_lastInfo!['category']}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    'UPC: $_lastScanned',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (!canAdd) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          size: 16,
                                          color: Colors.orange.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Category limit reached',
                                          style: TextStyle(
                                            color: Colors.orange.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
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
