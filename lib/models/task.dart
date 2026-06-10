enum TaskPriority {
  high,
  medium,
  low,
}

class Task {
  final String id;
  final String title; // e.g., "Draft Q3 Financial Overview Presentation"
  final List<String> tags; // e.g., ["Deep Work", "High Priority"]
  final TaskPriority priority;
  final bool isCompleted;
  final int sortOrder; // for drag-and-drop reordering in "Up Next" list
  final DateTime createdAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.tags,
    required this.priority,
    required this.isCompleted,
    required this.sortOrder,
    required this.createdAt,
    this.completedAt,
  });

  String getPriorityLabel() {
    switch (priority) {
      case TaskPriority.high:
        return 'High Priority';
      case TaskPriority.medium:
        return 'Medium Priority';
      case TaskPriority.low:
        return 'Low Priority';
    }
  }

  Task copyWith({
    String? id,
    String? title,
    List<String>? tags,
    TaskPriority? priority,
    bool? isCompleted,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tags': tags,
      'priority': priority.name,
      'isCompleted': isCompleted,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      tags: List<String>.from(json['tags'] as List),
      priority: TaskPriority.values.firstWhere((e) => e.name == json['priority']),
      isCompleted: json['isCompleted'] as bool,
      sortOrder: json['sortOrder'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
