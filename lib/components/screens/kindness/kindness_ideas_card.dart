import 'package:flutter/material.dart';

import '../../../controllers/kindness_act_controller.dart';
import '../../../models/kindness_act.dart';
import '../../theme/habit_focus_theme.dart';

class KindnessIdeasCard extends StatelessWidget {
  const KindnessIdeasCard({
    super.key,
    required this.colorScheme,
    required this.kindnessActController,
    required this.onToggleChip,
  });

  final ColorScheme colorScheme;
  final KindnessActController kindnessActController;
  final ValueChanged<String> onToggleChip;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final acts = kindnessActController.getSorted();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        border: Border(left: BorderSide(color: colorScheme.tertiary, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: colorScheme.tertiary),
              const SizedBox(width: 8),
              Text('Quick Ideas', style: textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text('Select the acts of kindness you performed today.'),
          const SizedBox(height: 24),
          if (acts.isEmpty)
            const Text('No kindness ideas are available yet.')
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: acts.map((KindnessAct act) => FilterChip(
                label: Text(act.label),
                selected: act.isSelected,
                onSelected: (_) => onToggleChip(act.id),
                selectedColor: colorScheme.primaryContainer,
                labelStyle: textTheme.labelMedium?.copyWith(
                  color: act.isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }
}
