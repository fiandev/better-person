import 'dart:async';
import 'package:flutter/material.dart';

import '../../../controllers/controllers.dart';
import '../../../models/models.dart';
import '../../../utils/habit_auto_checker.dart';

/// Manages focus session lifecycle, timer, and state transitions
class SessionManager {
  final FocusSessionController _focusSessionController;
  final TaskController _taskController;
  final HabitController _habitController;
  final HabitAutoChecker _habitAutoChecker;
  
  Timer? _timer;
  
  SessionManager({
    required FocusSessionController focusSessionController,
    required TaskController taskController,
    required HabitController habitController,
    required HabitAutoChecker habitAutoChecker,
  })  : _focusSessionController = focusSessionController,
        _taskController = taskController,
        _habitController = habitController,
        _habitAutoChecker = habitAutoChecker;

  void dispose() {
    _timer?.cancel();
  }

  /// Get or create an active focus session
  Future<FocusSession> getOrCreateSession() async {
    final activeSessions = _focusSessionController.getActiveSessions();
    
    if (activeSessions.isEmpty) {
      return await _createDefaultSession();
    }
    
    return activeSessions.first;
  }

  Future<FocusSession> _createDefaultSession() async {
    final now = DateTime.now();

    // Create default tasks if none exist
    if (_taskController.getAll().isEmpty) {
      // Intentionally empty - users should add tasks themselves
    }

    final allTasks = _taskController.getIncomplete();
    final firstTask = allTasks.isNotEmpty ? allTasks.first : null;
    final upNextTaskIds = allTasks.skip(1).take(2).map((t) => t.id).toList();

    // Check if there is an active work habit, or create one
    final workHabits = _habitController.getByCategory(HabitCategory.work);
    String categoryName = 'Work Focus';
    String sessionName = 'Deep Work Session';

    if (workHabits.isNotEmpty) {
      categoryName = workHabits.first.getCategoryLabel();
      sessionName = workHabits.first.title;
    } else {
      await _habitController.create(
        Habit(
          id: 'habit_work_${now.millisecondsSinceEpoch}',
          title: sessionName,
          category: HabitCategory.work,
          isCompleted: false,
          createdAt: now,
        ),
      );
    }

    final session = FocusSession(
      id: 'session_${now.millisecondsSinceEpoch}',
      category: categoryName,
      name: sessionName,
      timerDuration: const Duration(minutes: 25),
      elapsed: Duration.zero,
      timerState: TimerState.idle,
      currentTaskId: firstTask?.id,
      upNextTaskIds: upNextTaskIds,
      createdAt: now,
    );

    return await _focusSessionController.create(session);
  }

  /// Start the session timer
  void startTimer(
    FocusSession session,
    void Function(FocusSession) onUpdate,
    void Function() onBreakComplete,
    void Function() onSessionComplete,
  ) {
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newElapsed = session.elapsed + const Duration(seconds: 1);

      // Check if timer completed
      if (newElapsed >= session.timerDuration) {
        if (session.timerState == TimerState.onBreak) {
          onBreakComplete();
        } else {
          onSessionComplete();
        }
        return;
      }

      // Update elapsed time
      _focusSessionController.updateElapsed(session.id, newElapsed);
      
      final updatedSession = session.copyWith(elapsed: newElapsed);
      onUpdate(updatedSession);
    });
  }

  /// Stop the current timer
  void stopTimer() {
    _timer?.cancel();
  }

  /// Toggle focus state (start/pause)
  Future<FocusSession> toggleFocus(FocusSession session) async {
    if (session.timerState == TimerState.focusing) {
      // Pause
      await _focusSessionController.pause(session.id);
      return session.copyWith(timerState: TimerState.idle);
    } else if (session.timerState == TimerState.onBreak) {
      // Switching from break to focus - reset to 25 min
      return await resetToFocusMode(session);
    } else {
      // Start focusing from idle
      if (session.timerDuration.inMinutes == 5) {
        // It was a paused break, reset to focus mode
        return await resetToFocusMode(session);
      } else {
        // It was a paused focus, resume
        await _focusSessionController.startFocus(session.id);
        return session.copyWith(timerState: TimerState.focusing);
      }
    }
  }

  /// Toggle break state (start/pause)
  Future<FocusSession> toggleBreak(FocusSession session) async {
    if (session.timerState == TimerState.onBreak) {
      // Pause break
      await _focusSessionController.pause(session.id);
      return session.copyWith(timerState: TimerState.idle);
    } else {
      // Start break - reset to 5 min or resume if paused
      if (session.timerState == TimerState.idle &&
          session.timerDuration.inMinutes == 5) {
        // Resume break
        await _focusSessionController.startBreak(session.id);
        return session.copyWith(timerState: TimerState.onBreak);
      } else {
        return await startBreak(session);
      }
    }
  }

  /// Start a break session
  Future<FocusSession> startBreak(FocusSession session) async {
    final updatedSession = session.copyWith(
      timerDuration: const Duration(minutes: 5),
      elapsed: Duration.zero,
      timerState: TimerState.onBreak,
    );

    await _focusSessionController.update(session.id, updatedSession);
    return updatedSession;
  }

  /// Complete the current break
  Future<FocusSession> completeBreak(FocusSession session) async {
    final updatedSession = session.copyWith(
      timerState: TimerState.idle,
      elapsed: Duration.zero,
    );
    
    await _focusSessionController.update(session.id, updatedSession);
    return updatedSession;
  }

  /// Reset to focus mode (25 minutes)
  Future<FocusSession> resetToFocusMode(FocusSession session) async {
    final updatedSession = session.copyWith(
      timerDuration: const Duration(minutes: 25),
      elapsed: Duration.zero,
      timerState: TimerState.focusing,
    );

    await _focusSessionController.update(session.id, updatedSession);
    return updatedSession;
  }

  /// Complete the current focus session
  Future<void> completeSession(
    FocusSession session,
    Task? currentTask,
  ) async {
    await _focusSessionController.completeSession(session.id);

    // Mark current task as completed if exists
    if (currentTask != null) {
      await _taskController.markCompleted(currentTask.id);
      await _habitAutoChecker.onTaskComplete(currentTask);
    }

    // Auto-check habit for completing focus session
    await _habitAutoChecker.onFocusSessionComplete(session);

    // Update user statistics
    await _habitAutoChecker.updateUserStats();
  }

  /// Assign a current task to the session if none exists
  Future<FocusSession?> assignCurrentTaskIfNeeded(
    FocusSession session,
  ) async {
    if (session.currentTaskId != null) {
      return null; // Already has a task
    }

    final incompleteTasks = _taskController.getIncomplete();
    if (incompleteTasks.isEmpty) {
      return null;
    }

    final currentTask = incompleteTasks.first;
    final updatedSession = session.copyWith(currentTaskId: currentTask.id);
    await _focusSessionController.update(session.id, updatedSession);
    
    return updatedSession;
  }
}
