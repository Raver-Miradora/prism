import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/civic_horizon_theme.dart';
import 'dashboard_timeclock.dart';
import 'profile_settings.dart';
import 'reports_form_48.dart';
import 'yap_to_report_journal.dart';

// Riverpod Provider tracking current index (0 to 3)
final navIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Current active screen index
    final currentIndex = ref.watch(navIndexProvider);

    // List of screens to stack
    final screens = [
      const DashboardTimeclock(),
      const YapToReportJournal(),
      const ReportsForm48(),
      const ProfileSettings(),
    ];

    return Scaffold(
      backgroundColor: CivicHorizonTheme.background,
      // We use Stack to keep state of all pages alive instantly but visually overlay the active one.
      // IndexedStack is perfect for Bottom Navs.
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildGlassBottomNavBar(currentIndex, ref),
    );
  }

  Widget _buildGlassBottomNavBar(int currentIndex, WidgetRef ref) {
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
              _buildNavItem(0, Icons.home, 'Home', currentIndex, ref),
              _buildNavItem(1, Icons.edit_note, 'Journal', currentIndex, ref),
              _buildNavItem(2, Icons.analytics, 'Reports', currentIndex, ref),
              _buildNavItem(3, Icons.settings, 'Settings', currentIndex, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, int currentIndex, WidgetRef ref) {
    final isActive = index == currentIndex;
    final color = isActive ? CivicHorizonTheme.primary : const Color(0xFF94A3B8);
    final bgColor = isActive ? CivicHorizonTheme.primary.withOpacity(0.1) : Colors.transparent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Change nav bar index via riverpod
        ref.read(navIndexProvider.notifier).state = index;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                letterSpacing: 0.5,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
