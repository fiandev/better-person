import 'package:flutter/material.dart';

import '../theme/habit_focus_theme.dart';
import '../widgets/habit_focus_app_bar.dart';
import '../widgets/home/greeting_section.dart';
import '../widgets/home/bento_grid.dart';
import '../widgets/home/key_habits_section.dart';
import '../../routes/route_shell.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _userController = UserController();
  final _habitController = HabitController();
  final _focusSessionController = FocusSessionController();

  User? _currentUser;
  List<Habit> _habits = [];
  double _todayProgress = 0.0;
  String _deepWorkTime = '0h 0m';
  int _devotionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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
    final totalMinutes = focusSessions.fold<int>(
      0,
      (sum, session) => sum + session.elapsed.inMinutes,
    );
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    // Count devotion habits completed
    final devotionHabits = habits.where(
      (h) => h.category == HabitCategory.devotion && h.isCompleted,
    );

    setState(() {
      _currentUser = user;
      _habits = habits;
      _todayProgress = progress;
      _deepWorkTime = '${hours}h ${minutes}m';
      _devotionCount = devotionHabits.length;
    });
  }

  Future<User> _createDefaultUser() async {
    final user = User(
      id: 'user_1',
      name: 'Sarah',
      streak: 12,
      dailyProgress: 0.0,
      totalHabitsDone: 0,
      totalFocusHours: 0.0,
      totalKindActs: 0,
      growthScore: 0.65,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _userController.create(user);
    await _createDefaultHabits();

    return user;
  }

  Future<void> _createDefaultHabits() async {
    final defaultHabits = [
      // Habit(
      //   id: 'habit_1',
      //   title: 'Morning Meditation',
      //   category: HabitCategory.growth,
      //   duration: '10 mins',
      //   isCompleted: true,
      //   createdAt: now,
      //   completedAt: now,
      // ),
      // Habit(
      //   id: 'habit_2',
      //   title: 'Deep Work Session',
      //   category: HabitCategory.work,
      //   duration: '90 mins',
      //   isCompleted: false,
      //   createdAt: now,
      // ),
      // Habit(
      //   id: 'habit_3',
      //   title: 'Daily Impact',
      //   category: HabitCategory.kindness,
      //   duration: 'Any amount',
      //   isCompleted: false,
      //   createdAt: now,
      // ),
    ];

    for (final habit in defaultHabits) {
      await _habitController.create(habit);
    }
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
              children: [
                GreetingSection(
                  userName: _currentUser?.name ?? 'Friend',
                  greeting: _getGreeting(),
                ),
                const SizedBox(height: HabitFocusTheme.sectionGap),
                BentoGrid(
                  todayProgress: _todayProgress,
                  streak: _currentUser?.streak ?? 0,
                  deepWorkTime: _deepWorkTime,
                  devotionCount: _devotionCount,
                ),
                const SizedBox(height: HabitFocusTheme.sectionGap),
                KeyHabitsSection(habits: _habits.take(3).toList()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 0),
    );
  }
}
