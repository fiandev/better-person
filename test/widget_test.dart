import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:better_person/components/screens/devotion_screen.dart';
import 'package:better_person/components/screens/kindness_screen.dart';
import 'package:better_person/components/screens/profile_screen.dart';
import 'package:better_person/components/screens/statistics/statistics_content.dart';
import 'package:better_person/components/theme/habit_focus_theme.dart';
import 'package:better_person/components/widgets/focus/timer_section.dart';
import 'package:better_person/components/widgets/wallet/financial_journal_card.dart';
import 'package:better_person/controllers/controllers.dart';
import 'package:better_person/l10n/app_localizations.dart';
import 'package:better_person/models/models.dart';
import 'package:better_person/routes/app_routes.dart';

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
    await TransactionController().clear();
    await WalletController().clear();
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

  testWidgets('profile screen shows the stored name and avatar initial', (
    tester,
  ) async {
    final now = DateTime.now();
    await tester.runAsync(
      () => UserController().create(
        User(
          id: 'test_user',
          name: 'Fian',
          streak: 3,
          dailyProgress: 0,
          totalHabitsDone: 0,
          totalFocusHours: 0,
          totalKindActs: 0,
          growthScore: 0,
          createdAt: now,
          updatedAt: now,
        ),
      ),
    );
    await tester.pumpWidget(_app(const ProfileScreen()));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Fian'), findsOneWidget);
    // Once in the profile header avatar, once in the app bar avatar.
    expect(find.text('F'), findsNWidgets(2));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('financial journal card renders real spending data', (
    tester,
  ) async {
    final now = DateTime.now();
    await tester.runAsync(
      () => TransactionController().create(
        Transaction(
          id: 'txn_journal',
          walletId: 'wallet_journal',
          amount: 120,
          type: TransactionType.expense,
          category: TransactionCategory.foodAndDrink,
          date: now,
          createdAt: now,
        ),
      ),
    );
    await tester.pumpWidget(
      _app(Scaffold(body: FinancialJournalCard(onViewAnalysis: () {}))),
    );
    await tester.pump();
    expect(find.text('Spending Mix'), findsOneWidget);
    expect(find.text('EXTREMES'), findsOneWidget);
    expect(find.text('No spending recorded this month yet.'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tapping a wallet card opens the edit wallet screen', (
    tester,
  ) async {
    final now = DateTime.now();
    await tester.runAsync(
      () => WalletController().create(
        Wallet(
          id: 'wallet_edit',
          name: 'Dompet Utama',
          type: WalletType.general,
          icon: WalletIcon.wallet,
          initialBalance: 100,
          currentBalance: 100,
          accountNumber: '**** 1234',
          createdAt: now,
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: HabitFocusTheme.themeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.wallet,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Dompet Utama'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Dompet'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('daily consistency bars render with a visible width', (
    tester,
  ) async {
    final now = DateTime.now();
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final records = [
      for (var index = 6; index >= 0; index--)
        DailyConsistencyRecord(
          id: 'consistency_$index',
          date: now.subtract(Duration(days: index)),
          dayLabel: labels[now.subtract(Duration(days: index)).weekday - 1],
          ratio: index == 0 ? 1 : 0,
        ),
    ];
    await tester.pumpWidget(
      _app(Scaffold(body: ConsistencyPanel(records: records))),
    );
    await tester.pump();

    final bars = find.byType(FractionallySizedBox);
    expect(bars, findsNWidgets(records.length));
    expect(tester.getSize(bars.first).width, greaterThan(0));
    expect(tester.getSize(bars.last).height, greaterThan(0));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
