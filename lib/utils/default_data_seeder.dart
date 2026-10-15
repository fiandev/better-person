import '../controllers/habit_controller.dart';
import '../models/habit.dart';

class DefaultDataSeeder {
  static Future<void> seedHabits() async {
    final controller = HabitController();
    if (controller.getAll().isNotEmpty) return;

    final now = DateTime.now();
    const defaults = [
      ('Daily reflection', HabitCategory.growth, 'Take a moment to reflect'),
      ('Deep work session', HabitCategory.work, 'Complete a focus session'),
      ('One kindness act', HabitCategory.kindness, 'Log an act of kindness'),
      ('Daily prayers', HabitCategory.devotion, 'Complete the daily prayers'),
      (
        'Quran reading',
        HabitCategory.devotion,
        'Read toward your daily page goal',
      ),
      ('Daily dzikir', HabitCategory.devotion, 'Complete your dzikir counters'),
    ];
    for (var index = 0; index < defaults.length; index++) {
      final (title, category, subtitle) = defaults[index];
      await controller.create(
        Habit(
          id: 'habit_default_$index',
          title: title,
          category: category,
          subtitle: subtitle,
          isCompleted: false,
          createdAt: now,
        ),
      );
    }
  }
}
