import 'package:flutter/material.dart';

import '../../theme/habit_focus_theme.dart';
import '../../../models/models.dart';

class TaskItem extends StatelessWidget {
  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    this.onDelete,
    this.isDisabled = false,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final taskWidget = GestureDetector(
      onTap: isDisabled ? null : onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(HabitFocusTheme.defaultRadius),
          boxShadow: [HabitFocusTheme.ambientShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted ? colorScheme.secondary : null,
                border: Border.all(
                  color: isDisabled
                      ? colorScheme.outline.withValues(alpha: 0.3)
                      : (task.isCompleted
                          ? colorScheme.secondary
                          : colorScheme.outline),
                  width: 1.5,
                ),
              ),
              child: task.isCompleted
                  ? Icon(Icons.check, size: 12, color: colorScheme.onSecondary)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: textTheme.bodyMedium?.copyWith(
                  color: isDisabled 
                      ? colorScheme.onSurface.withValues(alpha: 0.4)
                      : colorScheme.onSurface,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: colorScheme.outline,
              ),
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
            const SizedBox(width: 8),
            Icon(Icons.drag_indicator, size: 20, color: colorScheme.outline),
          ],
        ),
      ),
    );

    // Wrap with Dismissible for swipe-to-delete if onDelete is provided
    if (onDelete != null) {
      return Dismissible(
        key: Key(task.id),
        direction: DismissDirection.horizontal,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(HabitFocusTheme.defaultRadius),
          ),
          child: Icon(Icons.delete, color: colorScheme.onError),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(HabitFocusTheme.defaultRadius),
          ),
          child: Icon(Icons.delete, color: colorScheme.onError),
        ),
        onDismissed: (_) => onDelete!(),
        child: taskWidget,
      );
    }

    return taskWidget;
  }
}
