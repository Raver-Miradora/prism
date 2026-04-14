import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/civic_horizon_theme.dart';
import '../controllers/yap_journal_controller.dart';
import '../controllers/settings_controller.dart';
import '../data/repositories/daily_report_repository.dart';

import '../services/report_generator_service.dart';
import '../services/app_feedback.dart';
import 'widgets/prism_drawer.dart';
import 'widgets/profile_avatar.dart';
import 'document_preview_screen.dart';

class YapToReportJournal extends ConsumerStatefulWidget {
  const YapToReportJournal({super.key});

  @override
  ConsumerState<YapToReportJournal> createState() => _YapToReportJournalState();
}

class _YapToReportJournalState extends ConsumerState<YapToReportJournal> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _formalController = TextEditingController();
  Timer? _debounce;
  bool _isSaving = false;
  String? _lastOriginalNotes;

  @override
  void initState() {
    super.initState();
    // Re-initialize controller text safely when switching dates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTextFieldWithState();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _notesController.dispose();
    _formalController.dispose();
    super.dispose();
  }

  void _syncTextFieldWithState() {
    final state = ref.read(yapJournalProvider);
    final report = state.reportStatus.valueOrNull;
    if (_notesController.text != (report?.rawNotes ?? '')) {
      _notesController.text = report?.rawNotes ?? '';
    }
    if (_formalController.text != (report?.formalReport ?? '')) {
      _formalController.text = report?.formalReport ?? '';
    }
  }

  void _onNotesChanged(String text) {
    setState(() => _isSaving = true);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        ref.read(yapJournalProvider.notifier).saveRawNotes(text).then((_) {
          if (mounted) setState(() => _isSaving = false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final journalState = ref.watch(yapJournalProvider);
    final isLoading = journalState.reportStatus.isLoading;

    // Keep textField in sync lazily without interrupting typing
    ref.listen(yapJournalProvider, (previous, next) {
      if (previous?.selectedDate != next.selectedDate ||
          (previous?.reportStatus.isLoading == true && !next.reportStatus.isLoading)) {
        _syncTextFieldWithState();
      }
    });

    return Scaffold(
      backgroundColor: context.colors.surface,
      drawer: const PrismDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(context, journalState.selectedDate),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDatePicker(context, journalState.selectedDate),
                    const SizedBox(height: 16),
                    _buildRecentDaysStrip(context, journalState.selectedDate),
                    const SizedBox(height: 20),
                    _buildAITipBox(context),
                    const SizedBox(height: 24),
                    _buildNotesInput(context, isLoading),
                    const SizedBox(height: 24),
                    _buildExportMonthlyButton(context, journalState.selectedDate, isLoading),
                    const SizedBox(height: 80), // Padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDaysStrip(BuildContext context, DateTime selectedDate) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (ctx, index) {
          final date = DateTime.now().subtract(Duration(days: index));
          final isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(selectedDate);
          
          return GestureDetector(
            onTap: () => ref.read(yapJournalProvider.notifier).changeDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              decoration: BoxDecoration(
                color: isSelected ? context.colors.primary : context.colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? null : Border.all(color: context.colors.outlineVariant.withAlpha(50)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? context.colors.onPrimary.withValues(alpha: 0.7) : context.colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? context.colors.onPrimary : context.colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildTopAppBar(BuildContext context, DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: context.colors.surface.withAlpha(216), // 0.85 opacity
        border: Border(
          bottom: BorderSide(
            color: context.colors.surfaceContainerHigh.withAlpha(128),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(
                builder: (ctx) => IconButton(
                  icon: Icon(Icons.menu, color: context.colors.primary),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'PRISM',
                style: context.text.headlineLarge?.copyWith(fontSize: 20, letterSpacing: -1.0),
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Journal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                  Text(
                    'ACTIVE SESSION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              const ProfileAvatar(size: 44),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, DateTime selectedDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_today, color: context.colors.onPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECTED DATE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurfaceVariant,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(selectedDate),
                    style: context.text.bodyLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () async {
              final newDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (newDate != null) {
                ref.read(yapJournalProvider.notifier).changeDate(newDate);
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: context.colors.surfaceContainerHighest,
              foregroundColor: context.colors.onSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            icon: const Text('Change'),
            label: const Icon(Icons.expand_more, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAITipBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primary.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.primary.withAlpha(25)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: context.colors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRO-TIP FOR AI POLISHING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mention specific tasks (e.g., "Encoded 50 records") or outcomes for better results.',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesInput(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'DAILY ACCOMPLISHMENTS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isSaving ? 0.5 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _isSaving ? context.colors.surfaceContainerHigh : const Color(0xFFE8F5E9).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: _isSaving ? null : Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        _isSaving ? 'SAVING...' : 'SAVED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _isSaving ? context.colors.onSurfaceVariant : const Color(0xFF4CAF50),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              else
                ElevatedButton.icon(
                  onPressed: () {
                    final currentText = _notesController.text.trim();
                    if (currentText.isEmpty) return;
                    FocusManager.instance.primaryFocus?.unfocus();

                    String textToPolish = currentText;
                    if (_lastOriginalNotes != null && currentText.startsWith('•')) {
                      textToPolish = _lastOriginalNotes!;
                    } else {
                      _lastOriginalNotes = currentText;
                    }

                    ref.read(yapJournalProvider.notifier).generateFormalReport(textToPolish).then((_) {
                       if (context.mounted) AppFeedback.showSuccess(context, 'Accomplishments polished by AI.');
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.secondary,
                    foregroundColor: context.colors.onSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 2,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 14),
                  label: const Text(
                    'AI Polish',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                )
            ],
          ),
        ),
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: TextField(
            controller: _notesController,
            onChanged: _onNotesChanged,
            maxLines: null,
            expands: true,
            style: TextStyle(color: context.colors.onSurface),
            decoration: InputDecoration(
              hintText: 'Type your informal daily notes here...',
              hintStyle: TextStyle(color: context.colors.outlineVariant),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportMonthlyButton(BuildContext context, DateTime selectedDate, bool isLoading) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : () async {
          final range = await showDateRangePicker(
            context: context, 
            firstDate: DateTime(2025), 
            lastDate: DateTime.now().add(const Duration(days: 365)),
            currentDate: DateTime.now(),
            saveText: 'GO',
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: context.colors,
                ),
                child: child!,
              );
            }
          );

          if (range == null) return;
          if (!context.mounted) return;

          final summary = await ref.read(yapJournalProvider.notifier).retrieveRangeSummary(range.start, range.end);
          if (!context.mounted) return;
          if (summary == null || summary.isEmpty) {
             AppFeedback.showError(context, "No completed entries found for selected range.");
             return;
          }
          
          Navigator.push(context, MaterialPageRoute(
            builder: (ctx) => DocumentPreviewScreen(
              title: 'Accomplishment Report Preview',
              initialContent: summary,
              onApprove: (docCtx, finalSummary) async {
                  final repo = DailyReportRepository();
                  final reports = await repo.getReportsForRange(range.start, range.end);
                  final settingsState = ref.read(settingsProvider);
                  final profile = settingsState.profile;
                  final settings = settingsState.settings;
                  if (profile == null || settings == null) return;

                  try {
                    final reportPath = await ReportGeneratorService.generateReport(
                      reports: reports,
                      profile: profile,
                      settings: settings,
                      start: range.start,
                      end: range.end,
                      customSummaryBullets: finalSummary,
                    );

                    if (docCtx.mounted) {
                      showDialog(
                        context: docCtx,
                        builder: (sCtx) => AlertDialog(
                          title: const Text('REPORT GENERATED'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Professional report has been saved to your Documents directory:', style: TextStyle(fontSize: 12)),
                              const SizedBox(height: 16),
                              Text('PDF: $reportPath', style: const TextStyle(fontSize: 10, color: Colors.blue)),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(sCtx), child: const Text('OK')),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    if (docCtx.mounted) AppFeedback.showError(docCtx, 'Generation failed: $e');
                  }








              }
            )
          ));
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          side: BorderSide(color: context.colors.primary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: context.colors.primary,
        ),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text(
          'Generate Accomplishment Report',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
