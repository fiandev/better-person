class Setting {
  final String id;
  final String defaultCurrencyFormat;
  final String themeMode;
  final String localeCode;
  final bool notificationsEnabled;
  final int focusMinutes;
  final int breakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;
  final int weeklyKindnessGoal;
  final String prayerCalculationMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  Setting({
    required this.id,
    required this.defaultCurrencyFormat,
    this.themeMode = 'light',
    this.localeCode = 'en',
    this.notificationsEnabled = false,
    this.focusMinutes = 25,
    this.breakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
    this.weeklyKindnessGoal = 14,
    this.prayerCalculationMethod = 'muslim_world_league',
    required this.createdAt,
    required this.updatedAt,
  });

  Setting copyWith({
    String? id,
    String? defaultCurrencyFormat,
    String? themeMode,
    String? localeCode,
    bool? notificationsEnabled,
    int? focusMinutes,
    int? breakMinutes,
    int? longBreakMinutes,
    int? sessionsBeforeLongBreak,
    int? weeklyKindnessGoal,
    String? prayerCalculationMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Setting(
      id: id ?? this.id,
      defaultCurrencyFormat:
          defaultCurrencyFormat ?? this.defaultCurrencyFormat,
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      weeklyKindnessGoal: weeklyKindnessGoal ?? this.weeklyKindnessGoal,
      prayerCalculationMethod:
          prayerCalculationMethod ?? this.prayerCalculationMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'defaultCurrencyFormat': defaultCurrencyFormat,
      'themeMode': themeMode,
      'localeCode': localeCode,
      'notificationsEnabled': notificationsEnabled,
      'focusMinutes': focusMinutes,
      'breakMinutes': breakMinutes,
      'longBreakMinutes': longBreakMinutes,
      'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
      'weeklyKindnessGoal': weeklyKindnessGoal,
      'prayerCalculationMethod': prayerCalculationMethod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['id'] as String,
      defaultCurrencyFormat: json['defaultCurrencyFormat'] as String,
      themeMode: json['themeMode'] as String? ?? 'light',
      localeCode: json['localeCode'] as String? ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      focusMinutes: json['focusMinutes'] as int? ?? 25,
      breakMinutes: json['breakMinutes'] as int? ?? 5,
      longBreakMinutes: json['longBreakMinutes'] as int? ?? 15,
      sessionsBeforeLongBreak: json['sessionsBeforeLongBreak'] as int? ?? 4,
      weeklyKindnessGoal: json['weeklyKindnessGoal'] as int? ?? 14,
      prayerCalculationMethod:
          json['prayerCalculationMethod'] as String? ?? 'muslim_world_league',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static Setting defaultSetting() {
    final now = DateTime.now();
    return Setting(
      id: 'setting_default',
      defaultCurrencyFormat: 'Rp',
      createdAt: now,
      updatedAt: now,
    );
  }
}
