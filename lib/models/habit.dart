import 'package:flutter/material.dart';

enum HabitCategory {
  growth,
  work,
  kindness,
  devotion,
}

class Habit {
  final String id;
  final String title;
  final String? subtitle;
  final HabitCategory category;
  final String? duration; // e.g., "10 mins", "90 mins", "Any amount"
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  Habit({
    required this.id,
    required this.title,
    this.subtitle,
    required this.category,
    this.duration,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
  });

  Color getCategoryColor(ColorScheme colorScheme) {
    switch (category) {
      case HabitCategory.growth:
        return colorScheme.primary;
      case HabitCategory.work:
        return colorScheme.secondary;
      case HabitCategory.kindness:
        return colorScheme.tertiary;
      case HabitCategory.devotion:
        return colorScheme.tertiary;
    }
  }

  String getCategoryLabel() {
    switch (category) {
      case HabitCategory.growth:
        return 'Growth';
      case HabitCategory.work:
        return 'Work';
      case HabitCategory.kindness:
        return 'Kindness';
      case HabitCategory.devotion:
        return 'Devotion';
    }
  }

  Habit copyWith({
    String? id,
    String? title,
    String? subtitle,
    HabitCategory? category,
    String? duration,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category.name,
      'duration': duration,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      category: HabitCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      duration: json['duration'] as String?,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
