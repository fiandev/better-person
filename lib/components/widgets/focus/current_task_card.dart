import 'package:flutter/material.dart';

import '../../theme/habit_focus_theme.dart';
import '../../../models/models.dart';

class CurrentTaskCard extends StatelessWidget {
  const CurrentTaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        border: Border(
          left: BorderSide(color: colorScheme.secondary, width: 4),
        ),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Task',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.outline,
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
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onToggle,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted ? colorScheme.secondary : null,
                    border: Border.all(
                      color: task.isCompleted
                          ? colorScheme.secondary
                          : colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: colorScheme.onSecondary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: task.tags.map((tag) {
              final isHighPriority = tag.toLowerCase().contains('high');
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isHighPriority
                      ? colorScheme.error.withValues(alpha: 0.1)
                      : colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: textTheme.labelSmall?.copyWith(
                    color: isHighPriority
                        ? colorScheme.error
                        : colorScheme.secondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
