import '../../../controllers/controllers.dart';
import '../../../models/models.dart';
import 'task_editor.dart';

class TaskManager {
  TaskManager({
    required TaskController taskController,
    required FocusSessionController focusSessionController,
  }) : _taskController = taskController,
       _focusSessionController = focusSessionController;

  final TaskController _taskController;
  final FocusSessionController _focusSessionController;

  Future<void> toggleTaskCompletion(Task task) async {
    if (task.isCompleted) {
      await _taskController.markIncomplete(task.id);
    } else {
      await _taskController.markCompleted(task.id);
    }
  }

  Future<Task> createTask(TaskDraft draft) async {
    final now = DateTime.now();
    return _taskController.create(
      Task(
        id: 'task_${now.microsecondsSinceEpoch}',
        title: draft.title,
        tags: draft.tags,
        priority: draft.priority,
        isCompleted: false,
        sortOrder: _taskController.getAll().length,
        createdAt: now,
      ),
    );
  }

  Future<Task> updateTask(Task task, TaskDraft draft) async {
    final updated = task.copyWith(
      title: draft.title,
      tags: draft.tags,
      priority: draft.priority,
    );
    await _taskController.update(task.id, updated);
    return updated;
  }

  Future<void> deleteTask(Task task) async => _taskController.delete(task.id);

  Future<FocusSession?> assignTaskToSession(
    Task newTask,
    FocusSession session,
    Task? currentTask,
  ) async {
    final updated = currentTask == null
        ? session.copyWith(currentTaskId: newTask.id)
        : session.copyWith(
            upNextTaskIds: [...session.upNextTaskIds, newTask.id],
          );
    await _focusSessionController.update(session.id, updated);
    return updated;
  }

  Task? getCurrentTask(FocusSession session) => session.currentTaskId == null
      ? null
      : _taskController.getById(session.currentTaskId!);

  List<Task> getUpNextTasks(FocusSession session) => session.upNextTaskIds
      .map(_taskController.getById)
      .whereType<Task>()
      .toList();
}
