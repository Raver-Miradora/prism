/// Represents the system-wide configuration for an intern, including work
/// schedule, target hour quota, and program classification.
class InternSettings {
  final int id;
  final int targetHours;
  final String expectedTimeIn;
  final String expectedTimeOut;
  final int lunchBreakMins;
  final double? officeLat;
  final double? officeLng;
  final String programType; // OJT, SPES, Immersion, GIP

  InternSettings({
    this.id = 1, // Singleton row
    required this.targetHours,
    required this.expectedTimeIn,
    required this.expectedTimeOut,
    required this.lunchBreakMins,
    this.officeLat,
    this.officeLng,
    this.programType = 'OJT',
  });

  factory InternSettings.fromMap(Map<String, dynamic> map) {
    return InternSettings(
      id: map['id'] as int? ?? 1,
      targetHours: map['target_hours'] as int,
      expectedTimeIn: map['expected_time_in'] as String? ?? '08:00',
      expectedTimeOut: map['expected_time_out'] as String? ?? '17:00',
      lunchBreakMins: map['lunch_break_mins'] as int? ?? 60,
      officeLat: map['office_lat'] as double?,
      officeLng: map['office_lng'] as double?,
      programType: map['program_type'] as String? ?? 'OJT',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'target_hours': targetHours,
      'expected_time_in': expectedTimeIn,
      'expected_time_out': expectedTimeOut,
      'lunch_break_mins': lunchBreakMins,
      'office_lat': officeLat,
      'office_lng': officeLng,
      'program_type': programType,
    };
  }

  InternSettings copyWith({
    int? targetHours,
    String? expectedTimeIn,
    String? expectedTimeOut,
    int? lunchBreakMins,
    double? officeLat,
    double? officeLng,
    String? programType,
  }) {
    return InternSettings(
      id: id,
      targetHours: targetHours ?? this.targetHours,
      expectedTimeIn: expectedTimeIn ?? this.expectedTimeIn,
      expectedTimeOut: expectedTimeOut ?? this.expectedTimeOut,
      lunchBreakMins: lunchBreakMins ?? this.lunchBreakMins,
      officeLat: officeLat ?? this.officeLat,
      officeLng: officeLng ?? this.officeLng,
      programType: programType ?? this.programType,
    );
  }
}
