import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/civic_horizon_theme.dart';
import '../controllers/reports_controller.dart';
import '../core/utils/hourglass_engine.dart';
import 'widgets/prism_drawer.dart';

class ReportsForm48 extends ConsumerWidget {
  const ReportsForm48({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsControllerProvider);
    final notifier = ref.read(reportsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: CivicHorizonTheme.background,
      drawer: const PrismDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildReportHeader(state, notifier),
                    const SizedBox(height: 32),
                    _buildTimesheetLedger(state),
                    const SizedBox(height: 32),
                    _buildAssembleButton(state, notifier),
                    const SizedBox(height: 32),
                    _buildSecondaryInsights(state, notifier),
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

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: CivicHorizonTheme.surface.withAlpha(216),
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
                'Reports',
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
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: CivicHorizonTheme.outlineVariant.withAlpha(51), width: 1),
              color: CivicHorizonTheme.surfaceContainerHighest,
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBGk-Fvgr3zIM0ERXwAtXf_Vk068kgBaBt_9_UtIxdKOUjxSGMqDYibLGYEKLMdJPu2UD-SXz0CLZIfAqNeiJZior64yu35DRS41Uzkdk1jUFvdXvXhLXdbBk6rFhScpUllmSO6bXVud3YiU6DEboHnrsgtfJDMu55yZzjJtYgyPaiAWVQgiXlTLS0CFOyyv-4Pb6Y0PpsAAt9U5Y3KU_LGyVnDibeSKOz7vxYo_EyJKkgsQJboQ4rGn1LP9qzKu48tJ9moToMOmc4'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportHeader(ReportsState state, ReportsController notifier) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'DTR Generator',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: CivicHorizonTheme.primary,
                letterSpacing: -1.0,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: CivicHorizonTheme.primary),
              onPressed: () => notifier.changeMonth(-1),
            ),
            _buildDropdownFilter(
              'Period', 
              DateFormat('MMMM yyyy').format(DateTime(state.selectedYear, state.selectedMonth))
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: CivicHorizonTheme.primary),
              onPressed: () => notifier.changeMonth(1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownFilter(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CivicHorizonTheme.onSurfaceVariant),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: CivicHorizonTheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: CivicHorizonTheme.onSurface)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssembleButton(ReportsState state, ReportsController notifier) {
    bool isLoading = state.isGeneratingPdf || state.logsStatus.isLoading;

    return GestureDetector(
      onTap: isLoading ? null : () => notifier.generatePDF(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: isLoading ? const LinearGradient(colors: [Colors.grey, Colors.blueGrey]) : CivicHorizonTheme.ctaGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CivicHorizonTheme.primary.withAlpha(25),
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

  Widget _buildTimesheetLedger(ReportsState state) {
    final logs = state.logsStatus.valueOrNull ?? [];
    final settings = state.settingsStatus.valueOrNull;
    
    int totalLateMins = 0;
    int totalUndertimeMins = 0;

    return Container(
      decoration: BoxDecoration(
        color: CivicHorizonTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicHorizonTheme.outlineVariant.withAlpha(25)),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Table Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: CivicHorizonTheme.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: CivicHorizonTheme.outlineVariant.withAlpha(25))),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.event_note, color: CivicHorizonTheme.primary),
                    SizedBox(width: 8),
                    Text('Attendance Registry', style: TextStyle(fontWeight: FontWeight.bold, color: CivicHorizonTheme.primary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: CivicHorizonTheme.tertiaryFixedDim,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('ACTIVE RECORD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: CivicHorizonTheme.onTertiaryFixedVariant)),
                ),
              ],
            ),
          ),
          
          _buildTableRowHeader(),

          if (state.logsStatus.isLoading)
            const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator())),

          if (!state.logsStatus.isLoading && logs.isEmpty)
             const Padding(padding: EdgeInsets.all(48), child: Center(child: Text("No attendance logged for this period.", style: TextStyle(color: Colors.grey)))),

          // Dynamically map table rows
          ...logs.map((log) {
            final dtIn = DateTime.parse(log.timeIn);
            final strDate = DateFormat('MMM dd, yyyy').format(dtIn);
            final strDay = DateFormat('EEEE').format(dtIn);
            final strArr = DateFormat('hh:mm a').format(dtIn);
            final strDep = log.timeOut != null ? DateFormat('hh:mm a').format(DateTime.parse(log.timeOut!)) : 'Active';

            int lateVal = 0;
            if (settings != null && log.timeOut != null) {
              lateVal = HourglassEngine.calculateLateDeductions(log, settings.expectedTimeIn);
              totalLateMins += lateVal;
            }

            final lateString = lateVal > 0 ? '$lateVal m' : '-- : --';
            final hasError = lateVal > 0;

            return _buildTableRow(strDate, strDay, strArr, strDep, lateString, hasError);
          }),

          // Table Footer Actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CivicHorizonTheme.surfaceContainerHighest.withAlpha(102),
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
                    _buildLedgerStat('Total Tardy', '$totalLateMins mins'),
                    const SizedBox(width: 32),
                    _buildLedgerStat('Total Undertime', '${totalUndertimeMins} mins'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRowHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('DATE', style: _headerStyle)),
          Expanded(flex: 2, child: Center(child: Text('ARRIVAL', style: _headerStyle))),
          Expanded(flex: 2, child: Center(child: Text('DEPARTURE', style: _headerStyle))),
          Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('LATE', style: _headerStyle))),
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: CivicHorizonTheme.onSurfaceVariant,
    letterSpacing: 1.0,
  );

  Widget _buildTableRow(String date, String day, String arr, String dep, String lateVal, bool hasError) {
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: CivicHorizonTheme.surfaceContainerHigh))),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontWeight: FontWeight.bold, color: CivicHorizonTheme.onSurface)),
                Text(day, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: CivicHorizonTheme.onSurfaceVariant)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(arr, style: TextStyle(fontWeight: FontWeight.w500, color: hasError ? CivicHorizonTheme.error : CivicHorizonTheme.onSurface)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(dep, style: const TextStyle(fontWeight: FontWeight.w500, color: CivicHorizonTheme.onSurface)),
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
                  color: hasError ? CivicHorizonTheme.error : const Color(0xFF179D53),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: CivicHorizonTheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: CivicHorizonTheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildFooterButton(IconData icon, String label, {required bool isPrimary}) {
    return TextButton.icon(
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor: isPrimary ? CivicHorizonTheme.primary : CivicHorizonTheme.surfaceContainerHighest,
        foregroundColor: isPrimary ? CivicHorizonTheme.onPrimary : CivicHorizonTheme.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildSecondaryInsights(ReportsState state, ReportsController notifier) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        Container(
          width: 380, // Constrain width instead of Expanded
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: CivicHorizonTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CivicHorizonTheme.outlineVariant.withAlpha(12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.verified, color: CivicHorizonTheme.primaryContainer, size: 18),
                  SizedBox(width: 8),
                  Text('Certification Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: CivicHorizonTheme.primaryContainer)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'I certify on my honor that the above is a true and correct report of the hours of work performed...',
                style: TextStyle(fontSize: 12, color: CivicHorizonTheme.onSurfaceVariant, height: 1.5),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: state.profileStatus.valueOrNull?.name ?? '',
                onFieldSubmitted: (val) => notifier.updateProfileName(val),
                decoration: const InputDecoration(
                  hintText: 'Enter E-Signature Name...',
                  hintStyle: TextStyle(fontSize: 10, letterSpacing: 1.0),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: CivicHorizonTheme.outlineVariant)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: CivicHorizonTheme.primary, width: 2)),
                ),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: CivicHorizonTheme.primary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Container(
          width: 380, // Constrain width instead of Expanded
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: CivicHorizonTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CivicHorizonTheme.outlineVariant.withAlpha(12)),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: CivicHorizonTheme.primaryContainer.withAlpha(25), shape: BoxShape.circle),
                child: const Icon(Icons.info, color: CivicHorizonTheme.primaryContainer),
              ),
              const SizedBox(height: 12),
              const Text('Need Adjustments?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              const Text('Submit a Correction Request through Journal.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: CivicHorizonTheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {},
                child: const Text('Open Journal', style: TextStyle(fontWeight: FontWeight.bold, color: CivicHorizonTheme.primary)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
