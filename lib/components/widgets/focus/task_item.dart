import 'package:material_ui/material_ui.dart';

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
    this.showDragHandle = false,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool isDisabled;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final priorityColor = switch (task.priority) {
      TaskPriority.high => colorScheme.error,
      TaskPriority.medium => colorScheme.secondary,
      TaskPriority.low => colorScheme.outline,
    };
    final taskWidget = InkWell(
      onTap: isDisabled ? null : onToggle,
      borderRadius: BorderRadius.circular(HabitFocusTheme.defaultRadius),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDisabled
                          ? colorScheme.onSurface.withValues(alpha: 0.7)
                          : colorScheme.onSurface,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (task.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: task.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    task.getPriorityLabel(),
                    style: textTheme.labelSmall?.copyWith(color: priorityColor),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit ${task.title}',
              icon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: colorScheme.outline,
              ),
              onPressed: onEdit,
            ),
            if (showDragHandle)
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
        confirmDismiss: (_) async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete task?'),
              content: Text('Delete “${task.title}”?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          return confirmed ?? false;
        },
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
