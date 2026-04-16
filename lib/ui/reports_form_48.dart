import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/civic_horizon_theme.dart';
import '../controllers/reports_controller.dart';
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
                    _buildAssembleButton(context, ref, state, notifier),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DTR Generator',
          style: context.text.displayMedium?.copyWith(fontSize: 28, letterSpacing: -1.0),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
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
              'Selected Period', 
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

  Widget _buildAssembleButton(BuildContext context, WidgetRef ref, ReportsState state, ReportsController notifier) {
    bool isLoading = state.isGeneratingPdf || state.logsStatus.isLoading;

    return GestureDetector(
      onTap: isLoading ? null : () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(child: CircularProgressIndicator()),
        );
        try {
          await notifier.generatePDF();
          if (context.mounted) Navigator.pop(context); // pop loading
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isLoading ? context.colors.outlineVariant : context.colors.primary,
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
    double totalValidHours = 0.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 600, // Safe minimum width for 4-column DTR layout
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
                    color: context.colors.tertiary.withAlpha(51),
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
            final dtRef = log.amArrivalTime != null ? DateTime.parse(log.amArrivalTime!) : DateTime.parse(log.date);
            final strDate = DateFormat('MMM dd, yyyy').format(dtRef);
            final strDay = DateFormat('EEEE').format(dtRef);
            
            // Format Display Status
            String displayStatus = log.status;
            if (displayStatus == 'HOLIDAY_FULL') displayStatus = 'HOLIDAY';
            if (displayStatus == 'HOLIDAY_AM') displayStatus = 'HOLIDAY (AM)';
            if (displayStatus == 'HOLIDAY_PM') displayStatus = 'HOLIDAY (PM)';

            String sAmArr = isWork ? (log.amArrivalTime != null ? DateFormat('hh:mm').format(DateTime.parse(log.amArrivalTime!)) : '--:--') : displayStatus;
            String sPmDep = isWork ? (log.pmDepartureTime != null ? DateFormat('hh:mm').format(DateTime.parse(log.pmDepartureTime!)) : '--:--') : (log.remarks ?? '');
            
            int lateVal = 0;
            if (settings != null && log.amArrivalTime != null && isWork) {
              lateVal = HourglassEngine.calculateLateDeductions(log, settings.expectedTimeIn);
              totalLateMins += lateVal;
            }

            double shiftHours = 0.0;
            if (isWork && settings != null) {
              shiftHours = HourglassEngine.calculateActualHours(log, settings);
            }
            totalValidHours += shiftHours;

            final lateString = lateVal > 0 ? '$lateVal m' : '--';
            final hasError = lateVal > 0;

            return _buildTableRow(context, strDate, strDay, sAmArr, sPmDep, lateString, hasError);
          }).toList(),

          // Table Footer — Stats Summary
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest.withAlpha(102),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.primary.withAlpha(50)),
                  ),
                  child: _buildLedgerStat(context, 'Valid Hours (Rendered)', '${totalValidHours.toStringAsFixed(1)} hrs'),
                ),
                const SizedBox(width: 24),
                _buildLedgerStat(context, 'Total Tardy', '$totalLateMins mins'),
                const SizedBox(width: 24),
                _buildLedgerStat(context, 'Undertime', '$totalUndertimeMins mins'),
              ],
            ),
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
          Expanded(flex: 3, child: Center(child: Text('AM ARRIVAL', style: _headerStyle(context)))),
          Expanded(flex: 3, child: Center(child: Text('PM DEPARTURE', style: _headerStyle(context)))),
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

  Widget _buildTableRow(BuildContext context, String date, String day, String amArr, String pmDep, String lateVal, bool hasError) {
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
                Text(date, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: context.colors.onSurface)),
                Text(day, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: context.colors.onSurfaceVariant)),
              ],
            ),
          ),
          _buildTimeCell(context, amArr, hasError, flex: 3),
          _buildTimeCell(context, pmDep, false, flex: 3),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                lateVal,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
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

  Widget _buildTimeCell(BuildContext context, String time, bool isError, {int flex = 2}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          time,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isError ? context.colors.error : context.colors.onSurface,
          ),
        ),
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
