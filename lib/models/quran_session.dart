class QuranSession {
  final String id;
  final String currentSurah; // e.g., "Al-Mulk"
  final int currentSurahNumber;
  final int dailyPageGoal; // e.g., 2 pages
  final int pagesReadToday;
  final String instruction; // display text for the session card
  final bool isCompleted;
  final DateTime date;
  final DateTime? completedAt;

  QuranSession({
    required this.id,
    required this.currentSurah,
    required this.currentSurahNumber,
    required this.dailyPageGoal,
    required this.pagesReadToday,
    required this.instruction,
    required this.isCompleted,
    required this.date,
    this.completedAt,
  });

  double get progress =>
      dailyPageGoal > 0
          ? (pagesReadToday / dailyPageGoal).clamp(0.0, 1.0)
          : 0.0;

  QuranSession copyWith({
    String? id,
    String? currentSurah,
    int? currentSurahNumber,
    int? dailyPageGoal,
    int? pagesReadToday,
    String? instruction,
    bool? isCompleted,
    DateTime? date,
    DateTime? completedAt,
  }) {
    return QuranSession(
      id: id ?? this.id,
      currentSurah: currentSurah ?? this.currentSurah,
      currentSurahNumber: currentSurahNumber ?? this.currentSurahNumber,
      dailyPageGoal: dailyPageGoal ?? this.dailyPageGoal,
      pagesReadToday: pagesReadToday ?? this.pagesReadToday,
      instruction: instruction ?? this.instruction,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentSurah': currentSurah,
      'currentSurahNumber': currentSurahNumber,
      'dailyPageGoal': dailyPageGoal,
      'pagesReadToday': pagesReadToday,
      'instruction': instruction,
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory QuranSession.fromJson(Map<String, dynamic> json) {
    return QuranSession(
      id: json['id'] as String,
      currentSurah: json['currentSurah'] as String,
      currentSurahNumber: json['currentSurahNumber'] as int,
      dailyPageGoal: json['dailyPageGoal'] as int,
      pagesReadToday: json['pagesReadToday'] as int,
      instruction: json['instruction'] as String,
      isCompleted: json['isCompleted'] as bool,
      date: DateTime.parse(json['date'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
