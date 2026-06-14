import 'package:flutter/material.dart';

import '../../../controllers/controllers.dart';
import '../../../models/models.dart';

/// Manages task operations: creation, editing, completion, and session assignment
class TaskManager {
  final TaskController _taskController;
  final FocusSessionController _focusSessionController;

  TaskManager({
    required TaskController taskController,
    required FocusSessionController focusSessionController,
  })  : _taskController = taskController,
        _focusSessionController = focusSessionController;

  /// Toggle task completion status
  Future<void> toggleTaskCompletion(Task task) async {
    if (task.isCompleted) {
      await _taskController.markIncomplete(task.id);
    } else {
      await _taskController.markCompleted(task.id);
    }
  }

  /// Create a new task
  Future<Task> createTask(String title) async {
    final now = DateTime.now();
    final newTask = Task(
      id: 'task_${now.millisecondsSinceEpoch}',
      title: title,
      tags: ['Deep Work'],
      priority: TaskPriority.medium,
      isCompleted: false,
      sortOrder: _taskController.getAll().length,
      createdAt: now,
    );

    return await _taskController.create(newTask);
  }

  /// Update an existing task
  Future<Task> updateTask(Task task, String newTitle) async {
    final updatedTask = task.copyWith(title: newTitle);
    await _taskController.update(task.id, updatedTask);
    return updatedTask;
  }

  /// Delete a task
  Future<void> deleteTask(Task task) async {
    await _taskController.delete(task.id);
  }

  /// Assign newly created task to session if needed
  Future<FocusSession?> assignTaskToSession(
    Task newTask,
    FocusSession session,
    Task? currentTask,
    List<Task> upNextTasks,
  ) async {
    // If there's no current task, set it to this newly added task
    if (currentTask == null) {
      final updatedSession = session.copyWith(currentTaskId: newTask.id);
      await _focusSessionController.update(session.id, updatedSession);
      return updatedSession;
    } else if (upNextTasks.isEmpty) {
      // If current exists but up next is empty, put it in up next
      final newUpNext = [...session.upNextTaskIds, newTask.id];
      final updatedSession = session.copyWith(upNextTaskIds: newUpNext);
      await _focusSessionController.update(session.id, updatedSession);
      return updatedSession;
    }

    return null;
  }

  /// Load current task from session
  Task? getCurrentTask(FocusSession session) {
    if (session.currentTaskId == null) return null;
    return _taskController.getById(session.currentTaskId!);
  }

  /// Load up next tasks from session
  List<Task> getUpNextTasks(FocusSession session) {
    return session.upNextTaskIds
        .map((id) => _taskController.getById(id))
        .where((task) => task != null)
        .cast<Task>()
        .toList();
  }

  /// Show task edit bottom sheet
  Future<String?> showEditTaskDialog(
    BuildContext context,
    Task task,
  ) async {
    final controller = TextEditingController(text: task.title);

    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Edit Task',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Enter task title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(controller.text),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show add task bottom sheet
  Future<String?> showAddTaskDialog(BuildContext context) async {
    final controller = TextEditingController();

    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Add Task', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Enter task title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(controller.text),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
