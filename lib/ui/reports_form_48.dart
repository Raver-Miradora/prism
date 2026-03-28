import 'package:flutter/material.dart';
import '../core/theme/civic_horizon_theme.dart';

class ReportsForm48 extends StatelessWidget {
  const ReportsForm48({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivicHorizonTheme.background,
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
                    _buildReportHeader(),
                    const SizedBox(height: 32),
                    _buildAssembleButton(),
                    const SizedBox(height: 32),
                    _buildTimesheetLedger(),
                    const SizedBox(height: 32),
                    _buildSecondaryInsights(),
                    const SizedBox(height: 80), // Padding for bottom nav
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
        color: CivicHorizonTheme.surface.withOpacity(0.85),
        border: Border(
          bottom: BorderSide(
            color: CivicHorizonTheme.surfaceContainerHigh.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: CivicHorizonTheme.primary),
                onPressed: () {},
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
              border: Border.all(color: CivicHorizonTheme.outlineVariant.withOpacity(0.2), width: 1),
              color: CivicHorizonTheme.surfaceContainerHighest,
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCez5C_S9mAnYYtK0GNXbCPM70RyQaz_hFxzi-Lu-gIMe8laX8EaTroFihHF1-V8Od5phfOPMOuFZfU4avAXW4JagGZRBGEMZtNHupEo-hH3isC8filaatrMT8XsPxJXudiddj6P9X5eNag0FQq-vurOcawJY9V6uIvWv7T4tTKX92FPr22mDVms1Fczy4xfbGzOtAo6hxBXDA_yKAJadyFQa4MTCAhTj-ay1FDF4AyN6E04iyBBio-QTgfTa4i06-wk90FF6p1Dbo'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'CIVIL SERVICE COMMISSION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: CivicHorizonTheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Form 48 Generator',
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
            _buildDropdownFilter('Month', 'November'),
            const SizedBox(width: 16),
            _buildDropdownFilter('Year', '2024'),
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
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: CivicHorizonTheme.onSurfaceVariant,
            ),
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
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CivicHorizonTheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.expand_more, size: 16, color: CivicHorizonTheme.onSurfaceVariant),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssembleButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: CivicHorizonTheme.ctaGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CivicHorizonTheme.primary.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.picture_as_pdf, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Assemble CSC Form 48 PDF',
              style: TextStyle(
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

  Widget _buildTimesheetLedger() {
    return Container(
      decoration: BoxDecoration(
        color: CivicHorizonTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicHorizonTheme.outlineVariant.withOpacity(0.1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: CivicHorizonTheme.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: CivicHorizonTheme.outlineVariant.withOpacity(0.1))),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.event_note, color: CivicHorizonTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'Attendance Registry',
                      style: TextStyle(fontWeight: FontWeight.bold, color: CivicHorizonTheme.primary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: CivicHorizonTheme.tertiaryFixedDim,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'ACTIVE PERIOD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: CivicHorizonTheme.onTertiaryFixedVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Content Placeholder
          _buildTableRowHeader(),
          _buildTableRow('Nov 01, 2024', 'Friday', '07:54 AM', '05:02 PM', '-- : --', false),
          _buildTableRow('Nov 04, 2024', 'Monday', '08:15 AM', '05:10 PM', '0:15', true),
          _buildTableRow('Nov 05, 2024', 'Tuesday', '07:48 AM', '04:30 PM', '0:30', true),
          _buildTableRow('Nov 06, 2024', 'Wednesday', '07:59 AM', '05:05 PM', '-- : --', false),
          // Table Footer Actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CivicHorizonTheme.surfaceContainerHighest.withOpacity(0.4),
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
                    _buildLedgerStat('Total Tardy', '15 mins'),
                    const SizedBox(width: 32),
                    _buildLedgerStat('Total Undertime', '30 mins'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFooterButton(Icons.visibility, 'Preview PDF', isPrimary: false),
                    const SizedBox(width: 12),
                    _buildFooterButton(Icons.ios_share, 'Share/Export', isPrimary: true),
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
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: CivicHorizonTheme.surfaceContainerHigh)),
      ),
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
              child: Text(
                arr,
                style: TextStyle(fontWeight: FontWeight.w500, color: hasError && arr.startsWith('08') ? CivicHorizonTheme.error : CivicHorizonTheme.onSurface),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                dep,
                style: TextStyle(fontWeight: FontWeight.w500, color: hasError && dep.startsWith('04') ? CivicHorizonTheme.error : CivicHorizonTheme.onSurface),
              ),
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
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: CivicHorizonTheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: CivicHorizonTheme.onSurface,
          ),
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

  Widget _buildSecondaryInsights() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CivicHorizonTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CivicHorizonTheme.outlineVariant.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.verified, color: CivicHorizonTheme.primaryContainer, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Certification Status',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: CivicHorizonTheme.primaryContainer),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'I certify on my honor that the above is a true and correct report of the hours of work performed...',
                  style: TextStyle(fontSize: 12, color: CivicHorizonTheme.onSurfaceVariant, height: 1.5),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 60,
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 8),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: CivicHorizonTheme.outlineVariant, style: BorderStyle.solid))), // Flutter doesn't native support dashed easily without package, using solid
                  child: const Text('E-SIGNATURE ON FILE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: CivicHorizonTheme.onSurfaceVariant)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Simplification for screen sizing, omitting the 2nd insight card for brevity or making it smaller if needed.
        // I will omit the "Need adjustments" box on smaller screens to stick to pure flutter rendering easily.
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CivicHorizonTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CivicHorizonTheme.outlineVariant.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: CivicHorizonTheme.primaryContainer.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info, color: CivicHorizonTheme.primaryContainer),
                ),
                const SizedBox(height: 12),
                const Text('Need Adjustments?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                const Text(
                  'Submit a Correction Request through Journal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: CivicHorizonTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text('Open Journal', style: TextStyle(fontWeight: FontWeight.bold, color: CivicHorizonTheme.primary)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home'),
              _buildNavItem(Icons.edit_note, 'Journal'),
              _buildNavItem(Icons.analytics, 'Reports', isActive: true),
              _buildNavItem(Icons.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {
    final color = isActive ? CivicHorizonTheme.primary : const Color(0xFF94A3B8);
    final bgColor = isActive ? CivicHorizonTheme.primary.withOpacity(0.1) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
