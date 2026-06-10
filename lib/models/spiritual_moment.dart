import 'package:flutter/material.dart';

class SpiritualMoment {
  final String id;
  final String name; // e.g., "Morning Devotion", "Afternoon Mindfulness", "Evening Meditation"
  final TimeOfDay scheduledTime;
  final bool isChecked;
  final DateTime date;
  final DateTime? checkedAt;

  SpiritualMoment({
    required this.id,
    required this.name,
    required this.scheduledTime,
    required this.isChecked,
    required this.date,
    this.checkedAt,
  });

  SpiritualMoment copyWith({
    String? id,
    String? name,
    TimeOfDay? scheduledTime,
    bool? isChecked,
    DateTime? date,
    DateTime? checkedAt,
  }) {
    return SpiritualMoment(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isChecked: isChecked ?? this.isChecked,
      date: date ?? this.date,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scheduledTime': {
        'hour': scheduledTime.hour,
        'minute': scheduledTime.minute,
      },
      'isChecked': isChecked,
      'date': date.toIso8601String(),
      'checkedAt': checkedAt?.toIso8601String(),
    };
  }

  factory SpiritualMoment.fromJson(Map<String, dynamic> json) {
    final timeData = json['scheduledTime'] as Map<String, dynamic>;
    return SpiritualMoment(
      id: json['id'] as String,
      name: json['name'] as String,
      scheduledTime: TimeOfDay(
        hour: timeData['hour'] as int,
        minute: timeData['minute'] as int,
      ),
      isChecked: json['isChecked'] as bool,
      date: DateTime.parse(json['date'] as String),
      checkedAt: json['checkedAt'] != null
          ? DateTime.parse(json['checkedAt'] as String)
          : null,
    );
  }
}

class ReflectionEntry {
  final String id;
  final String name; // e.g., "Morning Mindfulness"
  final int current; // times completed today
  final int total; // target count
  final DateTime date;
  final DateTime? completedAt;

  ReflectionEntry({
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

  ReflectionEntry copyWith({
    String? id,
    String? name,
    int? current,
    int? total,
    DateTime? date,
    DateTime? completedAt,
  }) {
    return ReflectionEntry(
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

  factory ReflectionEntry.fromJson(Map<String, dynamic> json) {
    return ReflectionEntry(
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

class InspirationReading {
  final String id;
  final String name; // e.g., "Inspirational Reading"
  final String label; // e.g., "Daily Reading"
  final String instruction;
  final bool isCompleted;
  final DateTime date;
  final DateTime? completedAt;

  InspirationReading({
    required this.id,
    required this.name,
    required this.label,
    required this.instruction,
    required this.isCompleted,
    required this.date,
    this.completedAt,
  });

  InspirationReading copyWith({
    String? id,
    String? name,
    String? label,
    String? instruction,
    bool? isCompleted,
    DateTime? date,
    DateTime? completedAt,
  }) {
    return InspirationReading(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      instruction: instruction ?? this.instruction,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'label': label,
      'instruction': instruction,
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory InspirationReading.fromJson(Map<String, dynamic> json) {
    return InspirationReading(
      id: json['id'] as String,
      name: json['name'] as String,
      label: json['label'] as String,
      instruction: json['instruction'] as String,
      isCompleted: json['isCompleted'] as bool,
      date: DateTime.parse(json['date'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
