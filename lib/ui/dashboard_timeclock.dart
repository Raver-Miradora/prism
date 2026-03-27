import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/civic_horizon_theme.dart';
import '../controllers/timeclock_controller.dart';

class DashboardTimeclock extends ConsumerWidget {
  const DashboardTimeclock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch our core engine state!
    final state = ref.watch(timeclockControllerProvider);
    final notifier = ref.read(timeclockControllerProvider.notifier);

    // Dynamic UI state variables
    final isClockedIn = state.activeLog != null;
    final progressVal = state.accumulatedHours / state.targetHours;
    final formattedProgress = (progressVal * 100).clamp(0, 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: CivicHorizonTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(),
            Expanded(
              child: state.isLoading 
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    _buildDigitalClock(state),
                    const SizedBox(height: 48),
                    _buildStatusBar(isClockedIn),
                    const SizedBox(height: 48),
                    _buildActionButtons(isClockedIn, notifier),
                    const SizedBox(height: 48),
                    _buildProgressIndicator(state, formattedProgress),
                    const SizedBox(height: 100), // Scrolling clearance for BottomNav
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
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: CivicHorizonTheme.primaryContainer,
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

  Widget _buildDigitalClock(TimeclockState state) {
    // If clocked in, show their Clock In time. Else show current time (standard layout).
    final dt = state.activeLog != null ? DateTime.parse(state.activeLog!.timeIn) : DateTime.now();
    final timeStr = DateFormat('hh:mm').format(dt);
    final periodStr = DateFormat('a').format(dt);

    return Column(
      children: [
        Text(
          state.activeLog != null ? 'ACTIVE RESTRICTED SHIFT' : 'STANDARD TIME REGISTRY',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: CivicHorizonTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              timeStr,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: CivicHorizonTheme.primary,
                letterSpacing: -2.0,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              periodStr,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: CivicHorizonTheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBar(bool isClockedIn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusPill(
          Icons.location_on, 
          isClockedIn ? 'GPS: Locked' : 'GPS: Active',
          isClockedIn ? CivicHorizonTheme.primaryContainer : CivicHorizonTheme.onTertiaryFixedVariant,
        ),
        const SizedBox(width: 24),
        _buildStatusPill(
          Icons.camera_alt, 
          isClockedIn ? 'Camera: Saved' : 'Camera: Ready',
          isClockedIn ? CivicHorizonTheme.primaryContainer : CivicHorizonTheme.onTertiaryFixedVariant,
        ),
      ],
    );
  }

  Widget _buildStatusPill(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CivicHorizonTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: CivicHorizonTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isClockedIn, TimeclockController notifier) {
    return Column(
      children: [
        // Clock IN
        GestureDetector(
          onTap: isClockedIn ? null : () => notifier.clockIn(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isClockedIn ? CivicHorizonTheme.surfaceContainerLow : CivicHorizonTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: CivicHorizonTheme.ghostBorder,
              boxShadow: isClockedIn ? [] : CivicHorizonTheme.ambientGlow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SHIFT START',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isClockedIn ? CivicHorizonTheme.onSurfaceVariant : CivicHorizonTheme.onTertiaryFixedVariant,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CLOCK IN',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isClockedIn ? CivicHorizonTheme.outlineVariant : CivicHorizonTheme.tertiaryFixed,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isClockedIn ? CivicHorizonTheme.surfaceContainerHighest : CivicHorizonTheme.tertiaryFixedDim,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.camera_front,
                    color: isClockedIn ? CivicHorizonTheme.onSurfaceVariant : CivicHorizonTheme.onTertiaryFixedVariant,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Clock OUT
        GestureDetector(
          onTap: !isClockedIn ? null : () => notifier.clockOut(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: !isClockedIn ? CivicHorizonTheme.surfaceContainerLow : CivicHorizonTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: !isClockedIn ? CivicHorizonTheme.surfaceContainerHighest : CivicHorizonTheme.error,
                  width: 4,
                ),
              ),
              boxShadow: !isClockedIn ? [] : CivicHorizonTheme.ambientGlow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'END REGISTRY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: !isClockedIn ? CivicHorizonTheme.outlineVariant : CivicHorizonTheme.onSurfaceVariant,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CLOCK OUT',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: !isClockedIn ? CivicHorizonTheme.outlineVariant : CivicHorizonTheme.error,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.stop_circle,
                  color: !isClockedIn ? CivicHorizonTheme.outlineVariant : CivicHorizonTheme.error,
                  size: 32,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(TimeclockState state, String formattedProgress) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: CivicHorizonTheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HOURGLASS PROGRESS',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: CivicHorizonTheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    state.accumulatedHours.toStringAsFixed(1), // Reactive Hours
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: CivicHorizonTheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '/ ${state.targetHours} Hours',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: CivicHorizonTheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'COMPLETED THIS CYCLE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: CivicHorizonTheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: CircularProgressIndicator(
                  value: state.accumulatedHours / state.targetHours, // Reactive Tracker
                  strokeWidth: 8,
                  backgroundColor: CivicHorizonTheme.primaryContainer,
                  color: CivicHorizonTheme.tertiaryFixedDim,
                ),
              ),
              Text(
                '$formattedProgress%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: CivicHorizonTheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
