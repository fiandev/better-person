class HabitCompletion {
  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completedAt,
  });

  final String id;
  final String habitId;
  final DateTime date;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'habitId': habitId,
    'date': date.toIso8601String(),
    'completedAt': completedAt.toIso8601String(),
  };

  factory HabitCompletion.fromJson(Map<String, dynamic> json) =>
      HabitCompletion(
        id: json['id'] as String,
        habitId: json['habitId'] as String,
        date: DateTime.parse(json['date'] as String),
        completedAt: DateTime.parse(json['completedAt'] as String),
      );
}
