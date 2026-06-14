import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';

class QuranSessionController extends BaseController<QuranSession> {
  static final QuranSessionController _instance = QuranSessionController._internal();
  
  factory QuranSessionController() {
    return _instance;
  }
  
  QuranSessionController._internal();

  @override
  String get storageKey => 'quran_sessions';

  @override
  Map<String, dynamic> toJson(QuranSession item) => item.toJson();

  @override
  QuranSession fromJson(Map<String, dynamic> json) => QuranSession.fromJson(json);

  @override
  QuranSession? getById(String id) {
    try {
      return items.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<QuranSession> create(QuranSession session) async {
    items.add(session);
    await persist();
    return session;
  }

  @override
  Future<QuranSession?> update(String id, QuranSession session) async {
    final index = items.indexWhere((s) => s.id == id);
    if (index == -1) return null;
    
    items[index] = session;
    await persist();
    return session;
  }

  @override
  Future<QuranSession?> updateFields(String id, Map<String, dynamic> fields) async {
    final session = getById(id);
    if (session == null) return null;

    final updated = session.copyWith(
      currentSurah: fields['currentSurah'] as String? ?? session.currentSurah,
      currentSurahNumber: fields['currentSurahNumber'] as int? ?? session.currentSurahNumber,
      dailyPageGoal: fields['dailyPageGoal'] as int? ?? session.dailyPageGoal,
      pagesReadToday: fields['pagesReadToday'] as int? ?? session.pagesReadToday,
      instruction: fields['instruction'] as String? ?? session.instruction,
      isCompleted: fields['isCompleted'] as bool? ?? session.isCompleted,
      date: fields['date'] as DateTime? ?? session.date,
      completedAt: fields.containsKey('completedAt') ? fields['completedAt'] as DateTime? : session.completedAt,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, QuranSession>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, QuranSession>{};
    
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
    final deleted = items.length < initialLength;
    if (deleted) await persist();
    return deleted;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((session) => ids.contains(session.id));
    final deletedCount = initialLength - items.length;
    if (deletedCount > 0) await persist();
    return deletedCount;
  }

  /// Get sessions by date
  List<QuranSession> getByDate(DateTime date) {
    return findWhere((session) => 
      session.date.year == date.year &&
      session.date.month == date.month &&
      session.date.day == date.day
    );
  }

  /// Get completed sessions
  List<QuranSession> getCompleted() {
    return findWhere((session) => session.isCompleted);
  }

  /// Get incomplete sessions
  List<QuranSession> getIncomplete() {
    return findWhere((session) => !session.isCompleted);
  }

  /// Get today's session
  QuranSession? getTodaySession() {
    final today = getByDate(DateTime.now());
    return today.isNotEmpty ? today.first : null;
  }

  /// Increment pages read
  Future<QuranSession?> incrementPages(String id, int count) async {
    final session = getById(id);
    if (session == null) return null;

    final newPagesRead = session.pagesReadToday + count;
    final isCompleted = newPagesRead >= session.dailyPageGoal;

    return updateFields(id, {
      'pagesReadToday': newPagesRead,
      'isCompleted': isCompleted,
      'completedAt': isCompleted ? DateTime.now() : session.completedAt,
    });
  }

  /// Mark session as completed
  Future<QuranSession?> markCompleted(String id) async {
    return updateFields(id, {
      'isCompleted': true,
      'completedAt': DateTime.now(),
    });
  }

  /// Mark session as incomplete
  Future<QuranSession?> markIncomplete(String id) async {
    return updateFields(id, {
      'isCompleted': false,
      'completedAt': null,
    });
  }
}
