class TimeLog {
  final int? id;
  final String date;
  
  // 2-Step Attendance Slots
  final String? amArrivalTime;
  final String? pmDepartureTime;
  
  // Metadata for AM Arrival
  final double? latAmArrival;
  final double? lngAmArrival;
  final String? amArrivalPhotoPath;
  final bool isManualAmArrival;
  
  // Metadata for PM Departure
  final double? latPmDeparture;
  final double? lngPmDeparture;
  final String? pmDeparturePhotoPath;
  final bool isManualPmDeparture;

  final int syncStatus;
  final bool isFieldwork;
  final String? fieldworkLocation;
  final String? fieldworkPurpose;
  final String status;         // WORK, ABSENT, EXCUSED, HOLIDAY_*
  final String recordStatus;   // PRESENT, ABSENT, LEAVE, HOLIDAY
  final String? remarks;
  final bool hasMissedPunch;
  final bool isGeofenceBypassed;

  TimeLog({
    this.id,
    required this.date,
    this.amArrivalTime,
    this.pmDepartureTime,
    this.latAmArrival,
    this.lngAmArrival,
    this.amArrivalPhotoPath,
    this.isManualAmArrival = false,
    this.latPmDeparture,
    this.lngPmDeparture,
    this.pmDeparturePhotoPath,
    this.isManualPmDeparture = false,
    this.syncStatus = 0,
    this.isFieldwork = false,
    this.fieldworkLocation,
    this.fieldworkPurpose,
    this.status = 'WORK',
    this.recordStatus = 'PRESENT',
    this.remarks,
    this.hasMissedPunch = false,
    this.isGeofenceBypassed = false,
  });

  factory TimeLog.fromMap(Map<String, dynamic> map) {
    // ── Safe boolean helper: handles null, int (0/1), and bool literals
    // from different SQLite driver versions. Defaults to false on null.
    bool safeBool(dynamic v) => v == 1 || v == true;

    // ── Safe date: never allow an empty string downstream; use a sentinel
    // value that callers can check for rather than crashing on DateTime.parse.
    final rawDate = map['date'];
    final date = (rawDate is String && rawDate.isNotEmpty)
        ? rawDate
        : '1970-01-01'; // Sentinel — avoids DateTime.parse crash.

    return TimeLog(
      id: (map['id'] as num?)?.toInt(),
      date: date,
      amArrivalTime: map['am_arrival_time'] as String?,
      pmDepartureTime: map['pm_departure_time'] as String?,
      latAmArrival: (map['lat_am_arrival'] as num?)?.toDouble(),
      lngAmArrival: (map['lng_am_arrival'] as num?)?.toDouble(),
      amArrivalPhotoPath: map['am_arrival_photo_path'] as String?,
      isManualAmArrival: safeBool(map['is_manual_am_arrival']),
      latPmDeparture: (map['lat_pm_departure'] as num?)?.toDouble(),
      lngPmDeparture: (map['lng_pm_departure'] as num?)?.toDouble(),
      pmDeparturePhotoPath: map['pm_departure_photo_path'] as String?,
      isManualPmDeparture: safeBool(map['is_manual_pm_departure']),
      syncStatus: (map['sync_status'] as num?)?.toInt() ?? 0,
      isFieldwork: safeBool(map['is_fieldwork']),
      fieldworkLocation: map['fieldwork_location'] as String?,
      fieldworkPurpose: map['fieldwork_purpose'] as String?,
      status: (map['status'] as String?) ?? 'WORK',
      recordStatus: (map['record_status'] as String?) ?? 'PRESENT',
      remarks: map['remarks'] as String?,
      hasMissedPunch: safeBool(map['has_missed_punch']),
      isGeofenceBypassed: safeBool(map['is_geofence_bypassed']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'am_arrival_time': amArrivalTime,
      'pm_departure_time': pmDepartureTime,
      'lat_am_arrival': latAmArrival,
      'lng_am_arrival': lngAmArrival,
      'am_arrival_photo_path': amArrivalPhotoPath,
      'is_manual_am_arrival': isManualAmArrival ? 1 : 0,
      'lat_pm_departure': latPmDeparture,
      'lng_pm_departure': lngPmDeparture,
      'pm_departure_photo_path': pmDeparturePhotoPath,
      'is_manual_pm_departure': isManualPmDeparture ? 1 : 0,
      'sync_status': syncStatus,
      'is_fieldwork': isFieldwork ? 1 : 0,
      'fieldwork_location': fieldworkLocation,
      'fieldwork_purpose': fieldworkPurpose,
      'status': status,
      'record_status': recordStatus,
      'remarks': remarks,
      'has_missed_punch': hasMissedPunch ? 1 : 0,
      'is_geofence_bypassed': isGeofenceBypassed ? 1 : 0,
    };
  }

  TimeLog copyWith({
    int? id,
    String? date,
    String? amArrivalTime,
    String? pmDepartureTime,
    double? latAmArrival,
    double? lngAmArrival,
    String? amArrivalPhotoPath,
    bool? isManualAmArrival,
    double? latPmDeparture,
    double? lngPmDeparture,
    String? pmDeparturePhotoPath,
    bool? isManualPmDeparture,
    int? syncStatus,
    bool? isFieldwork,
    String? fieldworkLocation,
    String? fieldworkPurpose,
    String? status,
    String? recordStatus,
    String? remarks,
    bool? hasMissedPunch,
    bool? isGeofenceBypassed,
  }) {
    return TimeLog(
      id: id ?? this.id,
      date: date ?? this.date,
      amArrivalTime: amArrivalTime ?? this.amArrivalTime,
      pmDepartureTime: pmDepartureTime ?? this.pmDepartureTime,
      latAmArrival: latAmArrival ?? this.latAmArrival,
      lngAmArrival: lngAmArrival ?? this.lngAmArrival,
      amArrivalPhotoPath: amArrivalPhotoPath ?? this.amArrivalPhotoPath,
      isManualAmArrival: isManualAmArrival ?? this.isManualAmArrival,
      latPmDeparture: latPmDeparture ?? this.latPmDeparture,
      lngPmDeparture: lngPmDeparture ?? this.lngPmDeparture,
      pmDeparturePhotoPath: pmDeparturePhotoPath ?? this.pmDeparturePhotoPath,
      isManualPmDeparture: isManualPmDeparture ?? this.isManualPmDeparture,
      syncStatus: syncStatus ?? this.syncStatus,
      isFieldwork: isFieldwork ?? this.isFieldwork,
      fieldworkLocation: fieldworkLocation ?? this.fieldworkLocation,
      fieldworkPurpose: fieldworkPurpose ?? this.fieldworkPurpose,
      status: status ?? this.status,
      recordStatus: recordStatus ?? this.recordStatus,
      remarks: remarks ?? this.remarks,
      hasMissedPunch: hasMissedPunch ?? this.hasMissedPunch,
      isGeofenceBypassed: isGeofenceBypassed ?? this.isGeofenceBypassed,
    );
  }
}
