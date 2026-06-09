import 'package:flutter/material.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.title,
    this.subtitle,
    this.categoryLabel,
    this.categoryColor,
    this.duration,
    this.isCompleted = false,
    this.onToggle,
  });

  final String title;
  final String? subtitle;
  final String? categoryLabel;
  final Color? categoryColor;
  final String? duration;
  final bool isCompleted;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final borderColor = categoryColor ?? colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 40,
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? colorScheme.primary : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? colorScheme.primary
                      : colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: colorScheme.onPrimary,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? colorScheme.outline
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (categoryLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: (categoryColor ?? colorScheme.primary)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          categoryLabel!,
                          style: textTheme.labelSmall?.copyWith(
                            color: categoryColor ?? colorScheme.primary,
                          ),
                        ),
                      ),
                    if (categoryLabel != null && duration != null)
                      const SizedBox(width: 8),
                    if (duration != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duration!,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
