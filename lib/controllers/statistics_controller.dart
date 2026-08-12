import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/controllers/habit_controller.dart';
import 'package:better_person/controllers/focus_session_controller.dart';
import 'package:better_person/controllers/prayer_controller.dart';
import 'package:better_person/controllers/kindness_log_controller.dart';
import 'package:better_person/models/models.dart';

/// Controller for Badge model
class BadgeController extends BaseController<Badge> {
  static final BadgeController _instance = BadgeController._internal();
  
  factory BadgeController() {
    return _instance;
  }
  
  BadgeController._internal();

  @override
  String get storageKey => 'badges';

  @override
  Map<String, dynamic> toJson(Badge item) => item.toJson();

  @override
  Badge fromJson(Map<String, dynamic> json) => Badge.fromJson(json);

  @override
  Badge? getById(String id) {
    try {
      return items.firstWhere((badge) => badge.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Badge> create(Badge badge) async {
    items.add(badge);
    await persist();
    return badge;
  }

  @override
  Future<Badge?> update(String id, Badge badge) async {
    final index = items.indexWhere((b) => b.id == id);
    if (index == -1) return null;
    
    items[index] = badge;
    await persist();
    return badge;
  }

  @override
  Future<Badge?> updateFields(String id, Map<String, dynamic> fields) async {
    final badge = getById(id);
    if (badge == null) return null;

    final updated = badge.copyWith(
      title: fields['title'] as String? ?? badge.title,
      icon: fields['icon'] ?? badge.icon,
      backgroundColor: fields['backgroundColor'] ?? badge.backgroundColor,
      detail: fields['detail'] as String? ?? badge.detail,
      earnedDate: fields.containsKey('earnedDate') ? fields['earnedDate'] as DateTime? : badge.earnedDate,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, Badge>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, Badge>{};
    
    for (final entry in updates.entries) {
      final updated = await updateFields(entry.key, entry.value);
      if (updated != null) {
        result[entry.key] = updated;
      }
    }
    
    return result;
  }

  @override
  Future<bool> delete(String id) async {
    final initialLength = items.length;
    items.removeWhere((badge) => badge.id == id);
    final deleted = items.length < initialLength;
    if (deleted) await persist();
    return deleted;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((badge) => ids.contains(badge.id));
    final deletedCount = initialLength - items.length;
    if (deletedCount > 0) await persist();
    return deletedCount;
  }

  /// Get earned badges
  List<Badge> getEarned() {
    return findWhere((badge) => badge.earnedDate != null);
  }

  /// Get unearned badges
  List<Badge> getUnearned() {
    return findWhere((badge) => badge.earnedDate == null);
  }

  /// Mark badge as earned
  Future<Badge?> markEarned(String id) async {
    return updateFields(id, {'earnedDate': DateTime.now()});
  }
}

/// Controller for GrowthScore model
class GrowthScoreController extends BaseController<GrowthScore> {
  static final GrowthScoreController _instance = GrowthScoreController._internal();
  
  factory GrowthScoreController() {
    return _instance;
  }
  
  GrowthScoreController._internal();

  @override
  String get storageKey => 'growth_scores';

  @override
  Map<String, dynamic> toJson(GrowthScore item) => item.toJson();

  @override
  GrowthScore fromJson(Map<String, dynamic> json) => GrowthScore.fromJson(json);

  @override
  GrowthScore? getById(String id) {
    try {
      return items.firstWhere((score) => score.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<GrowthScore> create(GrowthScore score) async {
    items.add(score);
    await persist();
    return score;
  }

  @override
  Future<GrowthScore?> update(String id, GrowthScore score) async {
    final index = items.indexWhere((s) => s.id == id);
    if (index == -1) return null;
    
    items[index] = score;
    await persist();
    return score;
  }

  @override
  Future<GrowthScore?> updateFields(String id, Map<String, dynamic> fields) async {
    final score = getById(id);
    if (score == null) return null;

    final updated = score.copyWith(
      score: fields['score'] as double? ?? score.score,
      trend: fields['trend'] as double? ?? score.trend,
      description: fields['description'] as String? ?? score.description,
      weekStartDate: fields['weekStartDate'] as DateTime? ?? score.weekStartDate,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, GrowthScore>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, GrowthScore>{};
    
    for (final entry in updates.entries) {
      final updated = await updateFields(entry.key, entry.value);
      if (updated != null) {
        result[entry.key] = updated;
      }
    }
    
    return result;
  }

  @override
  Future<bool> delete(String id) async {
    final initialLength = items.length;
    items.removeWhere((score) => score.id == id);
    final deleted = items.length < initialLength;
    if (deleted) await persist();
    return deleted;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((score) => ids.contains(score.id));
    final deletedCount = initialLength - items.length;
    if (deletedCount > 0) await persist();
    return deletedCount;
  }

  /// Get current week's score
  GrowthScore? getCurrentWeekScore() {
    final now = DateTime.now();
    return findFirst((score) {
      final weekStart = score.weekStartDate;
      final weekEnd = weekStart.add(const Duration(days: 6));
      return now.isAfter(weekStart.subtract(const Duration(days: 1))) &&
             now.isBefore(weekEnd.add(const Duration(days: 1)));
    });
  }
}

/// Controller for ActivitySummary model
class ActivitySummaryController extends BaseController<ActivitySummary> {
  static final ActivitySummaryController _instance = ActivitySummaryController._internal();
  
  factory ActivitySummaryController() {
    return _instance;
  }
  
  ActivitySummaryController._internal();

  @override
  String get storageKey => 'activity_summaries';

  @override
  Map<String, dynamic> toJson(ActivitySummary item) => item.toJson();

  @override
  ActivitySummary fromJson(Map<String, dynamic> json) => ActivitySummary.fromJson(json);

  @override
  ActivitySummary? getById(String id) {
    try {
      return items.firstWhere((summary) => summary.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ActivitySummary> create(ActivitySummary summary) async {
    items.add(summary);
    await persist();
    return summary;
  }

  @override
  Future<ActivitySummary?> update(String id, ActivitySummary summary) async {
    final index = items.indexWhere((s) => s.id == id);
    if (index == -1) return null;
    
    items[index] = summary;
    await persist();
    return summary;
  }

  @override
  Future<ActivitySummary?> updateFields(String id, Map<String, dynamic> fields) async {
    final summary = getById(id);
    if (summary == null) return null;

    final updated = summary.copyWith(
      category: fields['category'] as ActivityCategory? ?? summary.category,
      label: fields['label'] as String? ?? summary.label,
      value: fields['value'] as String? ?? summary.value,
      subtitle: fields['subtitle'] as String? ?? summary.subtitle,
      trendLabel: fields.containsKey('trendLabel') ? fields['trendLabel'] as String? : summary.trendLabel,
      weekStartDate: fields['weekStartDate'] as DateTime? ?? summary.weekStartDate,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, ActivitySummary>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, ActivitySummary>{};
    
    for (final entry in updates.entries) {
      final updated = await updateFields(entry.key, entry.value);
      if (updated != null) {
        result[entry.key] = updated;
      }
    }
    
    return result;
  }

  @override
  Future<bool> delete(String id) async {
    final initialLength = items.length;
    items.removeWhere((summary) => summary.id == id);
    final deleted = items.length < initialLength;
    if (deleted) await persist();
    return deleted;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((summary) => ids.contains(summary.id));
    final deletedCount = initialLength - items.length;
    if (deletedCount > 0) await persist();
    return deletedCount;
  }

  /// Get summaries by category
  List<ActivitySummary> getByCategory(ActivityCategory category) {
    return findWhere((summary) => summary.category == category);
  }

  /// Get current week's summaries
  List<ActivitySummary> getCurrentWeekSummaries() {
    final now = DateTime.now();
    return findWhere((summary) {
      final weekStart = summary.weekStartDate;
      final weekEnd = weekStart.add(const Duration(days: 6));
      return now.isAfter(weekStart.subtract(const Duration(days: 1))) &&
             now.isBefore(weekEnd.add(const Duration(days: 1)));
    });
  }
}

/// Controller for DailyConsistencyRecord model
class DailyConsistencyRecordController extends BaseController<DailyConsistencyRecord> {
  static final DailyConsistencyRecordController _instance = DailyConsistencyRecordController._internal();
  
  factory DailyConsistencyRecordController() {
    return _instance;
  }
  
  DailyConsistencyRecordController._internal();

  @override
  String get storageKey => 'daily_consistency_records';

  @override
  Map<String, dynamic> toJson(DailyConsistencyRecord item) => item.toJson();

  @override
  DailyConsistencyRecord fromJson(Map<String, dynamic> json) => DailyConsistencyRecord.fromJson(json);

  @override
  DailyConsistencyRecord? getById(String id) {
    try {
      return items.firstWhere((record) => record.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DailyConsistencyRecord> create(DailyConsistencyRecord record) async {
    items.add(record);
    await persist();
    return record;
  }

  @override
  Future<DailyConsistencyRecord?> update(String id, DailyConsistencyRecord record) async {
    final index = items.indexWhere((r) => r.id == id);
    if (index == -1) return null;
    
    items[index] = record;
    await persist();
    return record;
  }

  @override
  Future<DailyConsistencyRecord?> updateFields(String id, Map<String, dynamic> fields) async {
    final record = getById(id);
    if (record == null) return null;

    final updated = record.copyWith(
      date: fields['date'] as DateTime? ?? record.date,
      dayLabel: fields['dayLabel'] as String? ?? record.dayLabel,
      ratio: fields['ratio'] as double? ?? record.ratio,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, DailyConsistencyRecord>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, DailyConsistencyRecord>{};
    
    for (final entry in updates.entries) {
      final updated = await updateFields(entry.key, entry.value);
      if (updated != null) {
        result[entry.key] = updated;
      }
    }
    
    return result;
  }

  @override
  Future<bool> delete(String id) async {
    final initialLength = items.length;
    items.removeWhere((record) => record.id == id);
    final deleted = items.length < initialLength;
    if (deleted) await persist();
    return deleted;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((record) => ids.contains(record.id));
    final deletedCount = initialLength - items.length;
    if (deletedCount > 0) await persist();
    return deletedCount;
  }

  /// Get records by date
  DailyConsistencyRecord? getByDate(DateTime date) {
    return findFirst((record) => 
      record.date.year == date.year &&
      record.date.month == date.month &&
      record.date.day == date.day
    );
  }

  /// Get records in date range
  List<DailyConsistencyRecord> getByDateRange(DateTime start, DateTime end) {
    return findWhere((record) => 
      record.date.isAfter(start.subtract(const Duration(days: 1))) &&
      record.date.isBefore(end.add(const Duration(days: 1)))
    );
  }

  /// Get current week's records
  List<DailyConsistencyRecord> getCurrentWeekRecords() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return getByDateRange(weekStart, weekEnd);
  }

  /// Get today's record
  DailyConsistencyRecord? getTodayRecord() {
    return getByDate(DateTime.now());
  }
}

/// Service for calculating statistics
class StatisticsService {
  final _badgeController = BadgeController();
  final _growthScoreController = GrowthScoreController();
  
  final _habitController = HabitController();
  final _focusSessionController = FocusSessionController();
  final _prayerController = PrayerController();
  final _kindnessLogController = KindnessLogController();
  
  /// Calculate growth score for current week
  Future<GrowthScore> calculateGrowthScore() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    // Calculate component scores (0-100 each)
    final habitScore = _calculateHabitScore(weekStart);
    final focusScore = _calculateFocusScore(weekStart);
    final devotionScore = _calculateDevotionScore(weekStart);
    final kindnessScore = _calculateKindnessScore(weekStart);
    
    // Weighted average
    final totalScore = (habitScore * 0.3) + 
                       (focusScore * 0.3) + 
                       (devotionScore * 0.2) + 
                       (kindnessScore * 0.2);
    
    // Calculate trend (compare to last week)
    final lastWeekScore = await _getLastWeekScore(weekStart);
    final trend = totalScore - lastWeekScore;
    
    return GrowthScore(
      id: '${weekStart.millisecondsSinceEpoch}',
      score: totalScore,
      trend: trend,
      description: _getScoreDescription(totalScore),
      weekStartDate: weekStart,
    );
  }
  
  double _calculateHabitScore(DateTime weekStart) {
    final habits = _habitController.getAll();
    if (habits.isEmpty) return 0;
    
    int completedThisWeek = 0;
    final totalPossible = habits.length * 7; // 7 days
    
    for (var habit in habits) {
      if (habit.isCompleted && 
          habit.completedAt != null && 
          habit.completedAt!.isAfter(weekStart)) {
        completedThisWeek++;
      }
    }
    
    return (completedThisWeek / totalPossible * 100).clamp(0, 100);
  }
  
  double _calculateFocusScore(DateTime weekStart) {
    final sessions = _focusSessionController.getAll();
    
    double totalHours = 0;
    for (var session in sessions) {
      if (session.createdAt.isAfter(weekStart)) {
        totalHours += session.elapsed.inSeconds / 3600; // Convert seconds to hours
      }
    }
    
    // Target: 20 hours per week = 100 score
    const targetHours = 20.0;
    return (totalHours / targetHours * 100).clamp(0, 100);
  }
  
  double _calculateDevotionScore(DateTime weekStart) {
    final prayers = _prayerController.getAll();
    
    int completedCount = 0;
    const totalPossible = 7 * 5; // 5 prayers per day for 7 days
    
    for (var prayer in prayers) {
      if (prayer.isChecked && prayer.date.isAfter(weekStart)) {
        completedCount++;
      }
    }
    
    return (completedCount / totalPossible * 100).clamp(0, 100);
  }
  
  double _calculateKindnessScore(DateTime weekStart) {
    final logs = _kindnessLogController.getAll();
    
    int actCount = 0;
    for (var log in logs) {
      if (log.date.isAfter(weekStart)) {
        actCount += log.selectedActIds.length;
      }
    }
    
    // Target: 14 acts per week = 100 score
    const targetActs = 14;
    return (actCount / targetActs * 100).clamp(0, 100);
  }
  
  Future<double> _getLastWeekScore(DateTime currentWeekStart) async {
    final lastWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    final lastWeekScore = _growthScoreController.findFirst((score) =>
      score.weekStartDate.year == lastWeekStart.year &&
      score.weekStartDate.month == lastWeekStart.month &&
      score.weekStartDate.day == lastWeekStart.day
    );
    
    return lastWeekScore?.score ?? 0.0;
  }
  
  String _getScoreDescription(double score) {
    if (score >= 80) return 'Excellent progress!';
    if (score >= 60) return 'Good work!';
    if (score >= 40) return 'Keep going!';
    return 'Let\'s improve!';
  }
  
  /// Calculate activity summaries for current week
  Future<List<ActivitySummary>> calculateActivitySummaries() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final summaries = <ActivitySummary>[];
    
    // Work Focus Summary
    final sessions = _focusSessionController.getAll();
    double weekFocusHours = 0;
    
    for (var session in sessions) {
      if (session.createdAt.isAfter(weekStart)) {
        weekFocusHours += session.elapsed.inSeconds / 3600;
      }
    }
    
    summaries.add(ActivitySummary(
      id: 'work_${weekStart.millisecondsSinceEpoch}',
      category: ActivityCategory.workFocus,
      label: 'Deep Work',
      value: '${weekFocusHours.toStringAsFixed(1)} hrs',
      subtitle: 'this week',
      trendLabel: '+12.5%',
      weekStartDate: weekStart,
    ));
    
    // Devotion Summary
    final prayers = _prayerController.getAll();
    int completedPrayers = 0;
    int totalPrayers = 0;
    
    for (var prayer in prayers) {
      if (prayer.date.isAfter(weekStart)) {
        totalPrayers++;
        if (prayer.isChecked) completedPrayers++;
      }
    }
    
    final devotionPercentage = totalPrayers > 0 
      ? (completedPrayers / totalPrayers * 100) 
      : 0.0;
    
    summaries.add(ActivitySummary(
      id: 'devotion_${weekStart.millisecondsSinceEpoch}',
      category: ActivityCategory.ibadah,
      label: 'Prayer',
      value: '${devotionPercentage.toStringAsFixed(0)}%',
      subtitle: 'completion rate',
      trendLabel: '+5.0%',
      weekStartDate: weekStart,
    ));
    
    // Kindness Summary
    final logs = _kindnessLogController.getAll();
    int actCount = 0;
    
    for (var log in logs) {
      if (log.date.isAfter(weekStart)) {
        actCount += log.selectedActIds.length;
      }
    }
    
    summaries.add(ActivitySummary(
      id: 'kindness_${weekStart.millisecondsSinceEpoch}',
      category: ActivityCategory.kindness,
      label: 'Kindness Acts',
      value: '$actCount acts',
      subtitle: 'this week',
      trendLabel: '+8.0%',
      weekStartDate: weekStart,
    ));
    
    return summaries;
  }
  
  /// Calculate daily consistency for current week
  Future<List<DailyConsistencyRecord>> calculateDailyConsistency() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final records = <DailyConsistencyRecord>[];
    
    // Generate records for each day of the week
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      
      // Get habits for this day
      final allHabits = _habitController.getAll();
      int completedCount = 0;
      
      for (var habit in allHabits) {
        if (habit.isCompleted && 
            habit.completedAt != null &&
            _isSameDay(habit.completedAt!, date)) {
          completedCount++;
        }
      }
      
      final ratio = allHabits.isNotEmpty 
        ? completedCount / allHabits.length 
        : 0.0;
      
      final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      
      records.add(DailyConsistencyRecord(
        id: '${date.millisecondsSinceEpoch}',
        date: date,
        dayLabel: dayLabels[i],
        ratio: ratio,
      ));
    }
    
    return records;
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Award a badge
  Future<void> awardBadge(Badge badge) async {
    await _badgeController.create(badge);
  }
  
  /// Get all badges
  List<Badge> getBadges() {
    return _badgeController.getAll();
  }
}
