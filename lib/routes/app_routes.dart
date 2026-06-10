import 'package:flutter/material.dart';

import '../components/screens/focus_screen.dart';
import '../components/screens/home_screen.dart';
import '../components/screens/devotion_screen.dart';
import '../components/screens/kindness_screen.dart';
import '../components/screens/statistics_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String focus = '/focus';
  static const String devotion = '/devotion';
  static const String kindness = '/kindness';
  static const String statistics = '/statistics';

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
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static void navigateToIndex(BuildContext context, int index) {
    final routes = [home, focus, devotion, kindness, statistics];
    if (index >= 0 && index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }
}
