import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/civic_horizon_theme.dart';
import '../controllers/reports_controller.dart';
import '../controllers/timeclock_controller.dart';
import '../core/utils/hourglass_engine.dart';
import 'widgets/prism_drawer.dart';
import 'widgets/profile_avatar.dart';

class ReportsForm48 extends ConsumerWidget {
  const ReportsForm48({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsControllerProvider);
    final notifier = ref.read(reportsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.surface,
      drawer: const PrismDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildReportHeader(context, state, notifier),
                    const SizedBox(height: 32),
                    _buildTimesheetLedger(context, ref, state),
                    const SizedBox(height: 32),
                    _buildAssembleButton(context, state, notifier),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: context.colors.surface.withAlpha(216),
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
              Text(
                'Reports',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 16),
              const ProfileAvatar(size: 44),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportHeader(BuildContext context, ReportsState state, ReportsController notifier) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DTR Generator',
              style: context.text.displayMedium?.copyWith(fontSize: 28, letterSpacing: -1.0),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.refresh, color: context.colors.primary),
              onPressed: () => notifier.loadData(state.selectedYear, state.selectedMonth),
              tooltip: 'Refresh Data',
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.chevron_left, color: context.colors.primary),
              onPressed: () => notifier.changeMonth(-1),
            ),
            _buildDropdownFilter(
              context,
              'Period', 
              DateFormat('MMMM yyyy').format(DateTime(state.selectedYear, state.selectedMonth))
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: context.colors.primary),
              onPressed: () => notifier.changeMonth(1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownFilter(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.colors.onSurfaceVariant),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.onSurface)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssembleButton(BuildContext context, ReportsState state, ReportsController notifier) {
    bool isLoading = state.isGeneratingPdf || state.logsStatus.isLoading;

    return GestureDetector(
      onTap: isLoading ? null : () => notifier.generatePDF(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: isLoading ? const LinearGradient(colors: [Colors.grey, Colors.blueGrey]) : CivicHorizonTheme.ctaGradient(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withAlpha(25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            else
              const Icon(Icons.picture_as_pdf, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              isLoading ? 'Rendering PDF...' : 'Assemble DTR PDF',
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimesheetLedger(BuildContext context, WidgetRef ref, ReportsState state) {
    final logs = state.logsStatus.valueOrNull ?? [];
    final settings = state.settingsStatus.valueOrNull;
    
    int totalLateMins = 0;
    int totalUndertimeMins = 0;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant.withAlpha(25)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Table Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: context.colors.outlineVariant.withAlpha(25))),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_note, color: context.colors.primary),
                    const SizedBox(width: 8),
                    Text('Attendance Registry', style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.primary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.tertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('ACTIVE RECORD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: context.colors.tertiary)),
                ),
              ],
            ),
          ),
          
          _buildTableRowHeader(context),

          if (state.logsStatus.isLoading)
            const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator())),

          if (!state.logsStatus.isLoading && logs.isEmpty)
             const Padding(padding: EdgeInsets.all(48), child: Center(child: Text("No attendance logged for this period.", style: TextStyle(color: Colors.grey)))),

          // Dynamically map table rows
          ...logs.map((log) {
            final isWork = log.status == 'WORK';
            final dtIn = log.timeIn != null ? DateTime.parse(log.timeIn!) : DateTime.parse(log.date);
            final strDate = DateFormat('MMM dd, yyyy').format(dtIn);
            final strDay = DateFormat('EEEE').format(dtIn);
            
            // Format Display Status
            String displayStatus = log.status;
            if (displayStatus == 'HOLIDAY_FULL') displayStatus = 'HOLIDAY';
            if (displayStatus == 'HOLIDAY_AM') displayStatus = 'HOLIDAY (AM)';
            if (displayStatus == 'HOLIDAY_PM') displayStatus = 'HOLIDAY (PM)';

            String strArr = isWork ? (log.timeIn != null ? DateFormat('hh:mm a').format(DateTime.parse(log.timeIn!)) : '--:--') : displayStatus;
            String strDep = isWork ? (log.timeOut != null ? DateFormat('hh:mm a').format(DateTime.parse(log.timeOut!)) : 'Active') : (log.remarks ?? '');
            
            int lateVal = 0;
            if (settings != null && log.timeOut != null && isWork) {
              lateVal = HourglassEngine.calculateLateDeductions(log, settings.expectedTimeIn);
              totalLateMins += lateVal;
            }

            final lateString = lateVal > 0 ? '$lateVal m' : '-- : --';
            final hasError = lateVal > 0;

            return _buildTableRow(context, strDate, strDay, strArr, strDep, lateString, hasError);
          }),

          // Table Footer Actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest.withAlpha(102),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLedgerStat(context, 'Total Tardy', '$totalLateMins mins'),
                    const SizedBox(width: 32),
                    _buildLedgerStat(context, 'Total Undertime', '$totalUndertimeMins mins'),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showManualEntryDialog(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.edit_calendar, size: 18),
                  label: const Text('Log Absence/Leave/Holiday', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog(BuildContext context, WidgetRef ref) {
    DateTime selectedDate = DateTime.now();
    String selectedStatus = 'ABSENT';
    final remarksController = TextEditingController();

    final statusOptions = {
      'ABSENT': 'Absent',
      'EXCUSED': 'Excused / Leave',
      'HOLIDAY_FULL': 'Holiday (Whole Day)',
      'HOLIDAY_AM': 'Holiday (AM Only)',
      'HOLIDAY_PM': 'Holiday (PM Only)',
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Log Status Entry', style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                trailing: const Icon(Icons.calendar_today, size: 20),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Attendance Status',
                  labelStyle: TextStyle(fontSize: 12),
                  border: OutlineInputBorder(),
                ),
                items: statusOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 14)))).toList(),
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks / Specific Reason',
                  labelStyle: TextStyle(fontSize: 12),
                  hintText: 'e.g. Sick Leave, National Holiday...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await ref.read(timeclockControllerProvider.notifier).logAttendanceStatus(
                  selectedDate,
                  selectedStatus,
                  remarksController.text,
                );
                // Refresh list
                ref.read(reportsControllerProvider.notifier).loadData(
                  ref.read(reportsControllerProvider).selectedYear,
                  ref.read(reportsControllerProvider).selectedMonth,
                );
                if (context.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRowHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('DATE', style: _headerStyle(context))),
          Expanded(flex: 2, child: Center(child: Text('ARRIVAL', style: _headerStyle(context)))),
          Expanded(flex: 2, child: Center(child: Text('DEPARTURE', style: _headerStyle(context)))),
          Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('LATE', style: _headerStyle(context)))),
        ],
      ),
    );
  }

  TextStyle _headerStyle(BuildContext context) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: context.colors.onSurfaceVariant,
    letterSpacing: 1.0,
  );

  Widget _buildTableRow(BuildContext context, String date, String day, String arr, String dep, String lateVal, bool hasError) {
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.colors.surfaceContainerHigh))),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.onSurface)),
                Text(day, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: context.colors.onSurfaceVariant)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(arr, style: TextStyle(fontWeight: FontWeight.w500, color: hasError ? context.colors.error : context.colors.onSurface)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(dep, style: TextStyle(fontWeight: FontWeight.w500, color: context.colors.onSurface)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                lateVal,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: hasError ? FontWeight.bold : FontWeight.normal,
                  color: hasError ? context.colors.error : const Color(0xFF179D53),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerStat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: context.colors.onSurfaceVariant),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: context.colors.onSurface),
        ),
      ],
    );
  }

}
