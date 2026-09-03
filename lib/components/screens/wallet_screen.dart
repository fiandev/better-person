import 'package:better_person/components/widgets/habit_focus_app_bar.dart';
import 'package:flutter/material.dart';

import '../../routes/route_shell.dart';
import '../../routes/app_routes.dart';
import '../../controllers/wallet_controller.dart';
import '../../controllers/setting_controller.dart';
import '../../models/wallet.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa), // surface
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
            _buildFinancialJournalCard(),
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
        backgroundColor: const Color(0xFF2d6a4f), // primary-container
        child: const Icon(
          Icons.add,
          size: 28,
          color: Colors.white, // on-primary
        ),
      ),
      bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 3),
    );
  }

  Widget _buildTotalBalanceSection() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF404943), // on-surface-variant
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${SettingController().getCurrentSetting().defaultCurrencyFormat}${_totalBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 40,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
              color: Color(0xFF0f5238), // primary
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialJournalCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFf8f9fa), // surface-bright
        border: Border.all(color: const Color(0xFFbfc9c1)), // outline-variant
        borderRadius: BorderRadius.circular(12), // rounded-xl
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1b4332), // rgba(27,67,50,0.04)
            blurRadius: 24,
            offset: Offset(0, 12),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Financial Journal',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0f5238), // primary
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Weekly vs Monthly Insights',
                    style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 12,
                      color: Color(0xFF404943), // on-surface-variant
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.insights,
                color: Color(0xFF0f5238), // primary
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Placeholder for chart - simplified
              Expanded(
                child: Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: const Text(
                    'Chart Placeholder',
                    style: TextStyle(fontSize: 10, color: Color(0xFF404943)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EXTREMES',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                        color: Color(0xFF404943),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildProgressBar('High', 0.9, const Color(0xFF0f5238)),
                    const SizedBox(height: 8),
                    _buildProgressBar('Low', 0.3, const Color(0xFF3e6750)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _navigateToFinancialAnalysis,
            child: Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFbfc9c1))),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View Detailed Analysis',
                    style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0f5238),
                    ),
                  ),
                  Icon(Icons.arrow_forward, size: 16, color: Color(0xFF0f5238)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress, Color color) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFedeeef), // surface-container
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your Wallets',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF191c1d), // on-surface
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 8),
            // Add Wallet button: bg-secondary-container text-on-secondary-container rounded-full
            ElevatedButton.icon(
              onPressed: _navigateToAddWallet,
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
              label: const Text(
                'Add Wallet',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFbdeacd), // secondary-container
                foregroundColor: const Color(
                  0xFF426b54,
                ), // on-secondary-container
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
              child: _buildWalletCard(wallet),
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1b4332),
            blurRadius: 24,
            offset: Offset(0, 12),
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
                '${SettingController().getCurrentSetting().defaultCurrencyFormat}${wallet.currentBalance.toStringAsFixed(2)}',
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
    return GestureDetector(
      onTap: _navigateToTransfer,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.82,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2d6a4f), // primary-container
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A1b4332),
              blurRadius: 24,
              offset: Offset(0, 12),
              spreadRadius: -8,
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, size: 40, color: Colors.white),
            SizedBox(height: 8),
            Text(
              'Transfer',
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Move funds between wallets',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add new wallet card: border-dashed border-primary-fixed-dim
  Widget _buildAddWalletCard() {
    return GestureDetector(
      onTap: _navigateToAddWallet,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.82,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF95d4b3), // primary-fixed-dim
            width: 2,
            // Flutter doesn't support dashed borders natively, we style it similarly
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 40,
              color: Color(0xFF2d6a4f),
            ), // primary-container
            SizedBox(height: 8),
            Text(
              'Add New Wallet',
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2d6a4f),
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
