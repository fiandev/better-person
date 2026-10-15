import '../models/habit_completion.dart';
import 'identified_controller.dart';

class HabitCompletionController extends IdentifiedController<HabitCompletion> {
  static final HabitCompletionController _instance =
      HabitCompletionController._internal();
  factory HabitCompletionController() => _instance;
  HabitCompletionController._internal();

  @override
  String get storageKey => 'habit_completions';
  @override
  Map<String, dynamic> toJson(HabitCompletion item) => item.toJson();
  @override
  HabitCompletion fromJson(Map<String, dynamic> json) =>
      HabitCompletion.fromJson(json);
  @override
  String idOf(HabitCompletion item) => item.id;
  @override
  HabitCompletion applyFields(
    HabitCompletion item,
    Map<String, dynamic> fields,
  ) => item;

  List<HabitCompletion> getByDate(DateTime date) => findWhere(
    (record) =>
        record.date.year == date.year &&
        record.date.month == date.month &&
        record.date.day == date.day,
  );

  List<HabitCompletion> getByRange(DateTime start, DateTime end) => findWhere(
    (record) => !record.date.isBefore(start) && record.date.isBefore(end),
  );

  Future<void> record(String habitId, DateTime completedAt) async {
    final date = DateTime(completedAt.year, completedAt.month, completedAt.day);
    final id = '${habitId}_${date.year}_${date.month}_${date.day}';
    if (getById(id) != null) return;
    await create(
      HabitCompletion(
        id: id,
        habitId: habitId,
        date: date,
        completedAt: completedAt,
      ),
    );
  }
}
