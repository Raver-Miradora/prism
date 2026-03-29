import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/intern_profile.dart';
import '../data/models/intern_settings.dart';
import '../data/repositories/intern_profile_repository.dart';
import '../core/database/database_helper.dart';
import 'settings_controller.dart';

/// Represents the state of the onboarding flow, including user profile details,
/// program selection, and transition progress.
class OnboardingState {
  final String name;
  final String office;
  final String? customOffice;
  final String supervisorName;
  final String programType; // OJT, SPES, Immersion, GIP
  final int targetHours;
  final int currentIndex;
  final double? officeLat;
  final double? officeLng;
  final bool hasReadTerms;
  final bool hasAdjustedHours;

  OnboardingState({
    this.name = '',
    this.office = 'LGU HRMO',
    this.customOffice,
    this.supervisorName = '',
    this.programType = 'OJT',
    this.targetHours = 486,
    this.currentIndex = 0,
    this.officeLat,
    this.officeLng,
    this.hasReadTerms = false,
    this.hasAdjustedHours = false,
  });

  OnboardingState copyWith({
    String? name,
    String? office,
    String? customOffice,
    String? supervisorName,
    String? programType,
    int? targetHours,
    int? currentIndex,
    double? officeLat,
    double? officeLng,
    bool? hasReadTerms,
    bool? hasAdjustedHours,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      office: office ?? this.office,
      customOffice: customOffice ?? this.customOffice,
      supervisorName: supervisorName ?? this.supervisorName,
      programType: programType ?? this.programType,
      targetHours: targetHours ?? this.targetHours,
      currentIndex: currentIndex ?? this.currentIndex,
      officeLat: officeLat ?? this.officeLat,
      officeLng: officeLng ?? this.officeLng,
      hasReadTerms: hasReadTerms ?? this.hasReadTerms,
      hasAdjustedHours: hasAdjustedHours ?? this.hasAdjustedHours,
    );
  }
}

/// Controller responsible for managing the onboarding process and persisting 
/// initial user configuration to the local registry.
class OnboardingController extends StateNotifier<OnboardingState> {
  final Ref _ref;
  final InternProfileRepository _profileRepo = InternProfileRepository();

  OnboardingController(this._ref) : super(OnboardingState());

  void updateName(String name) => state = state.copyWith(name: name);
  void updateOffice(String office) => state = state.copyWith(office: office, customOffice: office == 'Other' ? '' : null);
  void updateCustomOffice(String custom) => state = state.copyWith(customOffice: custom);
  void updateSupervisorName(String name) => state = state.copyWith(supervisorName: name);
  void updateTargetHours(int hours) => state = state.copyWith(targetHours: hours, hasAdjustedHours: true);
  void updateIndex(int index) => state = state.copyWith(currentIndex: index);
  void updateOfficeLocation(double lat, double lng) => state = state.copyWith(officeLat: lat, officeLng: lng);
  void setTermsRead(bool read) => state = state.copyWith(hasReadTerms: read);
  void markHoursAdjusted() => state = state.copyWith(hasAdjustedHours: true);

  void selectProgram(String type) {
    int hours = state.targetHours;
    if (type == 'SPES') hours = 160; 
    if (type == 'Immersion') hours = 80;
    if (type == 'GIP') hours = 660; // Default GIP
    if (type == 'OJT') hours = 486; 
    
    state = state.copyWith(
      programType: type, 
      targetHours: hours, 
      hasAdjustedHours: false, // Reset whenever program changes
    );
  }

  Future<void> completeOnboarding() async {
    // 1. Save Profile
    final profile = InternProfile(
      name: state.name,
      agencyOffice: state.office == 'Other' ? (state.customOffice ?? 'Other') : state.office,
      supervisorName: state.supervisorName.isEmpty ? 'TBD' : state.supervisorName,
    );
    await _profileRepo.saveProfile(profile);

    // 2. Save Settings
    final db = await DatabaseHelper.instance.database;
    
    // Shift logic
    String timeIn = '08:00';
    String timeOut = '17:00';
    if (state.programType == 'GIP') {
      timeIn = '07:00';
      timeOut = '18:00';
    }

    final settings = InternSettings(
      id: 1,
      targetHours: state.targetHours,
      expectedTimeIn: timeIn,
      expectedTimeOut: timeOut,
      lunchBreakMins: 60,
      officeLat: state.officeLat,
      officeLng: state.officeLng,
      programType: state.programType,
    );
    
    await db.update(
      'intern_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );

    // 3. Refresh the global settings provider
    await _ref.read(settingsProvider.notifier).loadSettings();
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController(ref);
});
