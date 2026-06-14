import 'package:flutter/material.dart';

import '../../theme/habit_focus_theme.dart';
import '../habit_card.dart';
import '../../../models/models.dart';

class KeyHabitsSection extends StatelessWidget {
  const KeyHabitsSection({
    super.key,
    required this.habits,
  });

  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Key Habits',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all habits screen
              },
              child: Text(
                'View All',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: HabitFocusTheme.stackGap),
        if (habits.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No habits yet. Start building your routine!',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...habits.asMap().entries.map((entry) {
            final index = entry.key;
            final habit = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < habits.length - 1 ? 12 : 0,
              ),
              child: HabitCard(
                title: habit.title,
                categoryLabel: habit.getCategoryLabel(),
                categoryColor: habit.getCategoryColor(colorScheme),
                duration: habit.duration ?? '',
                isCompleted: habit.isCompleted,
              ),
            );
          }).toList(),
      ],
    );
  }
}
