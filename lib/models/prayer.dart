import 'package:flutter/material.dart';

enum PrayerName {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
}

class Prayer {
  final String id;
  final PrayerName name;
  final TimeOfDay scheduledTime;
  final bool isChecked;
  final DateTime date; // which day this prayer is for
  final DateTime? checkedAt;

  Prayer({
    required this.id,
    required this.name,
    required this.scheduledTime,
    required this.isChecked,
    required this.date,
    this.checkedAt,
  });

  String getPrayerLabel() {
    switch (name) {
      case PrayerName.fajr:
        return 'Fajr';
      case PrayerName.dhuhr:
        return 'Dhuhr';
      case PrayerName.asr:
        return 'Asr';
      case PrayerName.maghrib:
        return 'Maghrib';
      case PrayerName.isha:
        return 'Isha';
    }
  }

  Color getBorderColor(ColorScheme colorScheme) {
    return isChecked ? colorScheme.primary : colorScheme.outline;
  }

  Prayer copyWith({
    String? id,
    PrayerName? name,
    TimeOfDay? scheduledTime,
    bool? isChecked,
    DateTime? date,
    DateTime? checkedAt,
  }) {
    return Prayer(
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
      'name': name.name,
      'scheduledTime': {
        'hour': scheduledTime.hour,
        'minute': scheduledTime.minute,
      },
      'isChecked': isChecked,
      'date': date.toIso8601String(),
      'checkedAt': checkedAt?.toIso8601String(),
    };
  }

  factory Prayer.fromJson(Map<String, dynamic> json) {
    final timeData = json['scheduledTime'] as Map<String, dynamic>;
    return Prayer(
      id: json['id'] as String,
      name: PrayerName.values.firstWhere((e) => e.name == json['name']),
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
