import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/civic_horizon_theme.dart';
import '../controllers/yap_journal_controller.dart';
import '../data/models/daily_report.dart';
import 'widgets/prism_drawer.dart';

class YapToReportJournal extends ConsumerStatefulWidget {
  const YapToReportJournal({super.key});

  @override
  ConsumerState<YapToReportJournal> createState() => _YapToReportJournalState();
}

class _YapToReportJournalState extends ConsumerState<YapToReportJournal> {
  final TextEditingController _notesController = TextEditingController();
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
    super.dispose();
  }

  void _syncTextFieldWithState() {
    final state = ref.read(yapJournalProvider);
    final report = state.reportStatus.valueOrNull;
    if (_notesController.text != (report?.rawNotes ?? '')) {
      _notesController.text = report?.rawNotes ?? '';
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
      backgroundColor: CivicHorizonTheme.background,
      drawer: const PrismDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(journalState.selectedDate),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDatePicker(context, journalState.selectedDate),
                    const SizedBox(height: 24),
                    _buildNotesInput(),
                    const SizedBox(height: 32),
                    _buildGenerateButton(isLoading),
                    const SizedBox(height: 32),
                    _buildFormalOutputCard(activeReport, isLoading),
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

  Widget _buildTopAppBar(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: CivicHorizonTheme.surface.withAlpha(216), // 0.85 opacity
        border: Border(
          bottom: BorderSide(
            color: CivicHorizonTheme.surfaceContainerHigh.withAlpha(128),
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
                  icon: const Icon(Icons.menu, color: CivicHorizonTheme.primary),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'PRISM',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: CivicHorizonTheme.primary,
                  letterSpacing: -1.0,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'Journal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: CivicHorizonTheme.primary,
                    ),
                  ),
                  Text(
                    'ACTIVE SESSION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: CivicHorizonTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CivicHorizonTheme.outlineVariant.withAlpha(50), width: 1),
                  color: CivicHorizonTheme.primaryContainer,
                  image: const DecorationImage(
                    image: NetworkImage('https://placeholder.com/user_avatar'), // Fallback placeholder
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
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
        color: CivicHorizonTheme.surfaceContainerLow,
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
                  color: CivicHorizonTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today, color: CivicHorizonTheme.onPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SELECTED DATE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CivicHorizonTheme.onSurfaceVariant,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(selectedDate),
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CivicHorizonTheme.primary,
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
              backgroundColor: CivicHorizonTheme.surfaceContainerHighest,
              foregroundColor: CivicHorizonTheme.onSurface,
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

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'DAILY TRANSCRIPT / INFORMAL NOTES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: CivicHorizonTheme.onSurfaceVariant,
            ),
          ),
        ),
        Stack(
          children: [
            Container(
              height: 320,
              decoration: BoxDecoration(
                color: CivicHorizonTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: TextField(
                controller: _notesController,
                onChanged: _onNotesChanged,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Type your informal daily notes here...',
                  hintStyle: TextStyle(color: CivicHorizonTheme.outlineVariant),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(24),
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
                    color: _isSaving ? CivicHorizonTheme.surfaceContainerHigh : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _isSaving ? 'SAVING...' : 'DRAFT SAVED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _isSaving ? CivicHorizonTheme.onSurfaceVariant : const Color(0xFF2E7D32),
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

  Widget _buildGenerateButton(bool isLoading) {
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
                : CivicHorizonTheme.ctaGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4)),
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

  Widget _buildFormalOutputCard(DailyReport? report, bool isLoading) {
    bool hasFormalText = report?.formalReport != null && report!.formalReport!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: CivicHorizonTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicHorizonTheme.outlineVariant.withAlpha(25)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: CivicHorizonTheme.primary.withAlpha(12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.description, color: CivicHorizonTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'AI Formal Output',
                      style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.bold, color: CivicHorizonTheme.primary),
                    ),
                  ],
                ),
                if (hasFormalText)
                  TextButton.icon(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: CivicHorizonTheme.primary,
                      side: BorderSide(color: CivicHorizonTheme.primary.withAlpha(25)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.content_copy, size: 14),
                    label: const Text('Copy text', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(minHeight: 240),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLoading
                ? _buildLoadingSkeleton()
                : hasFormalText
                    ? Text(
                        report!.formalReport!,
                        style: const TextStyle(fontSize: 14, color: CivicHorizonTheme.onSurface, height: 1.6),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 16),
                            decoration: const BoxDecoration(
                              border: Border(left: BorderSide(color: CivicHorizonTheme.primaryContainer, width: 4)),
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
        Container(height: 16, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 12),
        Container(height: 16, width: 220, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 12),
        Container(height: 16, width: 300, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
      ],
    );
  }
}
