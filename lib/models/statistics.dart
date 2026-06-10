import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Badge
// ---------------------------------------------------------------------------

class Badge {
  final String id;
  final String title; // e.g., "Focus Master", "Early Bird", "Helper"
  final IconData icon;
  final Color backgroundColor;
  final String detail; // e.g., "10h tracked", "5 days 5AM", "10 kindness"
  final DateTime? earnedDate;

  Badge({
    required this.id,
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.detail,
    this.earnedDate,
  });

  Badge copyWith({
    String? id,
    String? title,
    IconData? icon,
    Color? backgroundColor,
    String? detail,
    DateTime? earnedDate,
  }) {
    return Badge(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      detail: detail ?? this.detail,
      earnedDate: earnedDate ?? this.earnedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'backgroundColor': backgroundColor.toARGB32(),
      'detail': detail,
      'earnedDate': earnedDate?.toIso8601String(),
    };
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: IconData(
        json['iconCodePoint'] as int,
        fontFamily: json['iconFontFamily'] as String?,
      ),
      backgroundColor: Color(json['backgroundColor'] as int),
      detail: json['detail'] as String,
      earnedDate: json['earnedDate'] != null
          ? DateTime.parse(json['earnedDate'] as String)
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// GrowthScore
// ---------------------------------------------------------------------------

class GrowthScore {
  final String id;
  final double score; // 0.0–1.0, e.g. 0.85
  final double trend; // positive/negative change, e.g. +0.05
  final String description;
  final DateTime weekStartDate;

  GrowthScore({
    required this.id,
    required this.score,
    required this.trend,
    required this.description,
    required this.weekStartDate,
  });

  /// Score as a percentage string, e.g., "85%".
  String get scoreLabel => '${(score * 100).round()}%';

  /// Trend as a signed percentage string, e.g., "+5%" or "-3%".
  String get trendLabel {
    final pct = (trend * 100).round();
    return pct >= 0 ? '+$pct%' : '$pct%';
  }

  GrowthScore copyWith({
    String? id,
    double? score,
    double? trend,
    String? description,
    DateTime? weekStartDate,
  }) {
    return GrowthScore(
      id: id ?? this.id,
      score: score ?? this.score,
      trend: trend ?? this.trend,
      description: description ?? this.description,
      weekStartDate: weekStartDate ?? this.weekStartDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'trend': trend,
      'description': description,
      'weekStartDate': weekStartDate.toIso8601String(),
    };
  }

  factory GrowthScore.fromJson(Map<String, dynamic> json) {
    return GrowthScore(
      id: json['id'] as String,
      score: (json['score'] as num).toDouble(),
      trend: (json['trend'] as num).toDouble(),
      description: json['description'] as String,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
    );
  }
}

// ---------------------------------------------------------------------------
// ActivityCategory & ActivitySummary
// ---------------------------------------------------------------------------

enum ActivityCategory {
  workFocus,
  ibadah,
  kindness,
}

class ActivitySummary {
  final String id;
  final ActivityCategory category;
  final String label; // display label, e.g., "Work Focus"
  final String value; // e.g., "18h 45m", "95%", "24 Acts"
  final String subtitle; // e.g., "+12% from last week"
  final String? trendLabel; // optional explicit trend text
  final DateTime weekStartDate;

  ActivitySummary({
    required this.id,
    required this.category,
    required this.label,
    required this.value,
    required this.subtitle,
    this.trendLabel,
    required this.weekStartDate,
  });

  String getCategoryLabel() {
    switch (category) {
      case ActivityCategory.workFocus:
        return 'Work Focus';
      case ActivityCategory.ibadah:
        return 'Ibadah';
      case ActivityCategory.kindness:
        return 'Kindness';
    }
  }

  ActivitySummary copyWith({
    String? id,
    ActivityCategory? category,
    String? label,
    String? value,
    String? subtitle,
    String? trendLabel,
    DateTime? weekStartDate,
  }) {
    return ActivitySummary(
      id: id ?? this.id,
      category: category ?? this.category,
      label: label ?? this.label,
      value: value ?? this.value,
      subtitle: subtitle ?? this.subtitle,
      trendLabel: trendLabel ?? this.trendLabel,
      weekStartDate: weekStartDate ?? this.weekStartDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'label': label,
      'value': value,
      'subtitle': subtitle,
      'trendLabel': trendLabel,
      'weekStartDate': weekStartDate.toIso8601String(),
    };
  }

  factory ActivitySummary.fromJson(Map<String, dynamic> json) {
    return ActivitySummary(
      id: json['id'] as String,
      category: ActivityCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      label: json['label'] as String,
      value: json['value'] as String,
      subtitle: json['subtitle'] as String,
      trendLabel: json['trendLabel'] as String?,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
    );
  }
}

// ---------------------------------------------------------------------------
// DailyConsistencyRecord
// ---------------------------------------------------------------------------

class DailyConsistencyRecord {
  final String id;
  final DateTime date;
  final String dayLabel; // e.g., "M", "T", "W"
  final double ratio; // 0.0–1.0 normalized completion for the day

  DailyConsistencyRecord({
    required this.id,
    required this.date,
    required this.dayLabel,
    required this.ratio,
  });

  /// Whether this day is the current/today day.
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  DailyConsistencyRecord copyWith({
    String? id,
    DateTime? date,
    String? dayLabel,
    double? ratio,
  }) {
    return DailyConsistencyRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      dayLabel: dayLabel ?? this.dayLabel,
      ratio: ratio ?? this.ratio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'dayLabel': dayLabel,
      'ratio': ratio,
    };
  }

  factory DailyConsistencyRecord.fromJson(Map<String, dynamic> json) {
    return DailyConsistencyRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      dayLabel: json['dayLabel'] as String,
      ratio: (json['ratio'] as num).toDouble(),
    );
  }
}
