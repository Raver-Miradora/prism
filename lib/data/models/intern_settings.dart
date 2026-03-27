class InternSettings {
  final int id;
  final int targetHours;
  final String expectedTimeIn;
  final String expectedTimeOut;
  final int lunchBreakMins;

  InternSettings({
    this.id = 1, // Singleton row
    required this.targetHours,
    required this.expectedTimeIn,
    required this.expectedTimeOut,
    required this.lunchBreakMins,
  });

  factory InternSettings.fromMap(Map<String, dynamic> map) {
    return InternSettings(
      id: map['id'] as int? ?? 1,
      targetHours: map['target_hours'] as int,
      expectedTimeIn: map['expected_time_in'] as String,
      expectedTimeOut: map['expected_time_out'] as String,
      lunchBreakMins: map['lunch_break_mins'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'target_hours': targetHours,
      'expected_time_in': expectedTimeIn,
      'expected_time_out': expectedTimeOut,
      'lunch_break_mins': lunchBreakMins,
    };
  }

  InternSettings copyWith({
    int? targetHours,
    String? expectedTimeIn,
    String? expectedTimeOut,
    int? lunchBreakMins,
  }) {
    return InternSettings(
      id: id,
      targetHours: targetHours ?? this.targetHours,
      expectedTimeIn: expectedTimeIn ?? this.expectedTimeIn,
      expectedTimeOut: expectedTimeOut ?? this.expectedTimeOut,
      lunchBreakMins: lunchBreakMins ?? this.lunchBreakMins,
    );
  }
}
