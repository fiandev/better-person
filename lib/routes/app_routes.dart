import 'package:flutter/material.dart';

import '../components/screens/focus_screen/focus_screen.dart';
import '../components/screens/home_screen.dart';
import '../components/screens/devotion_screen.dart';
import '../components/screens/kindness_screen.dart';
import '../components/screens/statistics_screen.dart';
import '../components/screens/wallet_screen.dart';
import '../components/screens/add_wallet_screen.dart';
import '../components/screens/add_transaction_screen.dart';
import '../components/screens/transfer_screen.dart';
import '../components/screens/financial_analysis_screen.dart';
import '../components/screens/profile_screen.dart';
import '../components/screens/settings_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String focus = '/focus';
  static const String devotion = '/devotion';
  static const String kindness = '/kindness';
  static const String statistics = '/statistics';
  static const String wallet = '/wallet';
  static const String addWallet = '/add-wallet';
  static const String addTransaction = '/add-transaction';
  static const String transfer = '/transfer';
  static const String financialAnalysis = '/financial-analysis';
  static const String profile = '/profile';
  static const String settingsRoute = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case focus:
        return MaterialPageRoute(builder: (_) => const FocusScreen());
      case devotion:
        return MaterialPageRoute(builder: (_) => const DevotionScreen());
      case kindness:
        return MaterialPageRoute(builder: (_) => const KindnessScreen());
      case statistics:
        return MaterialPageRoute(builder: (_) => const StatisticsScreen());
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      case addWallet:
        return MaterialPageRoute(builder: (_) => const AddWalletScreen());
      case addTransaction:
        return MaterialPageRoute(builder: (_) => const AddTransactionScreen());
      case transfer:
        return MaterialPageRoute(builder: (_) => const TransferScreen());
      case financialAnalysis:
        return MaterialPageRoute(builder: (_) => const FinancialAnalysisScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static void navigateToIndex(BuildContext context, int index) {
    final routes = [home, focus, devotion, wallet, statistics];
    if (index >= 0 && index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }
}
