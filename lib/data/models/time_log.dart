class TimeLog {
  final int? id;
  final String date;
  final String timeIn;
  final String? timeOut;
  final double latitudeIn;
  final double longitudeIn;
  final double? latitudeOut;
  final double? longitudeOut;
  final String photoPathIn;
  final String? photoPathOut;
  final int syncStatus;

  TimeLog({
    this.id,
    required this.date,
    required this.timeIn,
    this.timeOut,
    required this.latitudeIn,
    required this.longitudeIn,
    this.latitudeOut,
    this.longitudeOut,
    required this.photoPathIn,
    this.photoPathOut,
    this.syncStatus = 0,
  });

  /// Factory constructor to create a [TimeLog] entirely from a Map (e.g., from SQLite)
  factory TimeLog.fromMap(Map<String, dynamic> map) {
    return TimeLog(
      id: map['id'] as int?,
      date: map['date'] as String,
      timeIn: map['time_in'] as String,
      timeOut: map['time_out'] as String?,
      latitudeIn: map['latitude_in'] as double,
      longitudeIn: map['longitude_in'] as double,
      latitudeOut: map['latitude_out'] as double?,
      longitudeOut: map['longitude_out'] as double?,
      photoPathIn: map['photo_path_in'] as String,
      photoPathOut: map['photo_path_out'] as String?,
      syncStatus: map['sync_status'] as int,
    );
  }

  /// Converts the [TimeLog] into a Map that can be inserted into SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'time_in': timeIn,
      'time_out': timeOut,
      'latitude_in': latitudeIn,
      'longitude_in': longitudeIn,
      'latitude_out': latitudeOut,
      'longitude_out': longitudeOut,
      'photo_path_in': photoPathIn,
      'photo_path_out': photoPathOut,
      'sync_status': syncStatus,
    };
  }

  /// Create a copy of [TimeLog] varying specific fields (useful when clocking out)
  TimeLog copyWith({
    int? id,
    String? date,
    String? timeIn,
    String? timeOut,
    double? latitudeIn,
    double? longitudeIn,
    double? latitudeOut,
    double? longitudeOut,
    String? photoPathIn,
    String? photoPathOut,
    int? syncStatus,
  }) {
    return TimeLog(
      id: id ?? this.id,
      date: date ?? this.date,
      timeIn: timeIn ?? this.timeIn,
      timeOut: timeOut ?? this.timeOut,
      latitudeIn: latitudeIn ?? this.latitudeIn,
      longitudeIn: longitudeIn ?? this.longitudeIn,
      latitudeOut: latitudeOut ?? this.latitudeOut,
      longitudeOut: longitudeOut ?? this.longitudeOut,
      photoPathIn: photoPathIn ?? this.photoPathIn,
      photoPathOut: photoPathOut ?? this.photoPathOut,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
