import '../controllers/controllers.dart';
import '../models/models.dart';

/// Service for automatically checking habits when tasks/activities are completed.
/// This ensures habits are only checked through actual task completion, not manual toggling.
class HabitAutoChecker {
  static final HabitAutoChecker _instance = HabitAutoChecker._internal();
  
  factory HabitAutoChecker() {
    return _instance;
  }
  
  HabitAutoChecker._internal();

  final _habitController = HabitController();
  final _focusSessionController = FocusSessionController();
  final _kindnessLogController = KindnessLogController();
  final _prayerController = PrayerController();
  final _quranSessionController = QuranSessionController();

  /// Check habit when a focus session completes
  Future<void> onFocusSessionComplete(FocusSession session) async {
    final habits = _habitController.getAll();
    
    // Check "Deep Work Session" or similar work habit
    final workHabit = habits.where((h) => 
      (h.title.toLowerCase().contains('deep work') || 
       h.title.toLowerCase().contains('work session')) &&
      h.category == HabitCategory.work
    ).firstOrNull;
    
    if (workHabit != null && !workHabit.isCompleted) {
      await _habitController.markCompleted(workHabit.id);
    }
  }

  /// Check habit when a task is completed
  Future<void> onTaskComplete(Task task) async {
    // Can extend this to check specific habits based on task tags/priority
    final habits = _habitController.getAll();
    
    // If task has "Deep Work" tag, check work habit
    if (task.tags.any((tag) => tag.toLowerCase().contains('deep work'))) {
      final workHabit = habits.where((h) => 
        h.title.toLowerCase().contains('work') &&
        h.category == HabitCategory.work
      ).firstOrNull;
      
      if (workHabit != null && !workHabit.isCompleted) {
        await _habitController.markCompleted(workHabit.id);
      }
    }
  }

  /// Check habit when kindness acts are logged
  Future<void> onKindnessLogComplete(KindnessLog log) async {
    if (log.selectedActIds.isEmpty) return;
    
    final habits = _habitController.getAll();
    
    // Check "Daily Impact" or kindness habit
    final kindnessHabit = habits.where((h) => 
      (h.title.toLowerCase().contains('impact') || 
       h.title.toLowerCase().contains('kindness')) &&
      h.category == HabitCategory.kindness
    ).firstOrNull;
    
    if (kindnessHabit != null && !kindnessHabit.isCompleted) {
      await _habitController.markCompleted(kindnessHabit.id);
    }
  }

  /// Check habit when morning meditation/growth activity completes
  Future<void> onMeditationComplete() async {
    final habits = _habitController.getAll();
    
    // Check "Morning Meditation" or growth habit
    final meditationHabit = habits.where((h) => 
      (h.title.toLowerCase().contains('meditation') || 
       h.title.toLowerCase().contains('mindful')) &&
      h.category == HabitCategory.growth
    ).firstOrNull;
    
    if (meditationHabit != null && !meditationHabit.isCompleted) {
      await _habitController.markCompleted(meditationHabit.id);
    }
  }

  /// Check habit when prayers are completed
  Future<void> onPrayersComplete() async {
    final todayPrayers = _prayerController.getTodayPrayers();
    
    // If all prayers for today are checked, mark devotion habit complete
    if (todayPrayers.isNotEmpty && todayPrayers.every((p) => p.isChecked)) {
      final habits = _habitController.getAll();
      
      final devotionHabit = habits.where((h) => 
        h.category == HabitCategory.devotion
      ).firstOrNull;
      
      if (devotionHabit != null && !devotionHabit.isCompleted) {
        await _habitController.markCompleted(devotionHabit.id);
      }
    }
  }

  /// Check habit when Quran session completes
  Future<void> onQuranSessionComplete(QuranSession session) async {
    if (!session.isCompleted) return;
    
    final habits = _habitController.getAll();
    
    // Check devotion habit
    final devotionHabit = habits.where((h) => 
      h.category == HabitCategory.devotion &&
      (h.title.toLowerCase().contains('quran') ||
       h.title.toLowerCase().contains('reading'))
    ).firstOrNull;
    
    if (devotionHabit != null && !devotionHabit.isCompleted) {
      await _habitController.markCompleted(devotionHabit.id);
    }
  }

  /// Get habit completion progress for today
  Future<Map<String, dynamic>> getTodayProgress() async {
    final habits = _habitController.getAll();
    final completedCount = habits.where((h) => h.isCompleted).length;
    final totalCount = habits.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return {
      'completed': completedCount,
      'total': totalCount,
      'progress': progress,
    };
  }

  /// Reset daily habits (should be called at start of new day)
  Future<void> resetDailyHabits() async {
    final habits = _habitController.getAll();
    
    for (final habit in habits) {
      if (habit.isCompleted) {
        await _habitController.markIncomplete(habit.id);
      }
    }
  }

  /// Update user statistics based on habit completions
  Future<void> updateUserStats() async {
    final userController = UserController();
    final users = userController.getAll();
    
    if (users.isEmpty) return;
    
    final user = users.first;
    final progressData = await getTodayProgress();
    
    await userController.updateFields(user.id, {
      'dailyProgress': progressData['progress'],
    });
  }
}
