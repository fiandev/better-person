import 'dart:convert';

import 'statistics_service.dart';

class StatisticsExportService {
  static String toCsv(StatisticsSnapshot snapshot) {
    final rows = <List<String>>[
      ['Metric', 'Value', 'Comparison'],
      [
        'Growth score',
        snapshot.growthScore.scoreLabel,
        _signedPercent(snapshot.growthScore.trend),
      ],
      ...snapshot.summaries.map(
        (item) => [
          item.getCategoryLabel(),
          item.value,
          item.trendLabel ?? 'No comparison data',
        ],
      ),
      [],
      ['Day', 'Date', 'Consistency'],
      ...snapshot.consistency.map(
        (record) => [
          record.dayLabel,
          _dateKey(record.date),
          '${(record.ratio * 100).round()}%',
        ],
      ),
    ];
    return rows.map((row) => row.map(_csvCell).join(',')).join('\n');
  }

  static String toJson(StatisticsSnapshot snapshot) => jsonEncode({
    'growthScore': snapshot.growthScore.toJson(),
    'summaries': snapshot.summaries.map((item) => item.toJson()).toList(),
    'dailyConsistency': snapshot.consistency
        .map((item) => item.toJson())
        .toList(),
  });

  static String _signedPercent(double trend) {
    final value = (trend * 100).round();
    return '${value > 0 ? '+' : ''}$value%';
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _csvCell(String value) => '"${value.replaceAll('"', '""')}"';
}
