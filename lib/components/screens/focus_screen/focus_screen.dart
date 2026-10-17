import 'dart:async';
import 'package:flutter/material.dart';

import '../../../controllers/controllers.dart';
import '../../../models/models.dart';
import '../../../utils/habit_auto_checker.dart';
import '../../../utils/notification_service.dart';

import 'session_manager.dart';
import 'task_manager.dart';
import 'focus_dialogs.dart';
import 'focus_data_loader.dart';
import 'focus_screen_body.dart';
import 'task_editor.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  late final SessionManager _sessionManager;
  late final TaskManager _taskManager;
  late final FocusDataLoader _dataLoader;
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
    _dataLoader = FocusDataLoader(
      sessionManager: _sessionManager,
      taskManager: _taskManager,
      habitController: _habitController,
      taskController: TaskController(),
    );
  }

  @override
  void dispose() {
    _sessionManager.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await _dataLoader.load();
    if (!mounted) return;
    setState(() {
      _currentSession = data.session;
      _currentTask = data.currentTask;
      _upNextTasks = data.upNextTasks;
      _completedTasks = data.completedTasks;
    });

    if (data.session.timerState == TimerState.focusing ||
        data.session.timerState == TimerState.onBreak) {
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
    if (!mounted) return;
    final settings = SettingController().getCurrentSetting();
    if (settings.notificationsEnabled) {
      await NotificationService.playCompletionSound();
      await NotificationService.show(
        'Break complete',
        'Your break timer has ended.',
      );
    }

    if (!mounted) return;
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
    if (!mounted) return;
    setState(() {
      _currentSession = updatedSession;
    });
    _startTimer();
  }

  Future<void> _toggleFocus() async {
    if (_currentSession == null) return;

    _sessionManager.stopTimer();
    final updatedSession = await _sessionManager.toggleFocus(_currentSession!);
    if (!mounted) return;

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
    if (!mounted) return;

    setState(() {
      _currentSession = updatedSession;
    });

    if (updatedSession.timerState == TimerState.onBreak) {
      _startTimer();
    }
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    final isCurrentTask = _currentTask?.id == task.id;
    final wasCompleted = task.isCompleted;

    await _taskManager.toggleTaskCompletion(task);
    if (!wasCompleted) {
      await HabitAutoChecker().onTaskComplete(task);
    }

    if (isCurrentTask && !wasCompleted && _currentSession != null) {
      if (_upNextTasks.isNotEmpty) {
        final newCurrentTaskId = _upNextTasks.first.id;
        final newUpNextIds = _currentSession!.upNextTaskIds
            .where((id) => id != newCurrentTaskId)
            .toList();

        final updatedSession = _currentSession!.copyWith(
          currentTaskId: newCurrentTaskId,
          upNextTaskIds: newUpNextIds,
        );

        await FocusSessionController().update(
          _currentSession!.id,
          updatedSession,
        );
      } else {
        final updatedSession = _currentSession!.copyWith(currentTaskId: null);
        await FocusSessionController().update(
          _currentSession!.id,
          updatedSession,
        );
      }
    }

    await _loadData();
  }

  Future<void> _editTask(Task task) async {
    final draft = await TaskEditor.show(context, task: task);
    if (draft != null) {
      await _taskManager.updateTask(task, draft);
      await _loadData();
    }
  }

  Future<void> _addTask() async {
    final draft = await TaskEditor.show(context);
    if (draft != null) {
      final newTask = await _taskManager.createTask(draft);

      if (_currentSession != null) {
        final updatedSession = await _taskManager.assignTaskToSession(
          newTask,
          _currentSession!,
          _currentTask,
        );

        if (updatedSession != null) {
          if (!mounted) return;
          setState(() {
            _currentSession = updatedSession;
          });
        }
      }

      await _loadData();
    }
  }

  Future<void> _reorderTasks(List<Task> tasks) async {
    final session = _currentSession;
    if (session == null) return;
    final orderedIds = tasks.map((task) => task.id).toList();
    await TaskController().reorderTasks(orderedIds);
    final updatedSession = session.copyWith(upNextTaskIds: orderedIds);
    await FocusSessionController().update(session.id, updatedSession);
    await _loadData();
  }

  Future<void> _deleteTask(Task task) async {
    await _taskManager.deleteTask(task);

    if (_currentSession != null &&
        _currentSession!.upNextTaskIds.contains(task.id)) {
      final updatedUpNext = _currentSession!.upNextTaskIds
          .where((id) => id != task.id)
          .toList();
      final updatedSession = _currentSession!.copyWith(
        upNextTaskIds: updatedUpNext,
      );
      await FocusSessionController().update(
        _currentSession!.id,
        updatedSession,
      );
    }

    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScreenBody(
      session: _currentSession,
      currentTask: _currentTask,
      upNextTasks: _upNextTasks,
      completedTasks: _completedTasks,
      onToggleFocus: _toggleFocus,
      onToggleBreak: _toggleBreak,
      onToggleTask: _toggleTaskCompletion,
      onEditTask: _editTask,
      onAddTask: _addTask,
      onDeleteTask: _deleteTask,
      onReorderTasks: _reorderTasks,
    );
  }
}
