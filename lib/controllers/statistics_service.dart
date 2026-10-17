import '../models/statistics.dart';
import 'activity_summary_controller.dart';
import 'focus_session_controller.dart';
import 'growth_score_controller.dart';
import 'habit_controller.dart';
import 'habit_completion_controller.dart';
import 'kindness_log_controller.dart';
import 'prayer_controller.dart';
import 'statistics_metrics.dart';

enum StatisticsPeriod { week, month, allTime }

class StatisticsSnapshot {
  const StatisticsSnapshot({
    required this.growthScore,
    required this.consistency,
    required this.summaries,
  });

  final GrowthScore growthScore;
  final List<DailyConsistencyRecord> consistency;
  final List<ActivitySummary> summaries;
}

class StatisticsService {
  final _growthScores = GrowthScoreController();
  final _summaries = ActivitySummaryController();
  final _habits = HabitController();
  final _habitCompletions = HabitCompletionController();
  final _sessions = FocusSessionController();
  final _prayers = PrayerController();
  final _kindness = KindnessLogController();
  late final _metrics = StatisticsMetrics(_prayers, _kindness);

  Future<StatisticsSnapshot> load(StatisticsPeriod period) async {
    final range = _range(period);
    final previous = period == StatisticsPeriod.allTime
        ? null
        : _range(period, previous: true);
    final score = _growthScoreFor(range, previous);
    final summaries = _activitySummaries(range, previous);
    final consistency = _dailyConsistency(DateTime.now());
    final snapshot = StatisticsSnapshot(
      growthScore: score,
      consistency: consistency,
      summaries: summaries,
    );
    final savedScore = _growthScores.getById(score.id);
    if (savedScore == null) {
      await _growthScores.create(score);
    } else {
      await _growthScores.update(score.id, score);
    }
    for (final summary in summaries) {
      final saved = _summaries.getById(summary.id);
      if (saved == null) {
        await _summaries.create(summary);
      } else {
        await _summaries.update(summary.id, summary);
      }
    }
    return snapshot;
  }

  Future<GrowthScore> calculateGrowthScore() async {
    final current = _range(StatisticsPeriod.week);
    final previous = _range(StatisticsPeriod.week, previous: true);
    return _growthScoreFor(current, previous);
  }

  Future<List<ActivitySummary>> calculateActivitySummaries() async =>
      _activitySummaries(
        _range(StatisticsPeriod.week),
        _range(StatisticsPeriod.week, previous: true),
      );

  Future<List<DailyConsistencyRecord>> calculateDailyConsistency() async =>
      _dailyConsistency(DateTime.now());

  GrowthScore _growthScoreFor(_DateRange range, _DateRange? previous) {
    final current = _score(range);
    final previousScore = previous == null ? current : _score(previous);
    final dateKey =
        '${range.start.year}-${range.start.month}-${range.start.day}';
    return GrowthScore(
      id: 'growth_$dateKey',
      score: current,
      trend: current - previousScore,
      description: _description(current),
      weekStartDate: range.start,
    );
  }

  List<ActivitySummary> _activitySummaries(
    _DateRange range,
    _DateRange? previous,
  ) {
    final currentFocus = _focusMinutes(range);
    final currentPrayer = _prayerCounts(range);
    final prayerDetail = _metrics.prayerDetail(range.start, range.end);
    final currentKindness = _kindnessCount(range);
    final previousFocus = previous == null ? 0 : _focusMinutes(previous);
    final previousPrayer = previous == null ? (0, 0) : _prayerCounts(previous);
    final previousKindness = previous == null ? 0 : _kindnessCount(previous);
    final suffix = '${range.start.millisecondsSinceEpoch}';
    return [
      ActivitySummary(
        id: 'work_$suffix',
        category: ActivityCategory.workFocus,
        label: 'Deep Work',
        value: _formatMinutes(currentFocus),
        subtitle: _periodLabel(range),
        trendLabel: previous == null
            ? null
            : _compare(currentFocus.toDouble(), previousFocus.toDouble()),
        weekStartDate: range.start,
      ),
      ActivitySummary(
        id: 'ibadah_$suffix',
        category: ActivityCategory.ibadah,
        label: 'Prayer',
        value: currentPrayer.$2 == 0
            ? 'No prayer records'
            : '${(currentPrayer.$1 / currentPrayer.$2 * 100).round()}%',
        subtitle: currentPrayer.$2 == 0
            ? 'No prayers recorded for this period'
            : '${prayerDetail.$1} on time, ${prayerDetail.$2} missed, ${_metrics.devotionStreak()}-day prayer streak',
        trendLabel: previous == null || previousPrayer.$2 == 0
            ? null
            : _compare(
                currentPrayer.$1 / currentPrayer.$2,
                previousPrayer.$1 / previousPrayer.$2,
              ),
        weekStartDate: range.start,
      ),
      ActivitySummary(
        id: 'kindness_$suffix',
        category: ActivityCategory.kindness,
        label: 'Kindness Acts',
        value: '$currentKindness acts',
        subtitle:
            '${_periodLabel(range)}; ${_metrics.kindnessStreak()}-day kindness streak',
        trendLabel: previous == null
            ? null
            : _compare(currentKindness.toDouble(), previousKindness.toDouble()),
        weekStartDate: range.start,
      ),
    ];
  }

