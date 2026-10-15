import '../models/statistics.dart';
import 'identified_controller.dart';

class DailyConsistencyRecordController
    extends IdentifiedController<DailyConsistencyRecord> {
  static final DailyConsistencyRecordController _instance =
      DailyConsistencyRecordController._internal();
  factory DailyConsistencyRecordController() => _instance;
  DailyConsistencyRecordController._internal();

  @override
  String get storageKey => 'daily_consistency_records';
  @override
  Map<String, dynamic> toJson(DailyConsistencyRecord item) => item.toJson();
  @override
  DailyConsistencyRecord fromJson(Map<String, dynamic> json) =>
      DailyConsistencyRecord.fromJson(json);
  @override
  String idOf(DailyConsistencyRecord item) => item.id;
  @override
  DailyConsistencyRecord applyFields(
    DailyConsistencyRecord item,
    Map<String, dynamic> fields,
  ) => item.copyWith(
    date: fields['date'] as DateTime? ?? item.date,
    dayLabel: fields['dayLabel'] as String? ?? item.dayLabel,
    ratio: fields['ratio'] as double? ?? item.ratio,
  );

  DailyConsistencyRecord? getByDate(DateTime date) => findFirst(
    (record) =>
        record.date.year == date.year &&
        record.date.month == date.month &&
        record.date.day == date.day,
  );
}
