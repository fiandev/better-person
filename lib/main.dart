import 'package:flutter/material.dart';

import 'habit_focus/screens/home_screen.dart';
import 'habit_focus/screens/focus_screen.dart';
import 'habit_focus/screens/ibadah_screen.dart';
import 'habit_focus/screens/spiritual_screen.dart';
import 'habit_focus/screens/kindness_screen.dart';
import 'habit_focus/screens/statistics_screen.dart';
import 'habit_focus/theme/habit_focus_theme.dart';

void main() {
  runApp(const MyApp());
}

final routes = <String, Widget Function()>{
  "/habit_focus/home": () => const HomeScreen(),
  "/habit_focus/focus": () => const FocusScreen(),
  "/habit_focus/ibadah": () => const IbadahScreen(),
  "/habit_focus/spiritual": () => const SpiritualScreen(),
  "/habit_focus/kindness": () => const KindnessScreen(),
  "/habit_focus/statistics": () => const StatisticsScreen(),
};

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Map<String, String> queryParams;

  @override
  void initState() {
    super.initState();
    queryParams = Uri.base.queryParameters;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitFocus',
      theme: queryParams["theme"] == "dark"
          ? ThemeData.dark()
          : ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
      home: Builder(
        builder: (context) {
          final builder = routes[queryParams["path"]];
          final widget = builder?.call() ?? const HomeScreen();
          final path = queryParams["path"] ?? "";
          if (path.startsWith("/habit_focus/") || builder == null) {
            return Theme(data: HabitFocusTheme.themeData, child: widget);
          }
          return widget;
        },
      ),
    );
  }
}
