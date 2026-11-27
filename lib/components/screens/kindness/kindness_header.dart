import 'package:material_ui/material_ui.dart';

class KindnessHeader extends StatelessWidget {
  const KindnessHeader({super.key, required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.volunteer_activism,
            size: 160, color: colorScheme.onSurface.withValues(alpha: 0.05)),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFffdcbd),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text('Daily Reflection',
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF623f18),
                  )),
            ),
            const SizedBox(height: 16),
            Text('How did you help today?',
                style: textTheme.headlineLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Small acts of kindness create a ripple effect. Log your moments of connection and compassion.',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
