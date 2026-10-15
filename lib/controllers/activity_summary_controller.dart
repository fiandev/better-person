import '../models/statistics.dart';
import 'identified_controller.dart';

class ActivitySummaryController extends IdentifiedController<ActivitySummary> {
  static final ActivitySummaryController _instance =
      ActivitySummaryController._internal();
  factory ActivitySummaryController() => _instance;
  ActivitySummaryController._internal();

  @override
  String get storageKey => 'activity_summaries';
  @override
  Map<String, dynamic> toJson(ActivitySummary item) => item.toJson();
  @override
  ActivitySummary fromJson(Map<String, dynamic> json) =>
      ActivitySummary.fromJson(json);
  @override
  String idOf(ActivitySummary item) => item.id;
  @override
  ActivitySummary applyFields(
    ActivitySummary item,
    Map<String, dynamic> fields,
  ) => item.copyWith(
    category: fields['category'] as ActivityCategory? ?? item.category,
    label: fields['label'] as String? ?? item.label,
    value: fields['value'] as String? ?? item.value,
    subtitle: fields['subtitle'] as String? ?? item.subtitle,
    trendLabel: fields.containsKey('trendLabel')
        ? fields['trendLabel'] as String?
        : item.trendLabel,
    weekStartDate: fields['weekStartDate'] as DateTime? ?? item.weekStartDate,
  );

  List<ActivitySummary> getByCategory(ActivityCategory category) =>
      findWhere((summary) => summary.category == category);
}
