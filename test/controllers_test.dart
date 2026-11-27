import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_person/controllers/controllers.dart';
import 'package:better_person/models/models.dart';
import 'package:better_person/utils/daily_reset_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    final tempDir = Directory.systemTemp.createTempSync('better_person_test_');
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => tempDir.path,
        );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserController().clear();
    await HabitController().clear();
    await HabitCompletionController().clear();
    await TaskController().clear();
    await WalletController().clear();
    await TransactionController().clear();
    await SettingController().clear();
    await PrayerController().clear();
    await KindnessLogController().clear();
    await QuranSessionController().clear();
    await DzikirEntryController().clear();
    await CustomDevotionController().clear();
    await FocusSessionController().clear();
  });

  test('activity dates build and reset a consecutive streak', () async {
    final controller = UserController();
    final start = DateTime(2026, 2, 1);
    await controller.create(_user(start));

    await controller.recordActivity(start);
    expect(controller.getCurrentUser().streak, 1);
    await controller.recordActivity(start.add(const Duration(hours: 6)));
    expect(controller.getCurrentUser().streak, 1);
    await controller.recordActivity(start.add(const Duration(days: 1)));
    expect(controller.getCurrentUser().streak, 2);
    await controller.recordActivity(start.add(const Duration(days: 3)));
    expect(controller.getCurrentUser().streak, 1);
    expect(controller.getCurrentUser().lastActivityDate, DateTime(2026, 2, 4));
  });

  test(
    'completed habits retain daily records after their state resets',
    () async {
      final controller = HabitController();
      final now = DateTime.now();
      final habit = Habit(
        id: 'habit_test',
        title: 'Read',
        category: HabitCategory.growth,
        isCompleted: false,
        createdAt: now,
      );
      await controller.create(habit);
      await controller.markCompleted(habit.id);
      await controller.markIncomplete(habit.id);

      final records = HabitCompletionController().getByDate(now);
      expect(records.map((record) => record.habitId), contains(habit.id));
      expect(controller.getById(habit.id)?.isCompleted, isFalse);
    },
  );

  test('task queue reorder persists order and priority breaks ties', () async {
    final controller = TaskController();
    final now = DateTime.now();
    for (final (id, order, priority) in [
      ('low', 0, TaskPriority.low),
      ('high', 0, TaskPriority.high),
    ]) {
      await controller.create(
        Task(
          id: id,
          title: id,
          tags: const [],
          priority: priority,
          isCompleted: false,
          sortOrder: order,
          createdAt: now,
        ),
      );
    }
    expect(controller.getSorted().first.id, 'high');
    await controller.reorderTasks(['low', 'high']);
    expect(controller.getSorted().map((task) => task.id).toList(), [
      'low',
      'high',
    ]);
  });

  test('editing and deleting a transaction reverses wallet balances', () async {
    final wallet = Wallet(
      id: 'wallet_test',
      name: 'Cash',
      type: WalletType.general,
      icon: WalletIcon.wallet,
      initialBalance: 100,
      currentBalance: 80,
      accountNumber: '',
      createdAt: DateTime.now(),
    );
    await WalletController().create(wallet);
    final now = DateTime.now();
    final transaction = Transaction(
      id: 'transaction_test',
      walletId: wallet.id,
      amount: 20,
      type: TransactionType.expense,
      category: TransactionCategory.other,
      date: now,
      createdAt: now,
    );
    await TransactionController().create(transaction);

    expect(
      await TransactionController().updateAndRebalance(
        transaction.id,
        transaction.copyWith(amount: 30),
      ),
      isTrue,
    );
    expect(WalletController().getById(wallet.id)?.currentBalance, 70);
    expect(
      await TransactionController().deleteAndReverse(transaction.id),
      isTrue,
    );
    expect(WalletController().getById(wallet.id)?.currentBalance, 100);
  });

  test('prayer controller finds the next scheduled prayer', () async {
    final controller = PrayerController();
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day);
    for (final entry in [
      (PrayerName.fajr, const TimeOfDay(hour: 5, minute: 0)),
      (PrayerName.asr, const TimeOfDay(hour: 15, minute: 0)),
    ]) {
      await controller.create(
        Prayer(
          id: 'prayer_${entry.$1.name}',
          name: entry.$1,
          scheduledTime: entry.$2,
          isChecked: false,
          date: date,
        ),
      );
    }
    final next = controller.getNextPrayer(
      DateTime(now.year, now.month, now.day, 12),
    );
    expect(next?.name, PrayerName.asr);
  });

  test('kindness logging stores acts and reflection', () async {
    await KindnessLogController().logKindness([
      'act_1',
    ], 'I helped a neighbor.');
    expect(
      KindnessLogController().getTodayLog()?.reflectionText,
      'I helped a neighbor.',
    );
  });

  test('statistics consistency includes retained habit records', () async {
    final today = DateTime.now();
    final habit = Habit(
      id: 'habit_consistency',
      title: 'Read',
      category: HabitCategory.growth,
      isCompleted: false,
      createdAt: today,
    );
    await HabitController().create(habit);
    await HabitCompletionController().record(habit.id, today);
    final records = await StatisticsService().calculateDailyConsistency();
    expect(records.last.isToday, isTrue);
    expect(records.last.ratio, 1);
  });

  test('daily reset marks completed habits incomplete', () async {
    final habit = Habit(
      id: 'habit_reset',
      title: 'Read',
      category: HabitCategory.growth,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    await HabitController().create(habit);
    await HabitController().markCompleted(habit.id);
    await DailyResetService.forceReset();
    expect(HabitController().getById(habit.id)?.isCompleted, isFalse);
  });

  test('growth score formats normalized score as a percentage', () {
    final score = GrowthScore(
      id: 'score',
      score: 0.75,
      trend: 0.1,
      description: 'Test',
      weekStartDate: DateTime(2026, 2, 2),
    );
    expect(score.scoreLabel, '75%');
    expect(score.trendLabel, '+10%');
  });

  test('focus timer anchor persists so elapsed survives resume', () async {
    final controller = FocusSessionController();
    final now = DateTime.now();
    final session = FocusSession(
      id: 'session_anchor',
      category: 'Work Focus',
      name: 'Deep Work',
      timerDuration: const Duration(minutes: 25),
      elapsed: const Duration(minutes: 5),
      timerState: TimerState.idle,
      upNextTaskIds: const [],
      createdAt: now,
    );
    await controller.create(session);

    final started = await controller.startFocus(session.id);
    final anchor = started?.timerStartedAt;
    expect(started?.timerState, TimerState.focusing);
    expect(anchor, isNotNull);
    // Anchor is rewound so that now - anchor ≈ the stored elapsed time.
    expect(
      DateTime.now().difference(anchor!).inMilliseconds,
      closeTo(const Duration(minutes: 5).inMilliseconds, 1000),
    );

    // Anchor must survive an app restart (JSON round-trip).
    final restored = FocusSession.fromJson(started!.toJson());
    expect(restored.timerStartedAt, anchor);

    final paused = await controller.pause(session.id);
    expect(paused?.timerStartedAt, isNull);
  });
}

User _user(DateTime createdAt) => User(
  id: 'user_test',
  name: 'Test',
  streak: 0,
  dailyProgress: 0,
  totalHabitsDone: 0,
  totalFocusHours: 0,
  totalKindActs: 0,
  growthScore: 0,
  createdAt: createdAt,
  updatedAt: createdAt,
);
