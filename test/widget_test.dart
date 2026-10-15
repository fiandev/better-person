import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:better_person/components/screens/devotion_screen.dart';
import 'package:better_person/components/screens/kindness_screen.dart';
import 'package:better_person/components/theme/habit_focus_theme.dart';
import 'package:better_person/components/widgets/focus/timer_section.dart';
import 'package:better_person/controllers/controllers.dart';
import 'package:better_person/l10n/app_localizations.dart';
import 'package:better_person/models/models.dart';

Widget _app(Widget home) => MaterialApp(
  theme: HabitFocusTheme.themeData,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => '/tmp/opencode/better-person-test',
        );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserController().clear();
    await PrayerController().clear();
    await DzikirEntryController().clear();
    await QuranSessionController().clear();
    await KindnessActController().clear();
    await KindnessLogController().clear();
    await HabitController().clear();
  });

  testWidgets('focus timer card shows remaining time', (tester) async {
    final now = DateTime.now();
    final session = FocusSession(
      id: 'session_test',
      category: 'Work',
      name: 'Focus',
      timerDuration: const Duration(minutes: 25),
      elapsed: const Duration(minutes: 4, seconds: 5),
      timerState: TimerState.idle,
      upNextTaskIds: const [],
      createdAt: now,
    );
    await tester.pumpWidget(
      _app(Scaffold(body: TimerSection(session: session))),
    );
    expect(find.text('20:55'), findsOneWidget);
    expect(find.text('Ready to Focus'), findsOneWidget);
  });

  testWidgets('kindness form exposes a reflection field and submit action', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const KindnessScreen()));
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Log Kindness'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('devotion screen loads a real prayer checklist', (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final times = [
      const TimeOfDay(hour: 5, minute: 0),
      const TimeOfDay(hour: 12, minute: 0),
      const TimeOfDay(hour: 15, minute: 0),
      const TimeOfDay(hour: 18, minute: 0),
      const TimeOfDay(hour: 20, minute: 0),
    ];
    for (var index = 0; index < PrayerName.values.length; index++) {
      PrayerController().items.add(
        Prayer(
          id: 'test_prayer_$index',
          name: PrayerName.values[index],
          scheduledTime: times[index],
          isChecked: false,
          date: today,
        ),
      );
    }
    await tester.pumpWidget(_app(const DevotionScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Daily Shalat'), findsOneWidget);
    expect(find.text('Fajr'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
