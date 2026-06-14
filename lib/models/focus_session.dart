enum TimerState {
  idle,
  focusing,
  onBreak,
}

class FocusSession {
  final String id;
  final String category; // e.g., "Work Focus"
  final String name; // e.g., "Deep Work Session"
  final Duration timerDuration; // total session duration (e.g., 25 minutes)
  final Duration elapsed; // time elapsed so far
  final TimerState timerState;
  final String? currentTaskId; // reference to the active Task
  final List<String> upNextTaskIds; // ordered list of upcoming Task IDs
  final DateTime createdAt;
  final DateTime? completedAt;

  FocusSession({
    required this.id,
    required this.category,
    required this.name,
    required this.timerDuration,
    required this.elapsed,
    required this.timerState,
    this.currentTaskId,
    required this.upNextTaskIds,
    required this.createdAt,
    this.completedAt,
  });

  /// 0.0–1.0 progress through the timer.
  double get progress =>
      timerDuration.inSeconds > 0
          ? (elapsed.inSeconds / timerDuration.inSeconds).clamp(0.0, 1.0)
          : 0.0;

  /// Remaining time in the timer.
  Duration get remaining {
    final rem = timerDuration - elapsed;
    return rem.isNegative ? Duration.zero : rem;
  }

  /// Human-readable remaining time as "MM:SS".
  String get timerDisplay {
    final r = remaining;
    final minutes = r.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = r.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get timerStateLabel {
    switch (timerState) {
      case TimerState.idle:
        if (timerDuration.inMinutes == 5) return 'Ready for Break';
        return 'Ready to Focus';
      case TimerState.focusing:
        return 'Focusing';
      case TimerState.onBreak:
        return 'On Break';
    }
  }

  FocusSession copyWith({
    String? id,
    String? category,
    String? name,
    Duration? timerDuration,
    Duration? elapsed,
    TimerState? timerState,
    String? currentTaskId,
    List<String>? upNextTaskIds,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return FocusSession(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      timerDuration: timerDuration ?? this.timerDuration,
      elapsed: elapsed ?? this.elapsed,
      timerState: timerState ?? this.timerState,
      currentTaskId: currentTaskId ?? this.currentTaskId,
      upNextTaskIds: upNextTaskIds ?? this.upNextTaskIds,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'timerDurationSeconds': timerDuration.inSeconds,
      'elapsedSeconds': elapsed.inSeconds,
      'timerState': timerState.name,
      'currentTaskId': currentTaskId,
      'upNextTaskIds': upNextTaskIds,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] as String,
      category: json['category'] as String,
      name: json['name'] as String,
      timerDuration: Duration(seconds: json['timerDurationSeconds'] as int),
      elapsed: Duration(seconds: json['elapsedSeconds'] as int),
      timerState: TimerState.values.firstWhere(
        (e) => e.name == json['timerState'],
      ),
      currentTaskId: json['currentTaskId'] as String?,
      upNextTaskIds: List<String>.from(json['upNextTaskIds'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
