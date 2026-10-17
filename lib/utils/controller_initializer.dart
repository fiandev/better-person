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
      HabitCompletionController().init(),
      TaskController().init(),
      PrayerController().init(),
      FocusSessionController().init(),
      QuranSessionController().init(),
      KindnessLogController().init(),
      KindnessActController().init(),
      SpiritualMomentController().init(),
      DzikirEntryController().init(),
      CustomDevotionController().init(),
      GrowthScoreController().init(),
      ActivitySummaryController().init(),
      DailyConsistencyRecordController().init(),
      WalletController().init(),
      TransactionController().init(),
      SettingController().init(),
    ]);

    _initialized = true;
  }

  static Future<void> reloadAll() async {
    await Future.wait([
      UserController().reload(),
      HabitController().reload(),
      HabitCompletionController().reload(),
      TaskController().reload(),
      PrayerController().reload(),
      FocusSessionController().reload(),
      QuranSessionController().reload(),
      KindnessLogController().reload(),
      KindnessActController().reload(),
      SpiritualMomentController().reload(),
      DzikirEntryController().reload(),
      CustomDevotionController().reload(),
      GrowthScoreController().reload(),
      ActivitySummaryController().reload(),
      DailyConsistencyRecordController().reload(),
      WalletController().reload(),
      TransactionController().reload(),
      SettingController().reload(),
    ]);
  }

  /// Check if controllers have been initialized
  static bool get isInitialized => _initialized;
}
