import '../../../controllers/controllers.dart';
import '../../../models/models.dart';
import 'session_manager.dart';
import 'task_manager.dart';

class FocusScreenData {
  const FocusScreenData({
    required this.session,
    required this.currentTask,
    required this.upNextTasks,
    required this.completedTasks,
  });

  final FocusSession session;
  final Task? currentTask;
  final List<Task> upNextTasks;
  final List<Task> completedTasks;
}

class FocusDataLoader {
  FocusDataLoader({
    required SessionManager sessionManager,
    required TaskManager taskManager,
    required HabitController habitController,
    required TaskController taskController,
  }) : _sessionManager = sessionManager,
       _taskManager = taskManager,
       _habitController = habitController,
       _taskController = taskController;

  final SessionManager _sessionManager;
  final TaskManager _taskManager;
  final HabitController _habitController;
  final TaskController _taskController;

  Future<FocusScreenData> load() async {
    var session = await _sessionManager.getOrCreateSession();
    if (_habitController.getByCategory(HabitCategory.work).isEmpty) {
      await _habitController.create(
        Habit(
          id: 'habit_work_${DateTime.now().microsecondsSinceEpoch}',
          title: session.name,
          category: HabitCategory.work,
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      );
    }
    var currentTask = _taskManager.getCurrentTask(session);
    final upNextTasks = _taskManager.getUpNextTasks(session);
    final completedTasks = _taskController.getCompleted();
    if (currentTask == null) {
      final updated = await _sessionManager.assignCurrentTaskIfNeeded(session);
      if (updated != null) {
        session = updated;
        currentTask = _taskManager.getCurrentTask(session);
      }
    }
    return FocusScreenData(
      session: session,
      currentTask: currentTask,
      upNextTasks: upNextTasks,
      completedTasks: completedTasks,
    );
  }
}
