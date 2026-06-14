import 'package:flutter/material.dart';

import '../../theme/habit_focus_theme.dart';
import 'task_item.dart';
import 'add_task_button.dart';
import '../../../models/models.dart';

class UpNextSection extends StatelessWidget {
  const UpNextSection({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onEdit,
    required this.onAddTask,
    required this.onDelete,
  });

  final List<Task> tasks;
  final Function(Task) onToggle;
  final Function(Task) onEdit;
  final VoidCallback onAddTask;
  final Function(Task) onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Waiting Tasks',
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: HabitFocusTheme.stackGap),
        if (tasks.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No tasks in queue',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ),
          )
        else
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
                isDisabled: true,
              ),
            );
          }).toList(),
        const SizedBox(height: 12),
        AddTaskButton(onTap: onAddTask),
      ],
    );
  }
}
