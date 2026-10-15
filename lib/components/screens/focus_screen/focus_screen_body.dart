import 'package:flutter/material.dart';

import '../../theme/habit_focus_theme.dart';
import '../../widgets/habit_focus_app_bar.dart';
import '../../widgets/focus/action_buttons.dart';
import '../../widgets/focus/completed_tasks_section.dart';
import '../../widgets/focus/current_task_card.dart';
import '../../widgets/focus/timer_section.dart';
import '../../widgets/focus/up_next_section.dart';
import '../../../models/models.dart';
import '../../../routes/route_shell.dart';

class FocusScreenBody extends StatelessWidget {
  const FocusScreenBody({
    super.key,
    required this.session,
    required this.currentTask,
    required this.upNextTasks,
    required this.completedTasks,
    required this.onToggleFocus,
    required this.onToggleBreak,
    required this.onToggleTask,
    required this.onEditTask,
    required this.onAddTask,
    required this.onDeleteTask,
    required this.onReorderTasks,
  });

  final FocusSession? session;
  final Task? currentTask;
  final List<Task> upNextTasks;
  final List<Task> completedTasks;
  final VoidCallback onToggleFocus;
  final VoidCallback onToggleBreak;
  final ValueChanged<Task> onToggleTask;
  final ValueChanged<Task> onEditTask;
  final VoidCallback onAddTask;
  final ValueChanged<Task> onDeleteTask;
  final ValueChanged<List<Task>> onReorderTasks;

  @override
  Widget build(BuildContext context) {
    final activeSession = session;
    if (activeSession == null) {
      return Scaffold(
        appBar: const HabitFocusAppBar(),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 1),
      );
    }
    return Scaffold(
      appBar: const HabitFocusAppBar(overrideTitle: 'Focus'),
      body: ListView(
        padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
        children: [
          TimerSection(session: activeSession),
          const SizedBox(height: 24),
          ActionButtons(
            session: activeSession,
            onToggleFocus: onToggleFocus,
            onToggleBreak: onToggleBreak,
          ),
          const SizedBox(height: HabitFocusTheme.sectionGap),
          if (currentTask != null)
            CurrentTaskCard(
              task: currentTask!,
              onToggle: () => onToggleTask(currentTask!),
              onEdit: () => onEditTask(currentTask!),
            ),
          const SizedBox(height: HabitFocusTheme.sectionGap),
          UpNextSection(
            tasks: upNextTasks,
            onToggle: onToggleTask,
            onEdit: onEditTask,
            onAddTask: onAddTask,
            onDelete: onDeleteTask,
            onReorder: onReorderTasks,
          ),
          if (completedTasks.isNotEmpty) ...[
            const SizedBox(height: HabitFocusTheme.sectionGap),
            CompletedTasksSection(
              tasks: completedTasks,
              onToggle: onToggleTask,
              onEdit: onEditTask,
              onDelete: onDeleteTask,
            ),
          ],
        ],
      ),
      bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 1),
    );
  }
}
