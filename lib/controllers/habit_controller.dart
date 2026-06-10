import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';

class HabitController extends BaseController<Habit> {
  static final HabitController _instance = HabitController._internal();
  
  factory HabitController() {
    return _instance;
  }
  
  HabitController._internal();

  @override
  Habit? getById(String id) {
    try {
      return _items.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Habit> create(Habit habit) async {
    _items.add(habit);
    return habit;
  }

  @override
  Future<Habit?> update(String id, Habit habit) async {
    final index = _items.indexWhere((h) => h.id == id);
    if (index == -1) return null;
    
    _items[index] = habit;
    return habit;
  }

  @override
  Future<Habit?> updateFields(String id, Map<String, dynamic> fields) async {
    final habit = getById(id);
    if (habit == null) return null;

    final updated = habit.copyWith(
      title: fields['title'] as String? ?? habit.title,
      subtitle: fields.containsKey('subtitle') ? fields['subtitle'] as String? : habit.subtitle,
      category: fields['category'] as HabitCategory? ?? habit.category,
      duration: fields.containsKey('duration') ? fields['duration'] as String? : habit.duration,
      isCompleted: fields['isCompleted'] as bool? ?? habit.isCompleted,
      completedAt: fields.containsKey('completedAt') ? fields['completedAt'] as DateTime? : habit.completedAt,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, Habit>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, Habit>{};
    
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
    final initialLength = _items.length;
    _items.removeWhere((habit) => habit.id == id);
    return _items.length < initialLength;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = _items.length;
    _items.removeWhere((habit) => ids.contains(habit.id));
    return initialLength - _items.length;
  }

  /// Get habits by category
  List<Habit> getByCategory(HabitCategory category) {
    return findWhere((habit) => habit.category == category);
  }

  /// Get completed habits
  List<Habit> getCompleted() {
    return findWhere((habit) => habit.isCompleted);
  }

  /// Get incomplete habits
  List<Habit> getIncomplete() {
    return findWhere((habit) => !habit.isCompleted);
  }

  /// Mark habit as completed
  Future<Habit?> markCompleted(String id) async {
    return updateFields(id, {
      'isCompleted': true,
      'completedAt': DateTime.now(),
    });
  }

  /// Mark habit as incomplete
  Future<Habit?> markIncomplete(String id) async {
    return updateFields(id, {
      'isCompleted': false,
      'completedAt': null,
    });
  }
}
