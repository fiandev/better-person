import 'package:better_person/components/widgets/habit_focus_app_bar.dart';
import 'package:flutter/material.dart';

import '../../routes/route_shell.dart';
import '../../routes/app_routes.dart';
import '../../controllers/wallet_controller.dart';
import '../../controllers/setting_controller.dart';
import '../../models/wallet.dart';
import '../widgets/wallet/financial_journal_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _walletController = WalletController();

  List<Wallet> _wallets = [];
  double _totalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final wallets = _walletController.getAll();
    final totalBalance = _walletController.getTotalBalance();

    setState(() {
      _wallets = wallets;
      _totalBalance = totalBalance;
    });
  }

  void _navigateToAddWallet() {
    Navigator.pushNamed(context, AppRoutes.addWallet).then((_) => _loadData());
  }

  void _navigateToTransfer() {
    Navigator.pushNamed(context, AppRoutes.transfer).then((_) => _loadData());
  }

  void _navigateToAddTransaction() {
    Navigator.pushNamed(
      context,
      AppRoutes.addTransaction,
    ).then((_) => _loadData());
  }

  void _navigateToFinancialAnalysis() {
    Navigator.pushNamed(context, AppRoutes.financialAnalysis);
  }

  void _navigateToEditWallet(Wallet wallet) {
    Navigator.pushNamed(
      context,
      AppRoutes.editWallet,
      arguments: wallet,
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const HabitFocusAppBar(overrideTitle: 'Finance'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Balance Summary
            _buildTotalBalanceSection(),
            const SizedBox(height: 32), // stack-lg
            // Financial Journal Card
            FinancialJournalCard(onViewAnalysis: _navigateToFinancialAnalysis),
            const SizedBox(height: 32), // stack-lg
            // Your Wallets Header + Action Buttons
            _buildWalletsHeader(),
            const SizedBox(height: 16), // stack-md
            // Horizontal Scrollable Wallet Cards
            _buildWalletsHorizontalScroll(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransaction,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 3),
    );
  }

  Widget _buildTotalBalanceSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Column(
        children: [
          Text(
            'Total Balance',
            style: textTheme.bodyMedium?.copyWith(
              fontFamily: 'Work Sans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${SettingController().getCurrentSetting().defaultCurrencyFormat} ${_totalBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
            style: textTheme.headlineLarge?.copyWith(
              fontFamily: 'Manrope',
              fontSize: 40,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletsHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Your Wallets',
          style: textTheme.headlineMedium?.copyWith(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _navigateToAddWallet,
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
              label: Text(
                'Add Wallet',
                style: textTheme.labelMedium?.copyWith(
                  fontFamily: 'Work Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: const StadiumBorder(),
                elevation: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletsHorizontalScroll() {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Existing wallet cards
          ..._wallets.map(
            (wallet) => Padding(
              padding: const EdgeInsets.only(right: 24), // gap-gutter
              child: GestureDetector(
                onTap: () => _navigateToEditWallet(wallet),
                child: _buildWalletCard(wallet),
              ),
            ),
          ),
          // Transfer shortcut card
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: _buildTransferShortcutCard(),
          ),
          // Add new wallet card
          _buildAddWalletCard(),
        ],
      ),
    );
  }

  // Wallet card: bg-gradient-to-br from-primary to-tertiary, rounded-xl, text-on-primary
  Widget _buildWalletCard(Wallet wallet) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradients = _walletGradients(wallet.icon);

    return Container(
      width: MediaQuery.of(context).size.width * 0.82, // min-w-[85%]
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradients,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12), // rounded-xl
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -8,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Glowing circle decorative top-right
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.name,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        wallet.getTypeName(),
                        style: const TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      _walletIconData(wallet.icon),
                      size: 32,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Balance
              Text(
                '${SettingController().getCurrentSetting().defaultCurrencyFormat} ${wallet.currentBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Account number label-data style
              Text(
                wallet.accountNumber,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Transfer shortcut card: bg-primary-container rounded-xl
  Widget _buildTransferShortcutCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: _navigateToTransfer,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.82,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: -8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz,
              size: 40,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 8),
            Text(
              'Transfer',
              style: textTheme.bodyLarge?.copyWith(
                fontFamily: 'Work Sans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Move funds between wallets',
              style: textTheme.labelSmall?.copyWith(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add new wallet card
  Widget _buildAddWalletCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: _navigateToAddWallet,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.82,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 40,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Add New Wallet',
              style: textTheme.bodyLarge?.copyWith(
                fontFamily: 'Work Sans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _walletGradients(WalletIcon icon) {
    switch (icon) {
      case WalletIcon.savings:
        // from-secondary (#3e6750) to-tertiary-container (#3f6754)
        return [const Color(0xFF3e6750), const Color(0xFF3f6754)];
      default:
        // from-primary (#0f5238) to-tertiary (#274f3d)
        return [const Color(0xFF0f5238), const Color(0xFF274f3d)];
    }
  }

  IconData _walletIconData(WalletIcon icon) {
    switch (icon) {
      case WalletIcon.wallet:
        return Icons.account_balance_wallet;
      case WalletIcon.savings:
        return Icons.savings;
      case WalletIcon.flight:
        return Icons.flight_takeoff;
      case WalletIcon.home:
        return Icons.home_work;
      case WalletIcon.car:
        return Icons.directions_car;
      case WalletIcon.bank:
        return Icons.account_balance;
    }
  }
}
