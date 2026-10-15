import 'package:flutter/material.dart';

import '../theme/habit_focus_theme.dart';
import '../widgets/habit_focus_app_bar.dart';
import '../widgets/home/greeting_section.dart';
import '../widgets/home/bento_grid.dart';
import '../widgets/home/key_habits_section.dart';
import '../widgets/home/home_quick_actions.dart';
import '../widgets/home/weekly_summary_preview.dart';
import '../../routes/route_shell.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';
import '../../utils/default_data_seeder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _userController = UserController();
  final _habitController = HabitController();
  final _focusSessionController = FocusSessionController();
  final _kindnessLogController = KindnessLogController();

  User? _currentUser;
  List<Habit> _habits = [];
  double _todayProgress = 0.0;
  String _deepWorkTime = '0h 0m';
  int _devotionCount = 0;
  int _weeklyFocusMinutes = 0;
  int _weeklyKindnessActs = 0;
  bool _isLoading = false;
  bool _refreshPending = false;

  static const _dailyTips = [
    'Choose one habit and begin with a small step.',
    'Make room for a focused block before the day fills up.',
    'Notice one opportunity to make someone’s day easier.',
    'A short reflection can help you choose what matters next.',
    'Return to your routine gently after a busy day.',
    'Start with the next useful action, not the whole list.',
    'Give your attention to one thing at a time.',
  ];

  @override
  void initState() {
    super.initState();
    _userController.addListener(_reloadFromChanges);
    _habitController.addListener(_reloadFromChanges);
    _focusSessionController.addListener(_reloadFromChanges);
    _kindnessLogController.addListener(_reloadFromChanges);
    _loadData();
  }

  @override
  void dispose() {
    _userController.removeListener(_reloadFromChanges);
    _habitController.removeListener(_reloadFromChanges);
    _focusSessionController.removeListener(_reloadFromChanges);
    _kindnessLogController.removeListener(_reloadFromChanges);
    super.dispose();
  }

  void _reloadFromChanges() {
    if (_isLoading) {
      _refreshPending = true;
    } else if (mounted) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      // Get or create default user
      User? user = _userController.getAll().isNotEmpty
          ? _userController.getAll().first
          : null;

      user ??= await _createDefaultUser();

      // Get all habits
      final habits = _habitController.getAll();

      // Calculate today's progress
      final completedCount = habits.where((h) => h.isCompleted).length;
      final totalCount = habits.length;
      final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

      // Calculate deep work time from focus sessions
      final focusSessions = _focusSessionController.getAll();
      final currentDate = DateTime.now();
      final weekStart = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day - currentDate.weekday + 1,
      );
      final totalMinutes = focusSessions.fold<int>(
        0,
        (sum, session) => sum + session.elapsed.inMinutes,
      );
      final weeklyMinutes = focusSessions
          .where((session) => !session.createdAt.isBefore(weekStart))
          .fold<int>(0, (sum, session) => sum + session.elapsed.inMinutes);
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;

      // Count devotion habits completed
      final devotionHabits = habits.where(
        (h) => h.category == HabitCategory.devotion && h.isCompleted,
      );

      final kindnessLogs = _kindnessLogController.getThisWeekLogs();
      final weeklyActs = kindnessLogs.fold<int>(
        0,
        (sum, log) => sum + log.selectedActIds.length,
      );

      final orderedHabits = [...habits]
        ..sort((a, b) {
          if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
          const categoryOrder = {
            HabitCategory.devotion: 0,
            HabitCategory.work: 1,
            HabitCategory.kindness: 2,
            HabitCategory.growth: 3,
          };
          return categoryOrder[a.category]!.compareTo(
            categoryOrder[b.category]!,
          );
        });

      if (!mounted) return;
      setState(() {
        _currentUser = user;
        _habits = orderedHabits;
        _todayProgress = progress;
        _deepWorkTime = '${hours}h ${minutes}m';
        _devotionCount = devotionHabits.length;
        _weeklyFocusMinutes = weeklyMinutes;
        _weeklyKindnessActs = weeklyActs;
      });
    } finally {
      _isLoading = false;
      if (_refreshPending && mounted) {
        _refreshPending = false;
        _loadData();
      }
    }
  }

  Future<User> _createDefaultUser() async {
    final user = User(
      id: 'user_1',
      name: 'Friend',
      streak: 0,
      dailyProgress: 0.0,
      totalHabitsDone: 0,
      totalFocusHours: 0.0,
      totalKindActs: 0,
      growthScore: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _userController.create(user);
    await DefaultDataSeeder.seedHabits();

    return user;
  }

  // Habits are automatically checked when tasks/activities complete
  // Users cannot manually toggle habits

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HabitFocusAppBar(overrideTitle: 'Home'),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
          children: [
            GreetingSection(
              userName: _currentUser?.name ?? 'Friend',
              greeting: _getGreeting(),
            ),
            const SizedBox(height: HabitFocusTheme.sectionGap),
            const HomeQuickActions(),
            const SizedBox(height: HabitFocusTheme.sectionGap),
            BentoGrid(
              todayProgress: _todayProgress,
              streak: _currentUser?.streak ?? 0,
              deepWorkTime: _deepWorkTime,
              devotionCount: _devotionCount,
            ),
            const SizedBox(height: HabitFocusTheme.sectionGap),
            KeyHabitsSection(habits: _habits.take(3).toList()),
            const SizedBox(height: HabitFocusTheme.sectionGap),
            WeeklySummaryPreview(
              focusMinutes: _weeklyFocusMinutes,
              kindnessActs: _weeklyKindnessActs,
            ),
            const SizedBox(height: HabitFocusTheme.stackGap),
            Text(
              _dailyTips[DateTime.now().weekday - 1],
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 0),
    );
  }
}
