import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // make sure this path is correct

/// Legacy welcome screen with a Firebase sign-out action.
///
/// Not registered in the current main router. Sign-out replaces the navigator
/// stack with the login screen; this widget does not manage basket state.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Navigate back to LoginScreen and remove previous routes
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
