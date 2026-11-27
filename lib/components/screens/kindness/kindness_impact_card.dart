import 'package:material_ui/material_ui.dart';

import '../../../controllers/kindness_log_controller.dart';
import '../../../controllers/setting_controller.dart';
import '../../theme/habit_focus_theme.dart';

class KindnessImpactCard extends StatelessWidget {
  const KindnessImpactCard({super.key, required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final count = KindnessLogController().getThisWeekLogs().fold<int>(
      0,
      (sum, log) => sum + log.selectedActIds.length,
    );
    final goal = SettingController().getCurrentSetting().weeklyKindnessGoal;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Your Impact', style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.onTertiaryContainer,
          )),
          const SizedBox(height: 8),
          Text('$count', style: textTheme.headlineLarge?.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: colorScheme.onTertiaryContainer,
          )),
          const SizedBox(height: 8),
          Text('Acts of kindness this week', textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onTertiaryContainer,
              )),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: (count / goal).clamp(0.0, 1.0),
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: colorScheme.primary,
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            count >= goal ? 'Weekly goal reached.' : '${goal - count} more to reach your goal',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onTertiaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
