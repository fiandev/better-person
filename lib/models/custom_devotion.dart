import 'package:flutter/material.dart';

class CustomDevotion {
  final String id;
  final String name; // e.g., "Morning Meditation", "Evening Prayer", "Gratitude Journal"
  final TimeOfDay scheduledTime;
  final bool isCompleted;
  final DateTime date;
  final DateTime? completedAt;

  CustomDevotion({
    required this.id,
    required this.name,
    required this.scheduledTime,
    required this.isCompleted,
    required this.date,
    this.completedAt,
  });

  CustomDevotion copyWith({
    String? id,
    String? name,
    TimeOfDay? scheduledTime,
    bool? isCompleted,
    DateTime? date,
    DateTime? completedAt,
  }) {
    return CustomDevotion(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      completedAt: completedAt ?? this.completedAt,
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
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory CustomDevotion.fromJson(Map<String, dynamic> json) {
    final timeData = json['scheduledTime'] as Map<String, dynamic>;
    return CustomDevotion(
      id: json['id'] as String,
      name: json['name'] as String,
      scheduledTime: TimeOfDay(
        hour: timeData['hour'] as int,
        minute: timeData['minute'] as int,
      ),
      isCompleted: json['isCompleted'] as bool,
      date: DateTime.parse(json['date'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
