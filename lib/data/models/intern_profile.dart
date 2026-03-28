class InternProfile {
  final String name;
  final String agencyOffice;
  final String supervisorName;
  final String? profileImagePath;

  InternProfile({
    required this.name,
    required this.agencyOffice,
    required this.supervisorName,
    this.profileImagePath,
  });

  factory InternProfile.fromMap(Map<String, dynamic> map) {
    return InternProfile(
      name: map['name'] as String,
      agencyOffice: map['agency_office'] as String,
      supervisorName: map['supervisor_name'] as String,
      profileImagePath: map['profile_image_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'agency_office': agencyOffice,
      'supervisor_name': supervisorName,
      'profile_image_path': profileImagePath,
    };
  }

  InternProfile copyWith({
    String? name,
    String? agencyOffice,
    String? supervisorName,
    String? profileImagePath,
  }) {
    return InternProfile(
      name: name ?? this.name,
      agencyOffice: agencyOffice ?? this.agencyOffice,
      supervisorName: supervisorName ?? this.supervisorName,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
