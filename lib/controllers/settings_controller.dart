import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/intern_profile.dart';
import '../data/models/intern_settings.dart';
import '../data/repositories/intern_profile_repository.dart';
import '../core/database/database_helper.dart';

class SettingsState {
  final InternProfile? profile;
  final InternSettings? settings;
  final bool isLoading;

  SettingsState({this.profile, this.settings, this.isLoading = true});

  SettingsState copyWith({InternProfile? profile, InternSettings? settings, bool? isLoading}) {
    return SettingsState(
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  final InternProfileRepository _profileRepo = InternProfileRepository();

  SettingsController() : super(SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true);
    final profile = await _profileRepo.getProfile();
    final db = await DatabaseHelper.instance.database;
    final map = await db.query('intern_settings', limit: 1);
    final settings = map.isNotEmpty ? InternSettings.fromMap(map.first) : null;
    state = SettingsState(profile: profile, settings: settings, isLoading: false);
  }

  Future<void> refreshOnly() async {
    final profile = await _profileRepo.getProfile();
    state = state.copyWith(profile: profile);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && state.profile != null) {
      final updatedProfile = state.profile!.copyWith(profileImagePath: image.path);
      await _profileRepo.saveProfile(updatedProfile);
      state = state.copyWith(profile: updatedProfile);
    }
  }

  Future<void> saveSettings({
    required String name,
    required String agency,
    required String supervisor,
    required int targetHours,
    required String timeIn,
  }) async {
    state = state.copyWith(isLoading: true);
    final updatedProfile = InternProfile(
      name: name,
      agencyOffice: agency,
      supervisorName: supervisor,
      profileImagePath: state.profile?.profileImagePath,
    );
    await _profileRepo.saveProfile(updatedProfile);

    final db = await DatabaseHelper.instance.database;
    final updatedSettings = InternSettings(
      id: 1,
      targetHours: targetHours,
      expectedTimeIn: timeIn,
      expectedTimeOut: state.settings?.expectedTimeOut ?? '17:00',
      lunchBreakMins: state.settings?.lunchBreakMins ?? 60,
    );
    
    await db.update(
      'intern_settings',
      updatedSettings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );

    state = SettingsState(profile: updatedProfile, settings: updatedSettings, isLoading: false);
  }
}

final settingsProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) => SettingsController());
