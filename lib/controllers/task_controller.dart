import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';

class TaskController extends BaseController<Task> {
  static final TaskController _instance = TaskController._internal();
  
  factory TaskController() {
    return _instance;
  }
  
  TaskController._internal();

  @override
  Task? getById(String id) {
    try {
      return items.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Task> create(Task task) async {
    items.add(task);
    return task;
  }

  @override
  Future<Task?> update(String id, Task task) async {
    final index = items.indexWhere((t) => t.id == id);
    if (index == -1) return null;
    
    items[index] = task;
    return task;
  }

  @override
  Future<Task?> updateFields(String id, Map<String, dynamic> fields) async {
    final task = getById(id);
    if (task == null) return null;

    final updated = task.copyWith(
      title: fields['title'] as String? ?? task.title,
      tags: fields['tags'] as List<String>? ?? task.tags,
      priority: fields['priority'] as TaskPriority? ?? task.priority,
      isCompleted: fields['isCompleted'] as bool? ?? task.isCompleted,
      sortOrder: fields['sortOrder'] as int? ?? task.sortOrder,
      completedAt: fields.containsKey('completedAt') ? fields['completedAt'] as DateTime? : task.completedAt,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, Task>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, Task>{};
    
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
    items.removeWhere((task) => task.id == id);
    return items.length < initialLength;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((task) => ids.contains(task.id));
    return initialLength - items.length;
  }

  /// Get tasks by priority
  List<Task> getByPriority(TaskPriority priority) {
    return findWhere((task) => task.priority == priority);
  }

  /// Get completed tasks
  List<Task> getCompleted() {
    return findWhere((task) => task.isCompleted);
  }

  /// Get incomplete tasks
  List<Task> getIncomplete() {
    return findWhere((task) => !task.isCompleted);
  }

  /// Get tasks sorted by sortOrder
  List<Task> getSorted() {
    final sorted = List<Task>.from(items);
    sorted.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted;
  }

  /// Mark task as completed
  Future<Task?> markCompleted(String id) async {
    return updateFields(id, {
      'isCompleted': true,
      'completedAt': DateTime.now(),
    });
  }

  /// Mark task as incomplete
  Future<Task?> markIncomplete(String id) async {
    return updateFields(id, {
      'isCompleted': false,
      'completedAt': null,
    });
  }

  /// Reorder tasks
  Future<void> reorderTasks(List<String> orderedIds) async {
    for (int i = 0; i < orderedIds.length; i++) {
      await updateFields(orderedIds[i], {'sortOrder': i});
    }
  }
}
