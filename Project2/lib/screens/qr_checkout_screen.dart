import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Displays the current basket as JSON encoded in a QR image.
///
/// Requires an [AppState] provider. Finishing calls [AppState.checkout], then
/// closes this screen and navigates to scanning. The QR is a basket summary,
/// not a payment authorization or verified retailer integration.
class QRCheckoutScreen extends StatelessWidget {
  const QRCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final qrData = jsonEncode(appState.basket);

    return Scaffold(
      appBar: AppBar(title: Text('QR Code Checkout')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 300.0,
            ),
          ),

          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () async {
                await appState.checkout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction Complete! Balances updated.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context, rootNavigator: true).pop();
                  context.go('/scan');
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(color: const Color(0xFFD1001C), width: 2),
              ),
              child: const Text(
                'Finish Transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD1001C),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
