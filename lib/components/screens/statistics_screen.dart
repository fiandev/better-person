import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../controllers/controllers.dart';
import '../../routes/route_shell.dart';
import '../theme/habit_focus_theme.dart';
import '../widgets/habit_focus_app_bar.dart';
import 'statistics/statistics_content.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _service = StatisticsService();
  late Future<StatisticsSnapshot> _snapshot;
  StatisticsPeriod _period = StatisticsPeriod.week;

  @override
  void initState() {
    super.initState();
    _listenToSources(true);
    _snapshot = _service.load(_period);
  }

  @override
  void dispose() {
    _listenToSources(false);
    super.dispose();
  }

  void _listenToSources(bool add) {
    for (final controller in [
      HabitController(),
      FocusSessionController(),
      PrayerController(),
      KindnessLogController(),
    ]) {
      if (add) {
        controller.addListener(_reload);
      } else {
        controller.removeListener(_reload);
      }
    }
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _snapshot = _service.load(_period);
    });
  }

  void _selectPeriod(Set<StatisticsPeriod> selection) {
    if (selection.isEmpty) return;
    setState(() {
      _period = selection.first;
      _snapshot = _service.load(_period);
    });
  }

  Future<void> _export(StatisticsSnapshot snapshot) async {
    final format = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 60, 8, 0),
      items: const [
        PopupMenuItem(value: 'csv', child: Text('Copy CSV')),
        PopupMenuItem(value: 'json', child: Text('Copy JSON')),
      ],
    );
    if (format == null) return;
    final content = format == 'csv'
        ? StatisticsExportService.toCsv(snapshot)
        : StatisticsExportService.toJson(snapshot);
    await Clipboard.setData(ClipboardData(text: content));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Statistics ${format.toUpperCase()} copied to clipboard.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HabitFocusAppBar(),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<StatisticsSnapshot>(
          future: _snapshot,
          builder: (context, state) {
            if (state.connectionState != ConnectionState.done) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 220),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (state.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
                children: [
                  const SizedBox(height: 80),
                  const Text('Statistics could not be loaded.'),
                  TextButton(onPressed: _reload, child: const Text('Retry')),
                ],
              );
            }
            final snapshot = state.requireData;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
              children: [
                Row(
                  children: [
                    IntrinsicWidth(
                      child: SegmentedButton<StatisticsPeriod>(
                        segments: const [
                          ButtonSegment(
                            value: StatisticsPeriod.week,
                            label: Text('Week'),
                          ),
                          ButtonSegment(
                            value: StatisticsPeriod.month,
                            label: Text('Month'),
                          ),
                          ButtonSegment(
                            value: StatisticsPeriod.allTime,
                            label: Text('All'),
                          ),
                        ],
                        selected: {_period},
                        onSelectionChanged: _selectPeriod,
                        showSelectedIcon: false,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Export statistics',
                      onPressed: () => _export(snapshot),
                      icon: const Icon(Icons.file_download_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: HabitFocusTheme.stackGap),
                GrowthScorePanel(score: snapshot.growthScore),
                const SizedBox(height: HabitFocusTheme.sectionGap),
                ConsistencyPanel(records: snapshot.consistency),
                const SizedBox(height: HabitFocusTheme.sectionGap),
                ActivitySummaryPanel(summaries: snapshot.summaries),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 4),
    );
  }
}
