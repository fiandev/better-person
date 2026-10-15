import '../models/prayer.dart';
import 'kindness_log_controller.dart';
import 'prayer_controller.dart';

class StatisticsMetrics {
  const StatisticsMetrics(this._prayers, this._kindness);

  final PrayerController _prayers;
  final KindnessLogController _kindness;

  (int, int) prayerDetail(DateTime start, DateTime end) {
    final now = DateTime.now();
    final prayers = _prayers.getAll().where(
      (prayer) => !prayer.date.isBefore(start) && prayer.date.isBefore(end),
    );
    var onTime = 0;
    var missed = 0;
    for (final prayer in prayers) {
      final scheduled = DateTime(
        prayer.date.year,
        prayer.date.month,
        prayer.date.day,
        prayer.scheduledTime.hour,
        prayer.scheduledTime.minute,
      );
      if (prayer.isChecked &&
          prayer.checkedAt != null &&
          !prayer.checkedAt!.isAfter(scheduled)) {
        onTime++;
      } else if (!prayer.isChecked && scheduled.isBefore(now)) {
        missed++;
      }
    }
    return (onTime, missed);
  }

  int devotionStreak() {
    final now = DateTime.now();
    var date = DateTime(now.year, now.month, now.day);
    final today = _prayers.getByDate(date);
    if (today.length != PrayerName.values.length ||
        today.any((prayer) => !prayer.isChecked)) {
      date = date.subtract(const Duration(days: 1));
    }
    var streak = 0;
    for (var days = 0; days < 365; days++) {
      final prayers = _prayers.getByDate(date);
      if (prayers.length != PrayerName.values.length ||
          prayers.any((prayer) => !prayer.isChecked)) {
        break;
      }
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int kindnessStreak() {
    final now = DateTime.now();
    var date = DateTime(now.year, now.month, now.day);
    if (_kindness.getByDate(date).every((log) => log.selectedActIds.isEmpty)) {
      date = date.subtract(const Duration(days: 1));
    }
    var streak = 0;
    for (var days = 0; days < 365; days++) {
      final logs = _kindness.getByDate(date);
      if (logs.every((log) => log.selectedActIds.isEmpty)) break;
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
