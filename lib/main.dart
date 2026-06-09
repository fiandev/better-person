import 'package:flutter/material.dart';

import 'habit_focus/screens/home_screen.dart';
import 'habit_focus/theme/habit_focus_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitFocus',
      theme: HabitFocusTheme.themeData,
      home: const HomeScreen(),
    );
  }
}
