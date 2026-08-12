import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/controllers.dart';

class DailyResetService {
  static const String _lastResetKey = 'last_reset_date';
  static Timer? _timer;
  
  /// Initialize the daily reset service
  static Future<void> initialize() async {
    // Check if reset is needed on startup
    await _checkAndReset();
    
    // Schedule periodic checks (every 10 minutes)
    _timer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _checkAndReset(),
    );
  }
  
  /// Stop the reset service
  static void dispose() {
    _timer?.cancel();
    _timer = null;
  }
  
  /// Check if reset is needed and perform it
  static Future<void> _checkAndReset() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetString = prefs.getString(_lastResetKey);
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    DateTime? lastReset;
    if (lastResetString != null) {
      lastReset = DateTime.parse(lastResetString);
      lastReset = DateTime(lastReset.year, lastReset.month, lastReset.day);
    }
    
    // If never reset or last reset was before today, perform reset
    if (lastReset == null || lastReset.isBefore(today)) {
      print('Performing daily reset...');
      await _performReset();
      await prefs.setString(_lastResetKey, today.toIso8601String());
      print('Daily reset completed');
    }
  }
  
  /// Perform the actual reset operations
  static Future<void> _performReset() async {
    try {
      // Reset habits
      await _resetHabits();
      
      // Regenerate prayers
      await _regeneratePrayers();
      
      // Reset custom devotions
      await _resetCustomDevotions();
      
    } catch (e) {
      print('Error during daily reset: $e');
    }
  }
  
  /// Reset all habits to incomplete
  static Future<void> _resetHabits() async {
    final habitController = HabitController();
    final habits = habitController.getAll();
    
    for (var habit in habits) {
      if (habit.isCompleted) {
        await habitController.markIncomplete(habit.id);
      }
    }
    
    print('Reset ${habits.length} habits');
  }
  
  /// Generate today's prayers
  static Future<void> _regeneratePrayers() async {
    final prayerController = PrayerController();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    // Check if today's prayers already exist
    final existingPrayers = prayerController.findWhere(
      (prayer) => _isSameDay(prayer.date, todayDate)
    );
    
    if (existingPrayers.isNotEmpty) {
      print('Today\'s prayers already exist');
      return;
    }
    
    // Create new prayers for today
    await prayerController.initializeDailyPrayers();
    print('Generated prayers for today');
  }
  
  /// Reset custom devotions for the new day
  static Future<void> _resetCustomDevotions() async {
    final customDevotionController = CustomDevotionController();
    final devotions = customDevotionController.getAll();
    
    for (var devotion in devotions) {
      if (devotion.isCompleted) {
        await customDevotionController.markIncomplete(devotion.id);
      }
    }
    
    print('Reset ${devotions.length} custom devotions');
  }
  
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Manual reset (for testing)
  static Future<void> forceReset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastResetKey);
    await _performReset();
  }
}
