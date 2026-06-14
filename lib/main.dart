import 'package:flutter/material.dart';

import 'components/theme/habit_focus_theme.dart';
import 'routes/app_routes.dart';
import 'utils/controller_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize all controllers with persisted data
  await ControllerInitializer.initializeAll();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better Person',
      theme: HabitFocusTheme.themeData,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
