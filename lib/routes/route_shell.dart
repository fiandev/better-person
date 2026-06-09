import 'package:flutter/material.dart';

import '../components/widgets/habit_focus_bottom_nav.dart';
import 'app_routes.dart';

/// Wraps a screen's Scaffold and injects the bottom navigation bar.
/// 
/// Usage: screens should call [RouteShell.bottomNav] in their Scaffold's
/// [bottomNavigationBar] parameter to obtain a route-aware nav bar.
class RouteShell {
  RouteShell._();

  /// Returns a [HabitFocusBottomNav] wired to route-based navigation.
  /// 
  /// Place this in your Scaffold's [bottomNavigationBar]:
  /// ```dart
  /// bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 0),
  /// ```
  static Widget bottomNav(BuildContext context, {required int currentIndex}) {
    return HabitFocusBottomNav(
      currentIndex: currentIndex,
      onTap: (index) => AppRoutes.navigateToIndex(context, index),
    );
  }
}
