class DzikirEntry {
  final String id;
  final String name; // e.g., "Morning Dzikir", "Evening Dzikir"
  final int current; // how many times repeated so far
  final int total; // target count, e.g., 33
  final DateTime date;
  final DateTime? completedAt;

  DzikirEntry({
    required this.id,
    required this.name,
    required this.current,
    required this.total,
    required this.date,
    this.completedAt,
  });

  bool get isCompleted => current >= total;

  double get progress => total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

  String get countLabel => '$current/$total';

  DzikirEntry copyWith({
    String? id,
    String? name,
    int? current,
    int? total,
    DateTime? date,
    DateTime? completedAt,
  }) {
    return DzikirEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      current: current ?? this.current,
      total: total ?? this.total,
      date: date ?? this.date,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'current': current,
      'total': total,
      'date': date.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory DzikirEntry.fromJson(Map<String, dynamic> json) {
    return DzikirEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      current: json['current'] as int,
      total: json['total'] as int,
      date: DateTime.parse(json['date'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
