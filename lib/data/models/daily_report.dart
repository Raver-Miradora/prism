/// Represents a daily journal entry, containing both informal "yap" notes
/// and the AI-synthesized formal report.
class DailyReport {
  final int? id;
  final String date;
  final String rawNotes;
  final String? formalReport;

  DailyReport({
    this.id,
    required this.date,
    required this.rawNotes,
    this.formalReport,
  });

  factory DailyReport.fromMap(Map<String, dynamic> map) {
    return DailyReport(
      id: map['id'] as int?,
      date: map['date'] as String,
      rawNotes: map['raw_notes'] as String,
      formalReport: map['formal_report'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'date': date,
      'raw_notes': rawNotes,
      'formal_report': formalReport,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  DailyReport copyWith({
    int? id,
    String? date,
    String? rawNotes,
    String? formalReport,
  }) {
    return DailyReport(
      id: id ?? this.id,
      date: date ?? this.date,
      rawNotes: rawNotes ?? this.rawNotes,
      formalReport: formalReport ?? this.formalReport,
    );
  }
}
