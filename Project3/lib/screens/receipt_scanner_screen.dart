import 'dart:convert'; // For Base64 encoding
import 'dart:typed_data'; // For reading bytes
import 'package:flutter/foundation.dart' show kIsWeb; // To detect Web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For API calls
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:wolfbite/utils/nutritional_utils.dart';
import '../state/app_state.dart';
import '../services/apl_service.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  static const Color _primaryRed = Color(0xFFD1001C);

  final _picker = ImagePicker();
  final _apl = AplService();

  bool _scanning = false;
  List<Map<String, dynamic>> _foundItems = [];
  String _status = "Tap button to upload receipt";

  /// 1. Pick Image & Send to API
  Future<void> _scanReceipt() async {
    // A. Ask user for source (Camera isn't great on Web, Gallery is safer)
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.receipt_long_outlined, color: _primaryRed),
            SizedBox(width: 10),
            Text("Choose Source"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SourceOption(
              icon: Icons.photo_library_outlined,
              title: "Gallery / Upload",
              description: "Choose an existing receipt image",
              onTap: () {
                Navigator.pop(ctx, ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
            _SourceOption(
              icon: Icons.camera_alt_outlined,
              title: "Camera",
              description: "Take a new photo of your receipt",
              onTap: () {
                Navigator.pop(ctx, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    setState(() {
      _scanning = true;
      _status = "Uploading & Analyzing...";
      _foundItems.clear();
    });

    try {
      final picked = await _picker.pickImage(source: source);

      if (picked == null) {
        setState(() {
          _scanning = false;
          _status = "Tap button to upload receipt";
        });
        return;
      }

      // B. Get the image bytes (Web-safe way)
      Uint8List imageBytes = await picked.readAsBytes();

      // C. Convert to Base64 for the API
      String base64Image = "data:image/jpeg;base64,${base64Encode(imageBytes)}";

      // D. Send to Cloud API
      final text = await _fetchOcrText(base64Image);

      // E. Parse results
      await _parseUPCs(text);
    } catch (e) {
      setState(() {
        _status = "Error: $e";
        _scanning = false;
      });
    }
  }

  /// Sends the image to the free OCR.space API
  Future<String> _fetchOcrText(String base64Image) async {
    // Use the public 'helloworld' key (limits: 25kb max size sometimes, mostly for testing).
    // For a smoother demo, get a free key at https://ocr.space/ocrapi/freekey
    const apiKey = 'helloworld';

    final uri = Uri.parse('https://api.ocr.space/parse/image');

    final response = await http.post(
      uri,
      body: {
        'apikey': apiKey,
        'base64Image': base64Image,
        'language': 'eng',
        'isOverlayRequired': 'false',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Check for API errors
      if (data['IsErroredOnProcessing'] == true) {
        throw Exception(data['ErrorMessage']?[0] ?? "API Processing Error");
      }

      final parsedResults = data['ParsedResults'] as List?;

      if (parsedResults != null && parsedResults.isNotEmpty) {
        return parsedResults[0]['ParsedText'] as String;
      }

      return "";
    } else {
      throw Exception("API Error: ${response.statusCode}");
    }
  }

  /// Find 12–14 digit codes and lookup in APL
  Future<void> _parseUPCs(String fullText) async {
    final regex = RegExp(r'\b\d{12,14}\b');

    final matches = regex.allMatches(fullText);

    List<Map<String, dynamic>> validItems = [];

    int foundCount = 0;

    for (final match in matches) {
      String candidate = match.group(0)!;

      foundCount++;

      List<String> toTry = [candidate];

      if (candidate.length > 12) {
        for (int i = 0; i <= candidate.length - 12; i++) {
          final sub = candidate.substring(i, i + 12);

          if (!toTry.contains(sub)) {
            toTry.add(sub);
          }
        }
      }

      for (final upc in toTry) {
        final info = await _apl.findByUpc(upc);

        if (info != null) {
          final productWithUpc = Map<String, dynamic>.from(info);

          productWithUpc['upc'] = upc;

          if (!validItems.any((item) => item['upc'] == upc)) {
            validItems.add(productWithUpc);
          }

          break;
        }
      }
    }

    setState(() {
      _foundItems = validItems;
      _scanning = false;

      _status = matches.isEmpty
          ? "No UPC candidates found.\n(Ensure image is clear & contains 12–14 digit codes)"
          : "Found $foundCount codes, ${validItems.length} valid WIC items.";
    });
  }

  void _addAllToBasket() {
    final app = context.read<AppState>();

    int count = 0;

    for (final item in _foundItems) {
      if (app.addItem(
        upc: item['upc'],
        name: item['name'],
        category: item['category'],
        nutrition: NutritionalUtils.buildNutritionFromFoodNutrients(item),
      )) {
        count++;
      }
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Added $count items')));

    context.go('/basket');
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      // Project 2 M3 UI update:
      // Match the rest of the shopping flow with the same neutral
      // background and red accent color.
      backgroundColor: const Color(0xFFF7F7F8),

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Scan',
          onPressed: () {
            context.go('/scan');
          },
        ),
        title: const Text('Scan Receipt'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(),

                  const SizedBox(height: 24),

                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _buildUploadCard()),

                        const SizedBox(width: 24),

                        Expanded(flex: 5, child: _buildResultsSection()),
                      ],
                    )
                  else ...[
                    _buildUploadCard(),

                    const SizedBox(height: 20),

                    _buildResultsSection(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the page heading shown above the receipt scanner.
  ///
  /// This is a presentation-only addition and does not change OCR behavior.
  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scan your receipt',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF222222),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Upload or photograph a receipt to find WIC-eligible products '
          'and quickly add them to your basket.',
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  /// Builds the receipt upload section.
  ///
  /// Uses the existing image picker and OCR workflow from [_scanReceipt].
  Widget _buildUploadCard() {
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primaryRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: _primaryRed,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload receipt',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 2),

                      Text(
                        'Use a clear image with visible product codes.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _scanning
                        ? Icons.hourglass_top
                        : _foundItems.isNotEmpty
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                    color: _scanning
                        ? _primaryRed
                        : _foundItems.isNotEmpty
                        ? Colors.green
                        : Colors.grey.shade700,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      _status,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_scanning) ...[
              const SizedBox(height: 16),

              const LinearProgressIndicator(color: _primaryRed),
            ],

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _scanning ? null : _scanReceipt,
              style: FilledButton.styleFrom(
                backgroundColor: _primaryRed,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                _foundItems.isEmpty ? Icons.upload_file : Icons.refresh,
              ),
              label: Text(
                _foundItems.isEmpty
                    ? 'Select Receipt Image'
                    : 'Scan Another Receipt',
              ),
            ),

            const SizedBox(height: 14),

            Text(
              kIsWeb
                  ? 'Tip: On web, uploading an existing image is usually more reliable than using the camera.'
                  : 'Tip: Make sure the receipt is flat, well lit, and easy to read.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the detected receipt items section.
  ///
  /// The product list comes directly from the existing OCR and APL lookup
  /// process in [_parseUPCs].
  Widget _buildResultsSection() {
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primaryRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: _primaryRed,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detected products',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        _foundItems.isEmpty
                            ? 'Eligible receipt items will appear here.'
                            : '${_foundItems.length} WIC item${_foundItems.length == 1 ? '' : 's'} found.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            if (_scanning)
              _buildScanningState()
            else if (_foundItems.isEmpty)
              _buildEmptyResults()
            else
              _buildFoundItems(),

            if (_foundItems.isNotEmpty) ...[
              const SizedBox(height: 20),

              // Existing action for adding all valid receipt products.
              FilledButton.icon(
                onPressed: _addAllToBasket,
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(
                  'Add ${_foundItems.length} Item${_foundItems.length == 1 ? '' : 's'} to Basket',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the visual state shown while the receipt is being analyzed.
  Widget _buildScanningState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 38),
      child: Column(
        children: [
          const SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(color: _primaryRed),
          ),

          const SizedBox(height: 18),

          const Text(
            'Analyzing receipt...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 6),

          Text(
            'Looking for UPC codes and matching WIC products.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// Builds the default result state before any products are detected.
  Widget _buildEmptyResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _primaryRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.document_scanner_outlined,
              size: 38,
              color: _primaryRed,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No receipt scanned yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Upload a receipt and any matching WIC products will be listed here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds cards for each valid WIC product found on the receipt.
  Widget _buildFoundItems() {
    return Column(
      children: [
        for (int i = 0; i < _foundItems.length; i++) ...[
          _ReceiptItemCard(item: _foundItems[i]),

          if (i != _foundItems.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Card used to display one WIC product detected from the receipt.
class _ReceiptItemCard extends StatelessWidget {
  const _ReceiptItemCard({required this.item});

  static const Color _primaryRed = Color(0xFFD1001C);

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final name = item['name'] ?? 'Unknown Product';

    final upc = item['upc'] ?? '';

    final category = item['category'] ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_outline, color: Colors.green),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    color: _primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'UPC: $upc',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Selection tile used in the receipt source dialog.
class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  static const Color _primaryRed = Color(0xFFD1001C);

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _primaryRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _primaryRed),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}
