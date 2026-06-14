import '../controllers/controllers.dart';

/// Initialize all controllers by loading their persisted data from disk.
/// This should be called once at app startup.
class ControllerInitializer {
  static bool _initialized = false;

  /// Initialize all controllers
  static Future<void> initializeAll() async {
    if (_initialized) return;

    await Future.wait([
      UserController().init(),
      HabitController().init(),
      TaskController().init(),
      PrayerController().init(),
      FocusSessionController().init(),
      QuranSessionController().init(),
      KindnessLogController().init(),
      KindnessActController().init(),
      SpiritualMomentController().init(),
      DzikirEntryController().init(),
      CustomDevotionController().init(),
      BadgeController().init(),
      GrowthScoreController().init(),
      ActivitySummaryController().init(),
      DailyConsistencyRecordController().init(),
    ]);

    _initialized = true;
  }

  /// Check if controllers have been initialized
  static bool get isInitialized => _initialized;
}
