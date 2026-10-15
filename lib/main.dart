import 'package:flutter/material.dart';

import 'components/theme/habit_focus_theme.dart';
import 'controllers/controllers.dart';
import 'l10n/app_localizations.dart';
import 'routes/app_routes.dart';
import 'utils/controller_initializer.dart';
import 'utils/daily_reset_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all controllers with persisted data
  await ControllerInitializer.initializeAll();

  // Initialize daily reset service
  await DailyResetService.initialize();

  runApp(
    MyApp(
      initialRoute: UserController().getAll().isEmpty
          ? AppRoutes.onboarding
          : AppRoutes.home,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.initialRoute = AppRoutes.home});

  final String initialRoute;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _settings = SettingController();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() => setState(() {});

  ThemeMode get _themeMode => switch (_settings.getCurrentSetting().themeMode) {
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.light,
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better Person',
      theme: HabitFocusTheme.themeData,
      darkTheme: HabitFocusTheme.darkThemeData,
      themeMode: _themeMode,
      locale: Locale(_settings.getCurrentSetting().localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      initialRoute: widget.initialRoute,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
