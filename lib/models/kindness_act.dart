class KindnessAct {
  final String id;
  final String label; // e.g., "Gave a compliment", "Helped a colleague"
  final bool isSelected; // whether user selected this act today
  final int sortOrder;

  KindnessAct({
    required this.id,
    required this.label,
    required this.isSelected,
    required this.sortOrder,
  });

  KindnessAct copyWith({
    String? id,
    String? label,
    bool? isSelected,
    int? sortOrder,
  }) {
    return KindnessAct(
      id: id ?? this.id,
      label: label ?? this.label,
      isSelected: isSelected ?? this.isSelected,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'isSelected': isSelected,
      'sortOrder': sortOrder,
    };
  }

  factory KindnessAct.fromJson(Map<String, dynamic> json) {
    return KindnessAct(
      id: json['id'] as String,
      label: json['label'] as String,
      isSelected: json['isSelected'] as bool,
      sortOrder: json['sortOrder'] as int,
    );
  }

  /// Default predefined kindness ideas that appear as chips on the Kindness screen.
  static List<KindnessAct> get defaultIdeas => [
        KindnessAct(id: 'k1', label: 'Gave a compliment', isSelected: false, sortOrder: 0),
        KindnessAct(id: 'k2', label: 'Helped a colleague', isSelected: false, sortOrder: 1),
        KindnessAct(id: 'k3', label: 'Held the door open', isSelected: false, sortOrder: 2),
        KindnessAct(id: 'k4', label: 'Listened actively', isSelected: false, sortOrder: 3),
        KindnessAct(id: 'k5', label: 'Donated to charity', isSelected: false, sortOrder: 4),
        KindnessAct(id: 'k6', label: 'Sent a thoughtful message', isSelected: false, sortOrder: 5),
      ];
}
