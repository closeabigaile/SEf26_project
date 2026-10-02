// Repeatable M4 UI walkthrough. All records and balances are synthetic.
// flutter run -d web-server -t tool/m4_scenario_walkthrough.dart --web-port 8083
import 'dart:convert';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wolfbite/screens/basket_screen.dart';
import 'package:wolfbite/services/checkout_help_repository.dart';
import 'package:wolfbite/state/app_state.dart';

class WalkthroughState extends AppState {
  WalkthroughState() : super(db: FakeFirebaseFirestore());
  int checkoutCalls = 0;
  int loadCalls = 0;
  int clearCalls = 0;
  @override
  Future<void> checkout() {
    checkoutCalls++;
    return super.checkout();
  }

  @override
  Future<void> loadUserState() {
    loadCalls++;
    return super.loadUserState();
  }

  @override
  void clearBasket() {
    clearCalls++;
    super.clearBasket();
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'M4 scenario walkthrough — synthetic data',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD1001C),
          primary: const Color(0xFFD1001C),
          secondary: const Color(0xFFD1001C),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD1001C),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD1001C),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFD1001C),
          foregroundColor: Colors.white,
        ),
      ),

      home: const Walkthrough(),
    ),
  );
}

class Walkthrough extends StatefulWidget {
  const Walkthrough({super.key});
  @override
  State<Walkthrough> createState() => _WalkthroughState();
}

class _WalkthroughState extends State<Walkthrough> {
  final state = WalkthroughState();
  String result = 'Ready to verify all four prepared scenarios.';
  bool busy = false;
  String snapshot() =>
      jsonEncode({'basket': state.basket, 'balances': state.balances});
  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  Future<void> start() async {
    setState(() => busy = true);
    try {
      final examples = await const CheckoutHelpRepository().loadExamples();
      state.basket.clear();
      state.basket.addAll(
        examples.map((e) => Map<String, dynamic>.from(e.toBasketLine())),
      );
      state.balances.clear();
      state.balances.addAll({
        'CEREAL': {'allowed': 4, 'used': 3},
        'PAID': {'allowed': null, 'used': 1},
      });
      state.checkoutCalls = 0;
      state.loadCalls = 0;
      state.clearCalls = 0;
      final before = snapshot();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChangeNotifierProvider<AppState>.value(
            value: state,
            child: const BasketScreen(),
          ),
        ),
      );
      if (!mounted) return;
      final unchanged = before == snapshot();
      final noOperations =
          state.checkoutCalls == 0 &&
          state.loadCalls == 0 &&
          state.clearCalls == 0;
      setState(
        () => result =
            '${unchanged && noOperations ? "PASS" : "FAIL"}: '
            'basket and balances ${unchanged ? "unchanged" : "changed"}. '
            'Checkout calls: ${state.checkoutCalls}; reload calls: ${state.loadCalls}; '
            'clear calls: ${state.clearCalls}. '
            'CEREAL used: ${state.balances['CEREAL']?['used']}; '
            'PAID used: ${state.balances['PAID']?['used']}.',
      );
    } catch (error) {
      if (mounted) setState(() => result = 'Walkthrough failed: $error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('M4 scenario walkthrough')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Synthetic fixture data. No account or live Firebase connection. '
          'Use Get checkout help on each of the four items. Read the explanation '
          'and next step, then Close. Use Back from My Basket to check state. '
          'Quantity, checkout, clear, and logout controls are not part of this walkthrough.',
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: busy ? null : start,
          child: const Text('Open prepared basket'),
        ),
        const SizedBox(height: 24),
        Text(result, key: const ValueKey('walkthrough-result')),
      ],
    ),
  );
}
