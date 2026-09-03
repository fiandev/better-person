class Setting {
  final String id;
  final String defaultCurrencyFormat;
  final DateTime createdAt;
  final DateTime updatedAt;

  Setting({
    required this.id,
    required this.defaultCurrencyFormat,
    required this.createdAt,
    required this.updatedAt,
  });

  Setting copyWith({
    String? id,
    String? defaultCurrencyFormat,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Setting(
      id: id ?? this.id,
      defaultCurrencyFormat: defaultCurrencyFormat ?? this.defaultCurrencyFormat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'defaultCurrencyFormat': defaultCurrencyFormat,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['id'] as String,
      defaultCurrencyFormat: json['defaultCurrencyFormat'] as String,
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
