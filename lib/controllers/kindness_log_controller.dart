import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';

class KindnessLogController extends BaseController<KindnessLog> {
  static final KindnessLogController _instance = KindnessLogController._internal();
  
  factory KindnessLogController() {
    return _instance;
  }
  
  KindnessLogController._internal();

  @override
  KindnessLog? getById(String id) {
    try {
      return items.firstWhere((log) => log.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<KindnessLog> create(KindnessLog log) async {
    items.add(log);
    return log;
  }

  @override
  Future<KindnessLog?> update(String id, KindnessLog log) async {
    final index = items.indexWhere((l) => l.id == id);
    if (index == -1) return null;
    
    items[index] = log;
    return log;
  }

  @override
  Future<KindnessLog?> updateFields(String id, Map<String, dynamic> fields) async {
    final log = getById(id);
    if (log == null) return null;

    final updated = log.copyWith(
      date: fields['date'] as DateTime? ?? log.date,
      selectedActIds: fields['selectedActIds'] as List<String>? ?? log.selectedActIds,
      reflectionText: fields['reflectionText'] as String? ?? log.reflectionText,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, KindnessLog>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, KindnessLog>{};
    
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
    items.removeWhere((log) => log.id == id);
    return items.length < initialLength;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((log) => ids.contains(log.id));
    return initialLength - items.length;
  }

  /// Get logs by date
  List<KindnessLog> getByDate(DateTime date) {
    return findWhere((log) => 
      log.date.year == date.year &&
      log.date.month == date.month &&
      log.date.day == date.day
    );
  }

  /// Get today's log
  KindnessLog? getTodayLog() {
    final today = getByDate(DateTime.now());
    return today.isNotEmpty ? today.first : null;
  }

  /// Get logs in date range
  List<KindnessLog> getByDateRange(DateTime start, DateTime end) {
    return findWhere((log) => 
      log.date.isAfter(start.subtract(const Duration(days: 1))) &&
      log.date.isBefore(end.add(const Duration(days: 1)))
    );
  }

  /// Get logs for current week
  List<KindnessLog> getThisWeekLogs() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return getByDateRange(weekStart, weekEnd);
  }

  /// Add an act to a log
  Future<KindnessLog?> addAct(String id, String actId) async {
    final log = getById(id);
    if (log == null) return null;

    if (log.selectedActIds.contains(actId)) {
      return log; // Already added
    }

    final updatedActIds = [...log.selectedActIds, actId];
    return updateFields(id, {'selectedActIds': updatedActIds});
  }

  /// Remove an act from a log
  Future<KindnessLog?> removeAct(String id, String actId) async {
    final log = getById(id);
    if (log == null) return null;

    final updatedActIds = log.selectedActIds.where((id) => id != actId).toList();
    return updateFields(id, {'selectedActIds': updatedActIds});
  }
}
