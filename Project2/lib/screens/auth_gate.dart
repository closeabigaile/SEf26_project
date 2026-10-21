import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:wolfbite/screens/scan_screen.dart';

/// Standalone auth-stream gate that displays scanning or login.
///
/// The main app currently uses the guarded router instead; this widget does
/// not define the app's route table or create its state providers.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        // Listen to the user's authentication state
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. If the snapshot has user data, they are logged in
          if (snapshot.hasData && snapshot.data != null) {
            return const ScanScreen();
          }
          // 2. If the snapshot has no data, they are logged out
          else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
