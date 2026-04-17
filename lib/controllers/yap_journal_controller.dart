import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/models/daily_report.dart';
import '../data/repositories/daily_report_repository.dart';
import '../services/ai_report_service.dart';

class YapJournalState {
  final DateTime selectedDate;
  final AsyncValue<DailyReport?> reportStatus;
  
  YapJournalState({
    required this.selectedDate, 
    required this.reportStatus
  });
  
  YapJournalState copyWith({
    DateTime? selectedDate,
    AsyncValue<DailyReport?>? reportStatus,
  }) {
    return YapJournalState(
      selectedDate: selectedDate ?? this.selectedDate,
      reportStatus: reportStatus ?? this.reportStatus,
    );
  }
}

class YapJournalController extends StateNotifier<YapJournalState> {
  final DailyReportRepository _repo = DailyReportRepository();
  final AiReportService _aiService = AiReportService();

  YapJournalController()
      : super(YapJournalState(
            selectedDate: DateTime.now().toUtc().add(const Duration(hours: 8)),
            reportStatus: const AsyncValue.loading())) {
    _loadReportForDate(state.selectedDate);
  }

  /// Change the actively viewed journal date
  void changeDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date, 
      reportStatus: const AsyncValue.loading()
    );
    _loadReportForDate(date);
  }

  /// Fetch from SQLite mapping to the target date
  Future<void> _loadReportForDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    try {
      final report = await _repo.getReportByDate(dateStr);
      state = state.copyWith(reportStatus: AsyncValue.data(report));
    } catch (err, stack) {
      state = state.copyWith(reportStatus: AsyncValue.error(err, stack));
    }
  }

  /// Silently update the raw notes into SQLite for draft saving
  Future<void> saveRawNotes(String rawNotes) async {
    final currentReport = state.reportStatus.valueOrNull;
    final dateStr = DateFormat('yyyy-MM-dd').format(state.selectedDate);
    
    // Prevent overriding locked formal reports with empty notes
    final report = DailyReport(
      id: currentReport?.id,
      date: dateStr,
      rawNotes: rawNotes,
      formalReport: currentReport?.formalReport, // Retain formal report
    );

    // If there's no ID and notes are entirely empty, skip saving
    if (currentReport?.id == null && rawNotes.trim().isEmpty) return;

    await _repo.saveReport(report);
    // Reload silently without throwing loading state
    final savedReport = await _repo.getReportByDate(dateStr);
    state = state.copyWith(reportStatus: AsyncValue.data(savedReport));
  }

  /// Pass the current notes through the AI engine to generate the Formal text
  Future<void> generateFormalReport(String rawNotes) async {
    // Lock the UI into loading visually
    final dateStr = DateFormat('yyyy-MM-dd').format(state.selectedDate);
    final previousData = state.reportStatus.valueOrNull;

    state = state.copyWith(reportStatus: const AsyncValue.loading());

    try {
      final formalText = await _aiService.synthesizeReport(rawNotes);
      
      final currentReport = await _repo.getReportByDate(dateStr);
      
      final updatedReport = DailyReport(
        id: currentReport?.id ?? previousData?.id,
        date: dateStr,
        rawNotes: rawNotes, // Preserve original draft
        formalReport: formalText, // Store AI version separately
      );

      await _repo.saveReport(updatedReport);
      await _loadReportForDate(state.selectedDate);
    } catch (e, stack) {
      state = state.copyWith(reportStatus: AsyncValue.error(e, stack));
    }
  }

  /// Manually update and save the formal report text (editing)
  Future<void> updateFormalReport(String formalText) async {
    final report = state.reportStatus.valueOrNull;
    if (report == null) return;

    final updatedReport = DailyReport(
      id: report.id,
      date: report.date,
      rawNotes: report.rawNotes,
      formalReport: formalText,
    );

    await _repo.saveReport(updatedReport);
    state = state.copyWith(reportStatus: AsyncValue.data(updatedReport));
  }

  /// Aggregate all notes for a custom range and summarize for Preview
  Future<String?> retrieveRangeSummary(DateTime start, DateTime end) async {
    state = state.copyWith(reportStatus: const AsyncValue.loading());
    try {
      final reports = await _repo.getReportsForRange(start, end);
      final allNotes = reports.map((r) => r.rawNotes).where((n) => n.isNotEmpty).toList();
      
      if (allNotes.isEmpty) {
         state = state.copyWith(reportStatus: AsyncValue.data(state.reportStatus.valueOrNull));
         return null;
      }
      
      final summary = await _aiService.synthesizeMonthlySummary(allNotes);
      state = state.copyWith(reportStatus: AsyncValue.data(state.reportStatus.valueOrNull));
      return summary;
    } catch (e, stack) {
      state = state.copyWith(reportStatus: AsyncValue.error(e, stack));
      return null;
    }
  }
}

// Global provider for the Journal Engine
final yapJournalProvider = StateNotifierProvider<YapJournalController, YapJournalState>(
  (ref) => YapJournalController(),
);
