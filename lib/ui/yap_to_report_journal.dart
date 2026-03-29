import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/civic_horizon_theme.dart';
import '../controllers/yap_journal_controller.dart';
import '../controllers/settings_controller.dart';
import '../data/models/daily_report.dart';
import '../data/repositories/daily_report_repository.dart';
import '../services/pdf_service.dart';
import '../core/utils/snackbar_utils.dart';
import 'widgets/prism_drawer.dart';
import 'widgets/profile_avatar.dart';

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
    final activeReport = journalState.reportStatus.valueOrNull;
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
                    const SizedBox(height: 24),
                    _buildNotesInput(context),
                    const SizedBox(height: 32),
                    _buildActionButtons(context, isLoading),
                    const SizedBox(height: 32),
                    _buildFormalOutputCard(context, activeReport, isLoading),
                    const SizedBox(height: 24),
                    _buildExportMonthlyButton(context, journalState.selectedDate),
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

  Widget _buildActionButtons(BuildContext context, bool isLoading) {
    return _buildGenerateButton(context, isLoading);
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

  Widget _buildNotesInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'DAILY TRANSCRIPT / INFORMAL NOTES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        Stack(
          children: [
            Container(
              height: 320,
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
            Positioned(
              bottom: 16,
              right: 16,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isSaving ? 0.5 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isSaving ? context.colors.surfaceContainerHigh : const Color(0xFFE8F5E9).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: _isSaving ? null : Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _isSaving ? 'SAVING...' : 'DRAFT SAVED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _isSaving ? context.colors.onSurfaceVariant : const Color(0xFF4CAF50),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenerateButton(BuildContext context, bool isLoading) {
    return Center(
      child: GestureDetector(
        onTap: isLoading
            ? null
            : () {
                // Focus out logic
                FocusManager.instance.primaryFocus?.unfocus();
                ref.read(yapJournalProvider.notifier).generateFormalReport(_notesController.text);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            gradient: isLoading
                ? const LinearGradient(colors: [Colors.grey, Colors.blueGrey])
                : CivicHorizonTheme.ctaGradient(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              else
                const Icon(Icons.auto_awesome, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                isLoading ? 'AI Engine Processing...' : 'Generate Formal Report',
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormalOutputCard(BuildContext context, DailyReport? report, bool isLoading) {
    bool hasFormalText = report?.formalReport != null && report!.formalReport!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant.withAlpha(25)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: context.colors.primary.withAlpha(12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.description, color: context.colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'AI Formal Output',
                      style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.bold, color: context.colors.primary),
                    ),
                  ],
                ),
                if (hasFormalText)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.refresh, size: 20, color: context.colors.primary),
                        onPressed: isLoading ? null : () => ref.read(yapJournalProvider.notifier).generateFormalReport(_notesController.text),
                        tooltip: 'Regenerate',
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _formalController.text));
                          SnackbarUtils.showSuccess(context, 'Copied to clipboard!');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: context.colors.primary,
                          side: BorderSide(color: context.colors.primary.withAlpha(25)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        icon: const Icon(Icons.content_copy, size: 14),
                        label: const Text('Copy text', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(minHeight: 240),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLoading
                ? _buildLoadingSkeleton()
                : hasFormalText
                    ? Column(
                        children: [
                          TextField(
                            controller: _formalController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Edit your formal report...',
                            ),
                            style: TextStyle(fontSize: 14, color: context.colors.onSurface, height: 1.6),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ref.read(yapJournalProvider.notifier).updateFormalReport(_formalController.text);
                                SnackbarUtils.showSuccess(context, 'Formal output updated and saved.');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colors.primary,
                                foregroundColor: context.colors.onPrimary,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              icon: const Icon(Icons.save, size: 18),
                              label: const Text('Commit Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 16),
                            decoration: BoxDecoration(
                              border: Border(left: BorderSide(color: context.colors.primaryContainer, width: 4)),
                            ),
                            child: const Text(
                              'Formal report will be synthesized here based on your informal notes above...',
                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, height: 1.5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLoadingSkeleton(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 16, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.withAlpha(40), borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 12),
        Container(height: 16, width: 220, decoration: BoxDecoration(color: Colors.grey.withAlpha(40), borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 12),
        Container(height: 16, width: 300, decoration: BoxDecoration(color: Colors.grey.withAlpha(40), borderRadius: BorderRadius.circular(4))),
      ],
    );
  }
  Widget _buildExportMonthlyButton(BuildContext context, DateTime selectedDate) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () async {
          final repo = DailyReportRepository();
          final reports = await repo.getReportsForMonth(selectedDate.year, selectedDate.month);
          final settingsState = ref.read(settingsProvider);
          final profile = settingsState.profile;
          if (profile == null) return;

          await PdfService.generateAndPrintMonthlyReport(
            reports,
            profile,
            selectedDate.year,
            selectedDate.month,
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          side: BorderSide(color: context.colors.primary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: context.colors.primary,
        ),
        icon: const Icon(Icons.picture_as_pdf),
        label: Text(
          'Export Monthly Report (${DateFormat('MMMM').format(selectedDate)})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}
