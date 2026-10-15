import 'package:flutter/material.dart';

import '../../../models/statistics.dart' as stats;
import '../../theme/habit_focus_theme.dart';
import '../../widgets/progress_ring.dart';

class GrowthScorePanel extends StatelessWidget {
  const GrowthScorePanel({super.key, required this.score});

  final stats.GrowthScore score;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Growth score',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  score.scoreLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(color: colors.primary),
                ),
                const SizedBox(height: 4),
                Text(score.description),
                const SizedBox(height: 8),
                Text(
                  _trend(score.trend),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: score.trend >= 0 ? colors.primary : colors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label: 'Growth score ${score.scoreLabel}',
            child: ProgressRing(
              progress: score.score.clamp(0.0, 1.0),
              color: colors.primary,
              size: 88,
              strokeWidth: 8,
            ),
          ),
        ],
      ),
    );
  }

  String _trend(double value) {
    final percent = (value * 100).round();
    if (percent == 0) return 'No change from previous period';
    return '${percent > 0 ? '+' : ''}$percent% from previous period';
  }
}

class ConsistencyPanel extends StatelessWidget {
  const ConsistencyPanel({super.key, required this.records});

  final List<stats.DailyConsistencyRecord> records;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily consistency',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Container(
          height: 172,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: records.map((record) {
              final ratio = record.ratio.clamp(0.04, 1.0);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: ratio,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: record.isToday
                                    ? colors.primary
                                    : colors.primary.withValues(alpha: 0.42),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record.dayLabel,
                        semanticsLabel:
                            '${record.date.month}/${record.date.day}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: record.isToday ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ActivitySummaryPanel extends StatelessWidget {
  const ActivitySummaryPanel({super.key, required this.summaries});

  final List<stats.ActivitySummary> summaries;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity breakdown',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 700 ? 3 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: summaries.map((item) {
                final color = switch (item.category) {
                  stats.ActivityCategory.workFocus => colors.secondary,
                  stats.ActivityCategory.ibadah => colors.tertiary,
                  stats.ActivityCategory.kindness => colors.primary,
                };
                final icon = switch (item.category) {
                  stats.ActivityCategory.workFocus => Icons.work_outline,
                  stats.ActivityCategory.ibadah => Icons.mosque_outlined,
                  stats.ActivityCategory.kindness => Icons.favorite_border,
                };
                return SizedBox(
                  width: width,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 150),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(
                        HabitFocusTheme.cardRadius,
                      ),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          icon,
                          color: color,
                          semanticLabel: item.getCategoryLabel(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.getCategoryLabel(),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.value,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.trendLabel ?? item.subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class EarnedBadgesPanel extends StatelessWidget {
  const EarnedBadgesPanel({super.key, required this.badges});

  final List<stats.Badge> badges;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Earned badges',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (badges.length > 3)
              TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  builder: (context) => SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: badges
                          .map((badge) => _BadgeRow(badge: badge))
                          .toList(),
                    ),
                  ),
                ),
                child: const Text('View all'),
              ),
          ],
        ),
        if (badges.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: const Text('Complete activities to earn your first badge.'),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: badges.length.clamp(0, 3),
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _BadgeCard(badge: badges[index]),
            ),
          ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});
  final stats.Badge badge;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 132,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: badge.backgroundColor,
              child: Icon(
                badge.icon,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(badge.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              badge.detail,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.badge});
  final stats.Badge badge;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(
      backgroundColor: badge.backgroundColor,
      child: Icon(badge.icon, color: Theme.of(context).colorScheme.onSurface),
    ),
    title: Text(badge.title),
    subtitle: Text(badge.detail),
  );
}
