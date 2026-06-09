import 'package:flutter/material.dart';

import '../theme/habit_focus_theme.dart';
import '../widgets/daily_progress_bar.dart';
import '../widgets/habit_card.dart';
import '../widgets/habit_focus_app_bar.dart';
import '../widgets/progress_ring.dart';
import '../../routes/route_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const HabitFocusAppBar(),
      body: Column(
        children: [
          DailyProgressBar(
            progress: 0.65,
            color: colorScheme.primary,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
              children: [
                _GreetingSection(
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: HabitFocusTheme.sectionGap),
                _BentoGrid(
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: HabitFocusTheme.sectionGap),
                _KeyHabitsSection(
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 0),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection({
    required this.textTheme,
    required this.colorScheme,
  });

  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Morning, Sarah.',
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
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _BentoGrid extends StatelessWidget {
  const _BentoGrid({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final gap = HabitFocusTheme.stackGap;

        if (crossAxisCount == 2) {
          return Column(
            children: [
              _MainProgressCard(
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              SizedBox(height: gap),
              Row(
                children: [
                  Expanded(
                    child: _SmallStatCard(
                      icon: Icons.timer,
                      iconColor: colorScheme.secondary,
                      label: 'Deep Work',
                      value: '2h 15m',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: _SmallStatCard(
                      icon: Icons.auto_awesome_motion,
                      iconColor: colorScheme.tertiary,
                      label: 'Devotion',
                      value: '3/5',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
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
              child: _MainProgressCard(
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _SmallStatCard(
                icon: Icons.timer,
                iconColor: colorScheme.secondary,
                label: 'Deep Work',
                value: '2h 15m',
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _SmallStatCard(
                icon: Icons.auto_awesome_motion,
                iconColor: colorScheme.tertiary,
                label: 'Devotion',
                value: '3/5',
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MainProgressCard extends StatelessWidget {
  const _MainProgressCard({
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
                  "Today's Focus",
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '65% Completed',
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
                      '12-day streak',
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
            progress: 0.65,
            color: colorScheme.primary,
            size: 80,
            strokeWidth: 8,
          ),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.textTheme,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyHabitsSection extends StatelessWidget {
  const _KeyHabitsSection({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
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
        HabitCard(
          title: 'Morning Meditation',
          categoryLabel: 'Growth',
          categoryColor: colorScheme.primary,
          duration: '10 mins',
          isCompleted: true,
        ),
        const SizedBox(height: 12),
        HabitCard(
          title: 'Deep Work Session',
          categoryLabel: 'Work',
          categoryColor: colorScheme.secondary,
          duration: '90 mins',
          isCompleted: false,
        ),
        const SizedBox(height: 12),
        HabitCard(
          title: 'Daily Impact',
          categoryLabel: 'Kindness',
          categoryColor: colorScheme.tertiary,
          duration: 'Any amount',
          isCompleted: false,
        ),
      ],
    );
  }
}
