import 'package:material_ui/material_ui.dart';

import '../../theme/habit_focus_theme.dart';

class WeeklySummaryPreview extends StatelessWidget {
  const WeeklySummaryPreview({
    super.key,
    required this.focusMinutes,
    required this.kindnessActs,
  });

  final int focusMinutes;
  final int kindnessActs;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hours = focusMinutes ~/ 60;
    final minutes = focusMinutes % 60;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This week', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryValue(
                  label: 'Focus',
                  value: '${hours}h ${minutes}m',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryValue(
                  label: 'Kindness',
                  value: '$kindnessActs acts',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 4),
      Text(value, style: Theme.of(context).textTheme.titleLarge),
    ],
  );
}
