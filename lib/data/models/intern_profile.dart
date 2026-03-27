class InternProfile {
  final String name;
  final String agencyOffice;
  final String supervisorName;

  InternProfile({
    required this.name,
    required this.agencyOffice,
    required this.supervisorName,
  });

  factory InternProfile.fromMap(Map<String, dynamic> map) {
    return InternProfile(
      name: map['name'] as String,
      agencyOffice: map['agency_office'] as String,
      supervisorName: map['supervisor_name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'agency_office': agencyOffice,
      'supervisor_name': supervisorName,
    };
  }

  InternProfile copyWith({
    String? name,
    String? agencyOffice,
    String? supervisorName,
  }) {
    return InternProfile(
      name: name ?? this.name,
      agencyOffice: agencyOffice ?? this.agencyOffice,
      supervisorName: supervisorName ?? this.supervisorName,
    );
  }
}
