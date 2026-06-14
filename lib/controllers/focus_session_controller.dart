import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';

class FocusSessionController extends BaseController<FocusSession> {
  static final FocusSessionController _instance = FocusSessionController._internal();
  
  factory FocusSessionController() {
    return _instance;
  }
  
  FocusSessionController._internal();

  @override
  FocusSession? getById(String id) {
    try {
      return items.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<FocusSession> create(FocusSession session) async {
    items.add(session);
    return session;
  }

  @override
  Future<FocusSession?> update(String id, FocusSession session) async {
    final index = items.indexWhere((s) => s.id == id);
    if (index == -1) return null;
    
    items[index] = session;
    return session;
  }

  @override
  Future<FocusSession?> updateFields(String id, Map<String, dynamic> fields) async {
    final session = getById(id);
    if (session == null) return null;

    final updated = session.copyWith(
      category: fields['category'] as String? ?? session.category,
      name: fields['name'] as String? ?? session.name,
      timerDuration: fields['timerDuration'] as Duration? ?? session.timerDuration,
      elapsed: fields['elapsed'] as Duration? ?? session.elapsed,
      timerState: fields['timerState'] as TimerState? ?? session.timerState,
      currentTaskId: fields.containsKey('currentTaskId') ? fields['currentTaskId'] as String? : session.currentTaskId,
      upNextTaskIds: fields['upNextTaskIds'] as List<String>? ?? session.upNextTaskIds,
      completedAt: fields.containsKey('completedAt') ? fields['completedAt'] as DateTime? : session.completedAt,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, FocusSession>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, FocusSession>{};
    
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
    items.removeWhere((session) => session.id == id);
    return items.length < initialLength;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((session) => ids.contains(session.id));
    return initialLength - items.length;
  }

  /// Get sessions by category
  List<FocusSession> getByCategory(String category) {
    return findWhere((session) => session.category == category);
  }

  /// Get sessions by timer state
  List<FocusSession> getByTimerState(TimerState state) {
    return findWhere((session) => session.timerState == state);
  }

  /// Get active (focusing or on break) sessions
  List<FocusSession> getActiveSessions() {
    return findWhere((session) => 
      session.timerState == TimerState.focusing || 
      session.timerState == TimerState.onBreak
    );
  }

  /// Get completed sessions
  List<FocusSession> getCompleted() {
    return findWhere((session) => session.completedAt != null);
  }

  /// Start focus session
  Future<FocusSession?> startFocus(String id) async {
    return updateFields(id, {
      'timerState': TimerState.focusing,
    });
  }

  /// Start break
  Future<FocusSession?> startBreak(String id) async {
    return updateFields(id, {
      'timerState': TimerState.onBreak,
    });
  }

  /// Pause session (set to idle)
  Future<FocusSession?> pause(String id) async {
    return updateFields(id, {
      'timerState': TimerState.idle,
    });
  }

  /// Update elapsed time
  Future<FocusSession?> updateElapsed(String id, Duration elapsed) async {
    return updateFields(id, {
      'elapsed': elapsed,
    });
  }

  /// Complete session
  Future<FocusSession?> completeSession(String id) async {
    return updateFields(id, {
      'timerState': TimerState.idle,
      'completedAt': DateTime.now(),
    });
  }
}
