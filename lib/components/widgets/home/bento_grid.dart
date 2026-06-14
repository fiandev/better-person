import 'package:flutter/material.dart';

import '../../theme/habit_focus_theme.dart';
import 'main_progress_card.dart';
import 'small_stat_card.dart';

class BentoGrid extends StatelessWidget {
  const BentoGrid({
    super.key,
    required this.todayProgress,
    required this.streak,
    required this.deepWorkTime,
    required this.devotionCount,
  });

  final double todayProgress;
  final int streak;
  final String deepWorkTime;
  final int devotionCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final gap = HabitFocusTheme.stackGap;

        if (crossAxisCount == 2) {
          return Column(
            children: [
              MainProgressCard(
                progress: todayProgress,
                streak: streak,
              ),
              SizedBox(height: gap),
              Row(
                children: [
                  Expanded(
                    child: SmallStatCard(
                      icon: Icons.timer,
                      iconColor: colorScheme.secondary,
                      label: 'Deep Work',
                      value: deepWorkTime,
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: SmallStatCard(
                      icon: Icons.auto_awesome_motion,
                      iconColor: colorScheme.tertiary,
                      label: 'Devotion',
                      value: '$devotionCount',
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // Desktop 4-column layout
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: MainProgressCard(
                progress: todayProgress,
                streak: streak,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: SmallStatCard(
                icon: Icons.timer,
                iconColor: colorScheme.secondary,
                label: 'Deep Work',
                value: deepWorkTime,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: SmallStatCard(
                icon: Icons.auto_awesome_motion,
                iconColor: colorScheme.tertiary,
                label: 'Devotion',
                value: '$devotionCount',
              ),
            ),
          ],
        );
      },
    );
  }
}
