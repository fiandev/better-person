class User {
  final String id;
  final String name;
  final String? avatarUrl;
  final int streak;
  final double dailyProgress; // 0.0–1.0
  final int totalHabitsDone;
  final double totalFocusHours;
  final int totalKindActs;
  final double growthScore; // 0.0–1.0
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.streak,
    required this.dailyProgress,
    required this.totalHabitsDone,
    required this.totalFocusHours,
    required this.totalKindActs,
    required this.growthScore,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    int? streak,
    double? dailyProgress,
    int? totalHabitsDone,
    double? totalFocusHours,
    int? totalKindActs,
    double? growthScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      streak: streak ?? this.streak,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      totalHabitsDone: totalHabitsDone ?? this.totalHabitsDone,
      totalFocusHours: totalFocusHours ?? this.totalFocusHours,
      totalKindActs: totalKindActs ?? this.totalKindActs,
      growthScore: growthScore ?? this.growthScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'streak': streak,
      'dailyProgress': dailyProgress,
      'totalHabitsDone': totalHabitsDone,
      'totalFocusHours': totalFocusHours,
      'totalKindActs': totalKindActs,
      'growthScore': growthScore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      streak: json['streak'] as int,
      dailyProgress: (json['dailyProgress'] as num).toDouble(),
      totalHabitsDone: json['totalHabitsDone'] as int,
      totalFocusHours: (json['totalFocusHours'] as num).toDouble(),
      totalKindActs: json['totalKindActs'] as int,
      growthScore: (json['growthScore'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
