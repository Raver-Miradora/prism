class TimeLog {
  final int? id;
  final String date;
  final String? timeIn;
  final String? timeLunchOut;
  final String? timeLunchIn;
  final String? timeOut;
  final double? latitudeIn;
  final double? longitudeIn;
  final double? latitudeOut;
  final double? longitudeOut;
  final String? photoPathIn;
  final String? photoPathOut;
  final int syncStatus;
  final bool isFieldwork;
  final String status; // WORK, ABSENT, EXCUSED
  final String? remarks;

  TimeLog({
    this.id,
    required this.date,
    this.timeIn,
    this.timeLunchOut,
    this.timeLunchIn,
    this.timeOut,
    this.latitudeIn,
    this.longitudeIn,
    this.latitudeOut,
    this.longitudeOut,
    this.photoPathIn,
    this.photoPathOut,
    this.syncStatus = 0,
    this.isFieldwork = false,
    this.status = 'WORK',
    this.remarks,
  });

  /// Factory constructor to create a [TimeLog] entirely from a Map (e.g., from SQLite)
  factory TimeLog.fromMap(Map<String, dynamic> map) {
    return TimeLog(
      id: map['id'] as int?,
      date: map['date'] as String,
      timeIn: map['time_in'] as String?,
      timeLunchOut: map['time_lunch_out'] as String?,
      timeLunchIn: map['time_lunch_in'] as String?,
      timeOut: map['time_out'] as String?,
      latitudeIn: map['latitude_in'] as double?,
      longitudeIn: map['longitude_in'] as double?,
      latitudeOut: map['latitude_out'] as double?,
      longitudeOut: map['longitude_out'] as double?,
      photoPathIn: map['photo_path_in'] as String?,
      photoPathOut: map['photo_path_out'] as String?,
      syncStatus: map['sync_status'] as int,
      isFieldwork: (map['is_fieldwork'] as int?) == 1,
      status: map['status'] as String? ?? 'WORK',
      remarks: map['remarks'] as String?,
    );
  }

  /// Converts the [TimeLog] into a Map that can be inserted into SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'time_in': timeIn,
      'time_lunch_out': timeLunchOut,
      'time_lunch_in': timeLunchIn,
      'time_out': timeOut,
      'latitude_in': latitudeIn,
      'longitude_in': longitudeIn,
      'latitude_out': latitudeOut,
      'longitude_out': longitudeOut,
      'photo_path_in': photoPathIn,
      'photo_path_out': photoPathOut,
      'sync_status': syncStatus,
      'is_fieldwork': isFieldwork ? 1 : 0,
      'status': status,
      'remarks': remarks,
    };
  }

  /// Create a copy of [TimeLog] varying specific fields (useful when clocking out)
  TimeLog copyWith({
    int? id,
    String? date,
    String? timeIn,
    String? timeLunchOut,
    String? timeLunchIn,
    String? timeOut,
    double? latitudeIn,
    double? longitudeIn,
    double? latitudeOut,
    double? longitudeOut,
    String? photoPathIn,
    String? photoPathOut,
    int? syncStatus,
    bool? isFieldwork,
    String? status,
    String? remarks,
  }) {
    return TimeLog(
      id: id ?? this.id,
      date: date ?? this.date,
      timeIn: timeIn ?? this.timeIn,
      timeLunchOut: timeLunchOut ?? this.timeLunchOut,
      timeLunchIn: timeLunchIn ?? this.timeLunchIn,
      timeOut: timeOut ?? this.timeOut,
      latitudeIn: latitudeIn ?? this.latitudeIn,
      longitudeIn: longitudeIn ?? this.longitudeIn,
      latitudeOut: latitudeOut ?? this.latitudeOut,
      longitudeOut: longitudeOut ?? this.longitudeOut,
      photoPathIn: photoPathIn ?? this.photoPathIn,
      photoPathOut: photoPathOut ?? this.photoPathOut,
      syncStatus: syncStatus ?? this.syncStatus,
      isFieldwork: isFieldwork ?? this.isFieldwork,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
    );
  }
}
