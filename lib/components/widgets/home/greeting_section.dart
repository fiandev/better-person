import 'package:flutter/material.dart';

import '../../theme/habit_focus_theme.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({
    super.key,
    required this.userName,
    required this.greeting,
  });

  final String userName;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $userName.',
          style: textTheme.headlineLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: HabitFocusTheme.spacingBase),
        Text(
          '"Small daily improvements over time lead to stunning results."',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.outline,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '- Robin Sharma',
          style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
        ),
      ],
    );
  }
}
