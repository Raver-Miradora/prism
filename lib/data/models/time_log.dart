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
  });

  factory TimeLog.fromMap(Map<String, dynamic> map) {
    return TimeLog(
      id: (map['id'] as num?)?.toInt(),
      date: (map['date'] as String?) ?? '',
      amArrivalTime: map['am_arrival_time'] as String?,
      pmDepartureTime: map['pm_departure_time'] as String?,
      latAmArrival: (map['lat_am_arrival'] as num?)?.toDouble(),
      lngAmArrival: (map['lng_am_arrival'] as num?)?.toDouble(),
      amArrivalPhotoPath: map['am_arrival_photo_path'] as String?,
      isManualAmArrival: (map['is_manual_am_arrival'] as num?)?.toInt() == 1,
      latPmDeparture: (map['lat_pm_departure'] as num?)?.toDouble(),
      lngPmDeparture: (map['lng_pm_departure'] as num?)?.toDouble(),
      pmDeparturePhotoPath: map['pm_departure_photo_path'] as String?,
      isManualPmDeparture: (map['is_manual_pm_departure'] as num?)?.toInt() == 1,
      syncStatus: (map['sync_status'] as num?)?.toInt() ?? 0,
      isFieldwork: (map['is_fieldwork'] as num?)?.toInt() == 1,
      fieldworkLocation: map['fieldwork_location'] as String?,
      fieldworkPurpose: map['fieldwork_purpose'] as String?,
      status: (map['status'] as String?) ?? 'WORK',
      recordStatus: (map['record_status'] as String?) ?? 'PRESENT',
      remarks: map['remarks'] as String?,
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
    );
  }
}
