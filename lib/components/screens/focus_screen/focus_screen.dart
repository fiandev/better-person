import 'dart:async';
import 'package:flutter/material.dart';

import '../../theme/habit_focus_theme.dart';
import '../../widgets/habit_focus_app_bar.dart';
import '../../widgets/focus/timer_section.dart';
import '../../widgets/focus/action_buttons.dart';
import '../../widgets/focus/current_task_card.dart';
import '../../widgets/focus/up_next_section.dart';
import '../../widgets/focus/completed_tasks_section.dart';
import '../../../routes/route_shell.dart';
import '../../../controllers/controllers.dart';
import '../../../models/models.dart';
import '../../../utils/habit_auto_checker.dart';

import 'session_manager.dart';
import 'task_manager.dart';
import 'focus_dialogs.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  late final SessionManager _sessionManager;
  late final TaskManager _taskManager;
  final _habitController = HabitController();

  FocusSession? _currentSession;
  Task? _currentTask;
  List<Task> _upNextTasks = [];
  List<Task> _completedTasks = [];

  @override
  void initState() {
    super.initState();
    _initializeManagers();
    _loadData();
  }

  void _initializeManagers() {
    _sessionManager = SessionManager(
      focusSessionController: FocusSessionController(),
      taskController: TaskController(),
      habitController: _habitController,
      habitAutoChecker: HabitAutoChecker(),
    );

    _taskManager = TaskManager(
      taskController: TaskController(),
      focusSessionController: FocusSessionController(),
    );
  }

  @override
  void dispose() {
    _sessionManager.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Get or create active focus session
    FocusSession session = await _sessionManager.getOrCreateSession();

    // Ensure we have a related Work habit
    final workHabits = _habitController.getByCategory(HabitCategory.work);
    if (workHabits.isEmpty) {
      await _habitController.create(
        Habit(
          id: 'habit_work_default',
          title: session.name,
          category: HabitCategory.work,
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      );
    }

    // Get current task and up next tasks
    Task? currentTask = _taskManager.getCurrentTask(session);
    List<Task> upNextTasks = _taskManager.getUpNextTasks(session);
    List<Task> completedTasks = TaskController().getCompleted();

    // If no current task in session, try to assign one
    if (currentTask == null) {
      final updatedSession = await _sessionManager.assignCurrentTaskIfNeeded(
        session,
      );
      if (updatedSession != null) {
        session = updatedSession;
        currentTask = _taskManager.getCurrentTask(session);
      }
    }

    setState(() {
      _currentSession = session;
      _currentTask = currentTask;
      _upNextTasks = upNextTasks;
      _completedTasks = completedTasks;
    });

    // Start timer if focusing or on break
    if (session.timerState == TimerState.focusing ||
        session.timerState == TimerState.onBreak) {
      _startTimer();
    }
  }

  void _startTimer() {
    if (_currentSession == null) return;

    _sessionManager.startTimer(
      _currentSession!,
      (updatedSession) {
        setState(() {
          _currentSession = updatedSession;
        });
      },
      _onBreakComplete,
      _onSessionComplete,
    );
  }

  void _onBreakComplete() async {
    if (_currentSession == null) return;

    _sessionManager.stopTimer();
    final updatedSession = await _sessionManager.completeBreak(
      _currentSession!,
    );

    setState(() {
      _currentSession = updatedSession;
    });

    if (mounted) {
      FocusDialogs.showBreakCompleteDialog(context, () {
        _resetToFocusAndStart();
      });
    }
  }

  void _onSessionComplete() async {
    if (_currentSession == null) return;

    _sessionManager.stopTimer();
    await _sessionManager.completeSession(_currentSession!, _currentTask);

    if (mounted) {
      FocusDialogs.showSessionCompleteDialog(context, _loadData);
    }
  }

  Future<void> _resetToFocusAndStart() async {
    if (_currentSession == null) return;

    final updatedSession = await _sessionManager.resetToFocusMode(
      _currentSession!,
    );
    setState(() {
      _currentSession = updatedSession;
    });
    _startTimer();
  }

  Future<void> _toggleFocus() async {
    if (_currentSession == null) return;

    _sessionManager.stopTimer();
    final updatedSession = await _sessionManager.toggleFocus(_currentSession!);

    setState(() {
      _currentSession = updatedSession;
    });

    if (updatedSession.timerState == TimerState.focusing) {
      _startTimer();
    }
  }

  Future<void> _toggleBreak() async {
    if (_currentSession == null) return;

    _sessionManager.stopTimer();
    final updatedSession = await _sessionManager.toggleBreak(_currentSession!);

    setState(() {
      _currentSession = updatedSession;
    });

    if (updatedSession.timerState == TimerState.onBreak) {
      _startTimer();
    }
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    // Check if this is the current task being completed
    final isCurrentTask = _currentTask?.id == task.id;
    final wasCompleted = task.isCompleted;
    
    await _taskManager.toggleTaskCompletion(task);
    
    // If completing the current task, promote the top waiting task
    if (isCurrentTask && !wasCompleted && _currentSession != null) {
      if (_upNextTasks.isNotEmpty) {
        // Promote first waiting task to current
        final newCurrentTaskId = _upNextTasks.first.id;
        final newUpNextIds = _currentSession!.upNextTaskIds
            .where((id) => id != newCurrentTaskId)
            .toList();
        
        final updatedSession = _currentSession!.copyWith(
          currentTaskId: newCurrentTaskId,
          upNextTaskIds: newUpNextIds,
        );
        
        await FocusSessionController().update(_currentSession!.id, updatedSession);
      } else {
        // No waiting tasks, clear current task
        final updatedSession = _currentSession!.copyWith(currentTaskId: null);
        await FocusSessionController().update(_currentSession!.id, updatedSession);
      }
    }
    
    await _loadData();
  }

  Future<void> _editTask(Task task) async {
    final result = await _taskManager.showEditTaskDialog(context, task);

    if (result != null && result.isNotEmpty && result != task.title) {
      await _taskManager.updateTask(task, result);
      await _loadData();
    }
  }

  Future<void> _addTask() async {
    final result = await _taskManager.showAddTaskDialog(context);

    if (result != null && result.isNotEmpty) {
      final newTask = await _taskManager.createTask(result);

      // Assign task to session if needed
      if (_currentSession != null) {
        final updatedSession = await _taskManager.assignTaskToSession(
          newTask,
          _currentSession!,
          _currentTask,
          _upNextTasks,
        );

        if (updatedSession != null) {
          setState(() {
            _currentSession = updatedSession;
          });
        }
      }

      await _loadData();
    }
  }

  Future<void> _deleteTask(Task task) async {
    await _taskManager.deleteTask(task);
    
    // If the deleted task was in the session's upNextTaskIds, update the session
    if (_currentSession != null && _currentSession!.upNextTaskIds.contains(task.id)) {
      final updatedUpNext = _currentSession!.upNextTaskIds.where((id) => id != task.id).toList();
      final updatedSession = _currentSession!.copyWith(upNextTaskIds: updatedUpNext);
      await FocusSessionController().update(_currentSession!.id, updatedSession);
    }
    
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentSession == null) {
      return Scaffold(
        appBar: const HabitFocusAppBar(),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 1),
      );
    }

    return Scaffold(
      appBar: const HabitFocusAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
        children: [
          TimerSection(session: _currentSession!),
          const SizedBox(height: 24),
          ActionButtons(
            session: _currentSession!,
            onToggleFocus: _toggleFocus,
            onToggleBreak: _toggleBreak,
          ),
          const SizedBox(height: HabitFocusTheme.sectionGap),
          if (_currentTask != null)
            CurrentTaskCard(
              task: _currentTask!,
              onToggle: () => _toggleTaskCompletion(_currentTask!),
              onEdit: () => _editTask(_currentTask!),
            ),
          const SizedBox(height: HabitFocusTheme.sectionGap),
          UpNextSection(
            tasks: _upNextTasks,
            onToggle: _toggleTaskCompletion,
            onEdit: _editTask,
            onAddTask: _addTask,
            onDelete: _deleteTask,
          ),
          if (_completedTasks.isNotEmpty) ...[
            const SizedBox(height: HabitFocusTheme.sectionGap),
            CompletedTasksSection(
              tasks: _completedTasks,
              onToggle: _toggleTaskCompletion,
              onEdit: _editTask,
              onDelete: _deleteTask,
            ),
          ],
        ],
      ),
      bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 1),
    );
  }
}
