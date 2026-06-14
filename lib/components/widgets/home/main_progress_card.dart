import 'package:flutter/material.dart';

import '../../theme/habit_focus_theme.dart';
import '../progress_ring.dart';

class MainProgressCard extends StatelessWidget {
  const MainProgressCard({
    super.key,
    required this.progress,
    required this.streak,
  });

  final double progress;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Focus",
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$percentage% Completed',
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak-day streak',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ProgressRing(
            progress: progress,
            color: colorScheme.primary,
            size: 80,
            strokeWidth: 8,
          ),
        ],
      ),
    );
  }
}
