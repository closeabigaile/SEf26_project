import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../state/app_state.dart';

/// Screen displaying WIC benefit balances and account management.
///
/// Shows the user's current benefit usage for each WIC category, with
/// visual progress indicators. Each category displays:
/// - Items used vs. allowed limit
/// - Progress bar with color-coded status (green/orange/red)
/// - "Unlimited" badge for uncapped categories (CVB, produce)
///
/// Also provides account management features:
/// - Sign out button that clears state and returns to [LoginScreen]
/// - Loading state while [AppState.loadUserState] completes
///
/// This screen watches [AppState.balancesLoaded] to determine when to
/// show data vs. loading spinner.
///
/// Usage: Navigated to via `/benefits` route in bottom navigation.
class BalancesScreen extends StatelessWidget {
  const BalancesScreen({super.key, this.auth});

  static const Color _primaryRed = Color(0xFFD1001C);

  final FirebaseAuth? auth;

  /// Signs the user out of [FirebaseAuth] and navigates to login screen.
  ///
  /// Clears all local state in [AppState] automatically via the auth
  /// listener wired in [main.dart].
  ///
  /// Side effects:
  /// - Calls [FirebaseAuth.instance.signOut]
  /// - Navigates to `/login` via [GoRouter]
  Future<void> _signOut(BuildContext context) async {
    await (auth ?? FirebaseAuth.instance).signOut();

    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final balances = appState.balances;
    final loaded = appState.balancesLoaded;

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      // Project 2 M3 UI update:
      // Match the updated Scan and Basket screens with the same neutral
      // background and consistent red accent color.
      backgroundColor: const Color(0xFFF7F7F8),

      appBar: AppBar(
        title: const Text('WIC Benefits'),
        actions: [
          // Sign out button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _signOut(context),
          ),

          const SizedBox(width: 4),
        ],
      ),

      body: !loaded
          ? _buildLoadingState()
          : balances.isEmpty
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
                        _buildPageHeader(),

                        const SizedBox(height: 24),

                        _buildHeader(),

                        const SizedBox(height: 20),

                        // Project 2 M3 UI update:
                        // Use a two-column grid on larger screens while
                        // preserving the same balance information.
                        isDesktop
                            ? _buildDesktopBalances(balances)
                            : _buildMobileBalances(balances),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  /// Builds the page heading shown above the benefit summary.
  ///
  /// This is a presentation-only addition and does not modify benefit data.
  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your benefits',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF222222),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Track how much of each WIC benefit you have used '
          'and what is still available.',
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  /// Builds the loading UI shown while balance data is being loaded.
  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: _primaryRed));
  }

  /// Builds the header section explaining benefit balances.
  ///
  /// Shows an informational card at the top of the screen with an icon
  /// and description text.
  Widget _buildHeader() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _primaryRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.info_outline, color: _primaryRed),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Benefit overview',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Your WIC benefit balances update as you add items '
                    'to your basket.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
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

  /// Builds benefit cards in a two-column desktop layout.
  Widget _buildDesktopBalances(Map<String, Map<String, dynamic>> balances) {
    final entries = balances.entries.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;

        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final entry in entries)
              SizedBox(
                width: itemWidth,
                child: _BalanceCard(category: entry.key, data: entry.value),
              ),
          ],
        );
      },
    );
  }

  /// Builds benefit cards in a single-column mobile layout.
  Widget _buildMobileBalances(Map<String, Map<String, dynamic>> balances) {
    return Column(
      children: [
        for (final entry in balances.entries) ...[
          _BalanceCard(category: entry.key, data: entry.value),

          if (entry.key != balances.keys.last) const SizedBox(height: 14),
        ],
      ],
    );
  }

  /// Builds the UI shown when no benefit data exists yet.
  ///
  /// Displays a centered message encouraging the user to start scanning
  /// products. This typically shows for new accounts before any items
  /// have been added.
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
                        Icons.account_balance_wallet_outlined,
                        size: 42,
                        color: _primaryRed,
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'No benefit data yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Scan products to start tracking your WIC '
                      'benefit balances.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 26),

                    FilledButton.icon(
                      onPressed: () {
                        context.go('/scan');
                      },
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

/// Individual benefit category balance card.
///
/// Displays usage information for a single WIC category with a visual
/// progress indicator. The [data] map from [AppState.balances] contains:
/// - `'allowed'`: [int]? - Max items (null = unlimited)
/// - `'used'`: [int] - Current usage count
///
/// The progress bar changes color based on usage percentage:
/// - Green: 0-60% used
/// - Orange: 60-85% used
/// - Red: 85-100% used
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.category, required this.data});

  static const Color _primaryRed = Color(0xFFD1001C);

  final String category;
  final Map<String, dynamic> data;

  /// Calculates the color for the progress bar based on usage percentage.
  ///
  /// Returns:
  /// - [Colors.green]: Less than 60% used
  /// - [Colors.orange]: 60-85% used
  /// - [Colors.red]: 85% or more used
  ///
  /// For unlimited categories (allowed is null), always returns green.
  Color _getProgressColor(int? allowed, int used) {
    if (allowed == null) {
      return _primaryRed;
    }

    final pct = used / allowed;

    if (pct < 0.6) {
      return _primaryRed;
    }

    if (pct < 0.85) {
      return Colors.orange.shade600;
    }

    return Colors.red.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final allowed = data['allowed'] as int?;

    final used = data['used'] as int? ?? 0;

    final isUnlimited = allowed == null;

    final progress = isUnlimited ? 0.0 : (used / allowed).clamp(0.0, 1.0);

    final color = _getProgressColor(allowed, used);

    final remaining = isUnlimited ? null : (allowed - used).clamp(0, allowed);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category name and status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _primaryRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.card_giftcard_outlined,
                    color: _primaryRed,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        isUnlimited
                            ? '$used items used'
                            : '$used of $allowed items used',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isUnlimited)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryRed.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Unlimited',
                      style: TextStyle(
                        fontSize: 12,
                        color: _primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            if (!isUnlimited) ...[
              // Usage text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Benefit usage',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Progress bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 9,
                borderRadius: BorderRadius.circular(5),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      '$remaining remaining',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'This category does not have a fixed item limit.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
