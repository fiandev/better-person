class KindnessLog {
  final String id;
  final DateTime date;
  final List<String> selectedActIds; // IDs of KindnessAct that were selected
  final String reflectionText; // free-text reflection from the user
  final DateTime createdAt;

  KindnessLog({
    required this.id,
    required this.date,
    required this.selectedActIds,
    required this.reflectionText,
    required this.createdAt,
  });

  KindnessLog copyWith({
    String? id,
    DateTime? date,
    List<String>? selectedActIds,
    String? reflectionText,
    DateTime? createdAt,
  }) {
    return KindnessLog(
      id: id ?? this.id,
      date: date ?? this.date,
      selectedActIds: selectedActIds ?? this.selectedActIds,
      reflectionText: reflectionText ?? this.reflectionText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'selectedActIds': selectedActIds,
      'reflectionText': reflectionText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory KindnessLog.fromJson(Map<String, dynamic> json) {
    return KindnessLog(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      selectedActIds: List<String>.from(json['selectedActIds'] as List),
      reflectionText: json['reflectionText'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class WeeklyKindnessStats {
  final int count; // total acts this week
  final int goal; // weekly goal
  final DateTime weekStartDate;

  WeeklyKindnessStats({
    required this.count,
    required this.goal,
    required this.weekStartDate,
  });

  double get progress => goal > 0 ? (count / goal).clamp(0.0, 1.0) : 0.0;

  String get progressLabel => '$count/$goal';

  WeeklyKindnessStats copyWith({
    int? count,
    int? goal,
    DateTime? weekStartDate,
  }) {
    return WeeklyKindnessStats(
      count: count ?? this.count,
      goal: goal ?? this.goal,
      weekStartDate: weekStartDate ?? this.weekStartDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'goal': goal,
      'weekStartDate': weekStartDate.toIso8601String(),
    };
  }

  factory WeeklyKindnessStats.fromJson(Map<String, dynamic> json) {
    return WeeklyKindnessStats(
      count: json['count'] as int,
      goal: json['goal'] as int,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
    );
  }
}
