import '../models/statistics.dart';
import 'identified_controller.dart';

class GrowthScoreController extends IdentifiedController<GrowthScore> {
  static final GrowthScoreController _instance =
      GrowthScoreController._internal();
  factory GrowthScoreController() => _instance;
  GrowthScoreController._internal();

  @override
  String get storageKey => 'growth_scores';
  @override
  Map<String, dynamic> toJson(GrowthScore item) => item.toJson();
  @override
  GrowthScore fromJson(Map<String, dynamic> json) => GrowthScore.fromJson(json);
  @override
  String idOf(GrowthScore item) => item.id;
  @override
  GrowthScore applyFields(GrowthScore item, Map<String, dynamic> fields) =>
      item.copyWith(
        score: fields['score'] as double? ?? item.score,
        trend: fields['trend'] as double? ?? item.trend,
        description: fields['description'] as String? ?? item.description,
        weekStartDate:
            fields['weekStartDate'] as DateTime? ?? item.weekStartDate,
      );

  GrowthScore? getCurrentWeekScore() {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    return findFirst((score) {
      final start = score.weekStartDate;
      return start.year == weekStart.year &&
          start.month == weekStart.month &&
          start.day == weekStart.day;
    });
  }
}