  double _score(_DateRange range) {
    final habits = _habits.getAll();
    final completedHabits = _habitCompletions
        .getByRange(range.start, range.end)
        .length;
    final possibleHabits = habits.length * range.days;
    final habitScore = _ratio(completedHabits, possibleHabits);
    final focusScore = (_focusMinutes(range) / (range.days / 7 * 20 * 60))
        .clamp(0.0, 1.0);
    final prayers = _prayerCounts(range);
    final devotionScore = _ratio(prayers.$1, prayers.$2);
    final targetActs = (range.days / 7 * 14).ceil();
    final kindnessScore = _ratio(_kindnessCount(range), targetActs);
    return habitScore * 0.3 +
        focusScore * 0.3 +
        devotionScore * 0.2 +
        kindnessScore * 0.2;
  }

  List<DailyConsistencyRecord> _dailyConsistency(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    final habits = _habits.getAll();
    final records = <DailyConsistencyRecord>[];
    for (var index = 0; index < 7; index++) {
      final date = start.add(Duration(days: index));
      final dayHabits = _habitCompletions
          .getByDate(date)
          .map((record) => record.habitId)
          .toSet()
          .length;
      final hasRecordedActivity =
          _sessions.getAll().any(
            (session) =>
                _sameDay(session.createdAt, date) &&
                session.elapsed.inSeconds > 0,
          ) ||
          _prayers.getByDate(date).any((prayer) => prayer.isChecked) ||
          _kindness.getByDate(date).any((log) => log.selectedActIds.isNotEmpty);
      final ratio = habits.isNotEmpty
          ? (dayHabits / habits.length).clamp(0.0, 1.0)
          : (hasRecordedActivity ? 1.0 : 0.0);
      records.add(
        DailyConsistencyRecord(
          id: 'consistency_${_dateKey(date)}',
          date: date,
          dayLabel: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1],
          ratio: ratio,
        ),
      );
    }
    return records;
  }

  int _focusMinutes(_DateRange range) => _sessions
      .getAll()
      .where((session) => range.contains(session.createdAt))
      .fold(0, (sum, session) => sum + session.elapsed.inMinutes);

  (int, int) _prayerCounts(_DateRange range) {
    final prayers = _prayers.getAll().where(
      (prayer) => range.contains(prayer.date),
    );
    final list = prayers.toList();
    return (list.where((prayer) => prayer.isChecked).length, list.length);
  }

  int _kindnessCount(_DateRange range) => _kindness
      .getAll()
      .where((log) => range.contains(log.date))
      .fold(0, (sum, log) => sum + log.selectedActIds.length);

  _DateRange _range(StatisticsPeriod period, {bool previous = false}) {
    final now = DateTime.now();
    if (period == StatisticsPeriod.week) {
      final today = DateTime(now.year, now.month, now.day);
      final start = today.subtract(Duration(days: now.weekday - 1));
      final shifted = previous
          ? start.subtract(const Duration(days: 7))
          : start;
      return _DateRange(shifted, shifted.add(const Duration(days: 7)));
    }
    if (period == StatisticsPeriod.month) {
      final start = DateTime(now.year, now.month, 1);
      final shifted = previous ? DateTime(now.year, now.month - 1, 1) : start;
      return _DateRange(shifted, DateTime(shifted.year, shifted.month + 1, 1));
    }
    final earliest = [
      ..._habits.getAll().map((item) => item.createdAt),
      ..._sessions.getAll().map((item) => item.createdAt),
      ..._kindness.getAll().map((item) => item.date),
    ];
    final start = earliest.isEmpty
        ? DateTime(now.year, now.month, now.day)
        : earliest.reduce((a, b) => a.isBefore(b) ? a : b);
    return _DateRange(
      DateTime(start.year, start.month, start.day),
      DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
    );
  }

  String _description(double score) {
    if (score >= 0.8) return 'Strong consistency this period';
    if (score >= 0.6) return 'Steady progress this period';
    if (score >= 0.4) return 'Some progress this period';
    return 'A fresh start is always available';
  }

  String _compare(double current, double previous) {
    if (previous == 0) return current == 0 ? 'No change' : 'New this period';
    final change = ((current - previous) / previous * 100).round();
    if (change == 0) return 'No change';
    return '${change > 0 ? '+' : ''}$change% vs previous period';
  }

  String _formatMinutes(int minutes) =>
      '${minutes ~/ 60} h ${minutes % 60} min';
  String _periodLabel(_DateRange range) =>
      'From ${_dateKey(range.start)} to ${_dateKey(range.end.subtract(const Duration(days: 1)))}';
  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  double _ratio(int value, int total) =>
      total <= 0 ? 0 : (value / total).clamp(0.0, 1.0);
  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateRange {
  const _DateRange(this.start, this.end);
  final DateTime start;
  final DateTime end;
  int get days => end.difference(start).inDays.clamp(1, 100000);
  bool contains(DateTime date) => !date.isBefore(start) && date.isBefore(end);
}
