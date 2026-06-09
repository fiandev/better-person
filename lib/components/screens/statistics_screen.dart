import 'package:flutter/material.dart';

import '../theme/habit_focus_theme.dart';
import '../widgets/habit_focus_app_bar.dart';
import '../widgets/habit_focus_bottom_nav.dart';
import '../widgets/progress_ring.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const HabitFocusAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
        children: [
          _GrowthScoreCard(
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: HabitFocusTheme.sectionGap),
          _DailyConsistencySection(
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: HabitFocusTheme.sectionGap),
          _ActivityBreakdownSection(
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: HabitFocusTheme.sectionGap),
          _RecentBadgesSection(
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ),
      bottomNavigationBar: const HabitFocusBottomNav(currentIndex: 0),
    );
  }
}

class _GrowthScoreCard extends StatelessWidget {
  const _GrowthScoreCard({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
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
                  'Growth Score',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '85%',
                  style: textTheme.headlineLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFb1f0ce),
                    borderRadius:
                        BorderRadius.circular(HabitFocusTheme.defaultRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+5%',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your growth is on track this week.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ProgressRing(
                  progress: 0.85,
                  color: colorScheme.primary,
                  size: 96,
                  strokeWidth: 8,
                ),
                Icon(
                  Icons.eco,
                  color: colorScheme.primary,
                  size: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyConsistencySection extends StatelessWidget {
  const _DailyConsistencySection({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  static const _barHeights = <double>[0.60, 0.75, 0.90, 1.00, 0.85, 0.50, 0.65];
  static const _dayLabels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _highlightedIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Consistency',
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: HabitFocusTheme.stackGap),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
            boxShadow: [HabitFocusTheme.ambientShadow],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_barHeights.length, (index) {
              final isHighlighted = index == _highlightedIndex;
              final barColor = isHighlighted
                  ? colorScheme.primary
                  : colorScheme.primary.withValues(alpha: 0.4);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: _barHeights[index],
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _dayLabels[index],
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: isHighlighted
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ActivityBreakdownSection extends StatelessWidget {
  const _ActivityBreakdownSection({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Breakdown',
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: HabitFocusTheme.stackGap),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  Expanded(
                    child: _ActivityCard(
                      icon: Icons.work_outline,
                      label: 'Work Focus',
                      labelColor: colorScheme.secondary,
                      value: '18h 45m',
                      subtitle: '+12% from last week',
                      subtitleIcon: Icons.arrow_upward,
                      borderColor: colorScheme.secondary,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActivityCard(
                      icon: Icons.mosque,
                      label: 'Ibadah',
                      labelColor: colorScheme.tertiaryContainer,
                      value: '95%',
                      subtitle: 'High consistency in Shalat & Dzikir.',
                      borderColor: colorScheme.tertiaryContainer,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActivityCard(
                      icon: Icons.favorite,
                      label: 'Kindness',
                      labelColor: colorScheme.primary,
                      value: '24 Acts',
                      subtitle: 'Spreading positivity daily.',
                      borderColor: colorScheme.primary,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _ActivityCard(
                  icon: Icons.work_outline,
                  label: 'Work Focus',
                  labelColor: colorScheme.secondary,
                  value: '18h 45m',
                  subtitle: '+12% from last week',
                  subtitleIcon: Icons.arrow_upward,
                  borderColor: colorScheme.secondary,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12),
                _ActivityCard(
                  icon: Icons.mosque,
                  label: 'Ibadah',
                  labelColor: colorScheme.tertiaryContainer,
                  value: '95%',
                  subtitle: 'High consistency in Shalat & Dzikir.',
                  borderColor: colorScheme.tertiaryContainer,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12),
                _ActivityCard(
                  icon: Icons.favorite,
                  label: 'Kindness',
                  labelColor: colorScheme.primary,
                  value: '24 Acts',
                  subtitle: 'Spreading positivity daily.',
                  borderColor: colorScheme.primary,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.label,
    required this.labelColor,
    required this.value,
    required this.subtitle,
    this.subtitleIcon,
    required this.borderColor,
    required this.colorScheme,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final Color labelColor;
  final String value;
  final String subtitle;
  final IconData? subtitleIcon;
  final Color borderColor;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: labelColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: labelColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              if (subtitleIcon != null) ...[
                Icon(subtitleIcon, size: 14, color: colorScheme.primary),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  subtitle,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentBadgesSection extends StatelessWidget {
  const _RecentBadgesSection({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Badges',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
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
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _badges.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final badge = _badges[index];
              return _BadgeCard(
                badge: badge,
                colorScheme: colorScheme,
                textTheme: textTheme,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BadgeData {
  const _BadgeData({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.detail,
  });

  final String title;
  final IconData icon;
  final Color backgroundColor;
  final String detail;
}

const _badges = <_BadgeData>[
  _BadgeData(
    title: 'Focus Master',
    icon: Icons.psychology,
    backgroundColor: Color(0xFFb1f0ce),
    detail: '10h tracked',
  ),
  _BadgeData(
    title: 'Early Bird',
    icon: Icons.wb_twilight,
    backgroundColor: Color(0xFFc7e7ff),
    detail: '5 days 5AM',
  ),
  _BadgeData(
    title: 'Helper',
    icon: Icons.volunteer_activism,
    backgroundColor: Color(0xFFffdcbd),
    detail: '10 kindness',
  ),
];

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.badge,
    required this.colorScheme,
    required this.textTheme,
  });

  final _BadgeData badge;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: badge.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              badge.icon,
              size: 24,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            badge.title,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            badge.detail,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
