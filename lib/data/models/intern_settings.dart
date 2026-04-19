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
  final String schoolName;
  final String courseProgram;

  InternSettings({
    this.id = 1, // Singleton row
    required this.targetHours,
    required this.expectedTimeIn,
    required this.expectedTimeOut,
    required this.lunchBreakMins,
    this.officeLat,
    this.officeLng,
    this.programType = 'OJT',
    this.schoolName = '',
    this.courseProgram = '',
  });

  factory InternSettings.fromMap(Map<String, dynamic> map) {
    return InternSettings(
      id: (map['id'] as num?)?.toInt() ?? 1,
      targetHours: (map['target_hours'] as num?)?.toInt() ?? 486,
      expectedTimeIn: map['expected_time_in'] as String? ?? '08:00',
      expectedTimeOut: map['expected_time_out'] as String? ?? '17:00',
      lunchBreakMins: (map['lunch_break_mins'] as num?)?.toInt() ?? 60,
      officeLat: (map['office_lat'] as num?)?.toDouble(),
      officeLng: (map['office_lng'] as num?)?.toDouble(),
      programType: map['program_type'] as String? ?? 'OJT',
      schoolName: map['school_name'] as String? ?? '',
      courseProgram: map['course_program'] as String? ?? '',
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
      'school_name': schoolName,
      'course_program': courseProgram,
    };
  }

  InternSettings copyWith({
    int? targetHours,
    String? expectedTimeIn,
    String? expectedTimeOut,
    int? lunchBreakMins,
    Object? officeLat = _sentinel,  // use sentinel to distinguish null-clear vs not provided
    Object? officeLng = _sentinel,
    String? programType,
    String? schoolName,
    String? courseProgram,
  }) {
    return InternSettings(
      id: id,
      targetHours: targetHours ?? this.targetHours,
      expectedTimeIn: expectedTimeIn ?? this.expectedTimeIn,
      expectedTimeOut: expectedTimeOut ?? this.expectedTimeOut,
      lunchBreakMins: lunchBreakMins ?? this.lunchBreakMins,
      officeLat: officeLat == _sentinel ? this.officeLat : officeLat as double?,
      officeLng: officeLng == _sentinel ? this.officeLng : officeLng as double?,
      programType: programType ?? this.programType,
      schoolName: schoolName ?? this.schoolName,
      courseProgram: courseProgram ?? this.courseProgram,
    );
  }
}

// Private sentinel for nullable copyWith disambiguation
const Object _sentinel = Object();
