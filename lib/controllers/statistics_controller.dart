import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';

/// Controller for Badge model
class BadgeController extends BaseController<Badge> {
  static final BadgeController _instance = BadgeController._internal();
  
  factory BadgeController() {
    return _instance;
  }
  
  BadgeController._internal();

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
    return badge;
  }

  @override
  Future<Badge?> update(String id, Badge badge) async {
    final index = items.indexWhere((b) => b.id == id);
    if (index == -1) return null;
    
    items[index] = badge;
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
    return items.length < initialLength;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((badge) => ids.contains(badge.id));
    return initialLength - items.length;
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
    return score;
  }

  @override
  Future<GrowthScore?> update(String id, GrowthScore score) async {
    final index = items.indexWhere((s) => s.id == id);
    if (index == -1) return null;
    
    items[index] = score;
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
    return items.length < initialLength;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((score) => ids.contains(score.id));
    return initialLength - items.length;
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
    return summary;
  }

  @override
  Future<ActivitySummary?> update(String id, ActivitySummary summary) async {
    final index = items.indexWhere((s) => s.id == id);
    if (index == -1) return null;
    
    items[index] = summary;
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
    return items.length < initialLength;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((summary) => ids.contains(summary.id));
    return initialLength - items.length;
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
    return record;
  }

  @override
  Future<DailyConsistencyRecord?> update(String id, DailyConsistencyRecord record) async {
    final index = items.indexWhere((r) => r.id == id);
    if (index == -1) return null;
    
    items[index] = record;
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
    return items.length < initialLength;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((record) => ids.contains(record.id));
    return initialLength - items.length;
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
