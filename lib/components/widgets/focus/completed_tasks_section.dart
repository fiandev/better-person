import 'package:flutter/material.dart';

import '../../theme/habit_focus_theme.dart';
import 'task_item.dart';
import '../../../models/models.dart';

class CompletedTasksSection extends StatelessWidget {
  const CompletedTasksSection({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Task> tasks;
  final Function(Task) onToggle;
  final Function(Task) onEdit;
  final Function(Task) onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completed Tasks',
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: HabitFocusTheme.stackGap),
        ...tasks.asMap().entries.map((entry) {
          final index = entry.key;
          final task = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < tasks.length - 1 ? 8 : 0,
            ),
            child: TaskItem(
              task: task,
              onToggle: () => onToggle(task),
              onEdit: () => onEdit(task),
              onDelete: () => onDelete(task),
              isDisabled: false,
            ),
          );
        }),
      ],
    );
  }
}
