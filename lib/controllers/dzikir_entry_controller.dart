import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';

class DzikirEntryController extends BaseController<DzikirEntry> {
  static final DzikirEntryController _instance = DzikirEntryController._internal();
  
  factory DzikirEntryController() {
    return _instance;
  }
  
  DzikirEntryController._internal();

  @override
  String get storageKey => 'dzikir_entries';

  @override
  Map<String, dynamic> toJson(DzikirEntry item) => item.toJson();

  @override
  DzikirEntry fromJson(Map<String, dynamic> json) => DzikirEntry.fromJson(json);

  @override
  DzikirEntry? getById(String id) {
    try {
      return items.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DzikirEntry> create(DzikirEntry entry) async {
    items.add(entry);
    await persist();
    return entry;
  }

  @override
  Future<DzikirEntry?> update(String id, DzikirEntry entry) async {
    final index = items.indexWhere((e) => e.id == id);
    if (index == -1) return null;
    
    items[index] = entry;
    await persist();
    return entry;
  }

  @override
  Future<DzikirEntry?> updateFields(String id, Map<String, dynamic> fields) async {
    final entry = getById(id);
    if (entry == null) return null;

    final updated = entry.copyWith(
      name: fields['name'] as String? ?? entry.name,
      current: fields['current'] as int? ?? entry.current,
      total: fields['total'] as int? ?? entry.total,
      date: fields['date'] as DateTime? ?? entry.date,
      completedAt: fields.containsKey('completedAt') ? fields['completedAt'] as DateTime? : entry.completedAt,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, DzikirEntry>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, DzikirEntry>{};
    
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
    items.removeWhere((entry) => entry.id == id);
    final deleted = items.length < initialLength;
    if (deleted) await persist();
    return deleted;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((entry) => ids.contains(entry.id));
    final deletedCount = initialLength - items.length;
    if (deletedCount > 0) await persist();
    return deletedCount;
  }

  /// Get entries by date
  List<DzikirEntry> getByDate(DateTime date) {
    return findWhere((entry) => 
      entry.date.year == date.year &&
      entry.date.month == date.month &&
      entry.date.day == date.day
    );
  }

  /// Get completed entries
  List<DzikirEntry> getCompleted() {
    return findWhere((entry) => entry.isCompleted);
  }

  /// Get incomplete entries
  List<DzikirEntry> getIncomplete() {
    return findWhere((entry) => !entry.isCompleted);
  }

  /// Get today's entries
  List<DzikirEntry> getTodayEntries() {
    return getByDate(DateTime.now());
  }

  /// Increment counter
  Future<DzikirEntry?> increment(String id, [int count = 1]) async {
    final entry = getById(id);
    if (entry == null) return null;

    final newCurrent = entry.current + count;
    final isCompleted = newCurrent >= entry.total;

    return updateFields(id, {
      'current': newCurrent,
      'completedAt': isCompleted ? DateTime.now() : entry.completedAt,
    });
  }

  /// Decrement counter
  Future<DzikirEntry?> decrement(String id, [int count = 1]) async {
    final entry = getById(id);
    if (entry == null) return null;

    final newCurrent = (entry.current - count).clamp(0, entry.total);

    return updateFields(id, {
      'current': newCurrent,
      'completedAt': newCurrent >= entry.total ? entry.completedAt : null,
    });
  }

  /// Reset counter
  Future<DzikirEntry?> reset(String id) async {
    return updateFields(id, {
      'current': 0,
      'completedAt': null,
    });
  }

  /// Mark as completed
  Future<DzikirEntry?> markCompleted(String id) async {
    final entry = getById(id);
    if (entry == null) return null;

    return updateFields(id, {
      'current': entry.total,
      'completedAt': DateTime.now(),
    });
  }
}
