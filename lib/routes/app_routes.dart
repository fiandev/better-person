import 'package:flutter/material.dart';

import '../components/screens/focus_screen.dart';
import '../components/screens/home_screen.dart';
import '../components/screens/ibadah_screen.dart';
import '../components/screens/kindness_screen.dart';
import '../components/screens/profile_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String focus = '/focus';
  static const String ibadah = '/ibadah';
  static const String kindness = '/kindness';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case focus:
        return MaterialPageRoute(builder: (_) => const FocusScreen());
      case ibadah:
        return MaterialPageRoute(builder: (_) => const IbadahScreen());
      case kindness:
        return MaterialPageRoute(builder: (_) => const KindnessScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static void navigateToIndex(BuildContext context, int index) {
    final routes = [home, focus, ibadah, kindness, profile];
    if (index >= 0 && index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }
}
