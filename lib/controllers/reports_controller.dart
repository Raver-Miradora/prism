import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_helper.dart';
import '../data/models/intern_profile.dart';
import '../data/models/intern_settings.dart';
import '../data/models/time_log.dart';
import '../data/repositories/time_log_repository.dart';
import '../data/repositories/intern_profile_repository.dart';
import '../services/pdf_service.dart';

class ReportsState {
  final int selectedYear;
  final int selectedMonth;
  final AsyncValue<List<TimeLog>> logsStatus;
  final AsyncValue<InternProfile> profileStatus;
  final AsyncValue<InternSettings> settingsStatus;
  final bool isGeneratingPdf;
  
  ReportsState({
    required this.selectedYear,
    required this.selectedMonth,
    required this.logsStatus,
    required this.profileStatus,
    required this.settingsStatus,
    this.isGeneratingPdf = false,
  });

  ReportsState copyWith({
    int? selectedYear,
    int? selectedMonth,
    AsyncValue<List<TimeLog>>? logsStatus,
    AsyncValue<InternProfile>? profileStatus,
    AsyncValue<InternSettings>? settingsStatus,
    bool? isGeneratingPdf,
  }) {
    return ReportsState(
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      logsStatus: logsStatus ?? this.logsStatus,
      profileStatus: profileStatus ?? this.profileStatus,
      settingsStatus: settingsStatus ?? this.settingsStatus,
      isGeneratingPdf: isGeneratingPdf ?? this.isGeneratingPdf,
    );
  }
}

class ReportsController extends StateNotifier<ReportsState> {
  final TimeLogRepository _logRepo = TimeLogRepository();
  final InternProfileRepository _profileRepo = InternProfileRepository();

  ReportsController() : super(ReportsState(
    selectedYear: DateTime.now().year,
    selectedMonth: DateTime.now().month,
    logsStatus: const AsyncValue.loading(),
    profileStatus: const AsyncValue.loading(),
    settingsStatus: const AsyncValue.loading(),
  )) {
    loadData(state.selectedYear, state.selectedMonth);
  }

  Future<void> loadData(int year, int month) async {
    state = state.copyWith(selectedYear: year, selectedMonth: month, logsStatus: const AsyncValue.loading());
    try {
      final logs = await _logRepo.getLogsForMonth(year, month);
      final profile = await _profileRepo.getProfile();
      
      final db = await DatabaseHelper.instance.database;
      final settingsList = await db.query('intern_settings', limit: 1);
      final settings = settingsList.isNotEmpty 
        ? InternSettings.fromMap(settingsList.first)
        : InternSettings(id: 1, targetHours: 486, expectedTimeIn: '08:00', expectedTimeOut: '17:00', lunchBreakMins: 60);

      state = state.copyWith(
        logsStatus: AsyncValue.data(logs),
        profileStatus: AsyncValue.data(profile),
        settingsStatus: AsyncValue.data(settings),
      );
    } catch (e, st) {
      state = state.copyWith(logsStatus: AsyncValue.error(e, st));
    }
  }

  Future<void> changeMonth(int offset) async {
    var d = DateTime(state.selectedYear, state.selectedMonth + offset, 1);
    await loadData(d.year, d.month);
  }

  Future<void> generatePDF() async {
    final logs = state.logsStatus.valueOrNull ?? [];
    final profile = state.profileStatus.valueOrNull;
    final settings = state.settingsStatus.valueOrNull;
    if (profile == null || settings == null) return;
    
    state = state.copyWith(isGeneratingPdf: true);
    try {
      await PdfService.generateAndPrintForm48(logs, profile, settings, state.selectedYear, state.selectedMonth);
    } finally {
      state = state.copyWith(isGeneratingPdf: false);
    }
  }
}

final reportsControllerProvider = StateNotifierProvider<ReportsController, ReportsState>(
  (ref) => ReportsController(),
);
