import 'package:material_ui/material_ui.dart';

import '../../theme/habit_focus_theme.dart';

class KindnessReflectionCard extends StatelessWidget {
  const KindnessReflectionCard({
    super.key,
    required this.colorScheme,
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final ColorScheme colorScheme;
  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.edit_note, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text('Reflection', style: textTheme.headlineMedium),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe your act of kindness or how it made you feel.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(HabitFocusTheme.defaultRadius),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: isSubmitting ? null : onSubmit,
              icon: isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, size: 18),
              label: const Text('Log Kindness'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(44, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
