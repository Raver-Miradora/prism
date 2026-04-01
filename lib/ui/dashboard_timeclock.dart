import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/civic_horizon_theme.dart';
import '../controllers/timeclock_controller.dart';
import '../core/utils/snackbar_utils.dart';
import 'widgets/prism_drawer.dart';
import 'widgets/profile_avatar.dart';

class DashboardTimeclock extends ConsumerWidget {
  const DashboardTimeclock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timeclockControllerProvider);
    final notifier = ref.read(timeclockControllerProvider.notifier);

    // Error listener
    ref.listen(timeclockControllerProvider.select((s) => s.errorMessage), (prev, next) {
      if (next != null && next.isNotEmpty) {
        SnackbarUtils.showError(context, next);
        notifier.clearError();
      }
    });

    final isClockedIn = state.activeLog != null;
    final progressVal = state.accumulatedHours / state.targetHours;
    final formattedProgress = (progressVal * 100).clamp(0, 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: context.colors.surface,
      drawer: const PrismDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(context),
            Expanded(
              child: state.isLoading 
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    _buildDigitalClock(context, state),
                    const SizedBox(height: 48),
                    _buildStatusBar(context, isClockedIn),
                    const SizedBox(height: 48),
                    _buildActionButtons(context, isClockedIn, notifier, state),
                    const SizedBox(height: 48),
                    _buildProgressIndicator(context, state, formattedProgress),
                    const SizedBox(height: 100),
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
                style: context.text.headlineLarge?.copyWith(
                  fontSize: 20,
                  letterSpacing: -1.0,
                ),
              ),
            ],
          ),
          const ProfileAvatar(size: 44),
        ],
      ),
    );
  }

  Widget _buildDigitalClock(BuildContext context, TimeclockState state) {
    String? sessionStart;
    if (state.activeLog != null && state.activeLog!.timeIn != null) {
      final dtStart = DateTime.parse(state.activeLog!.timeIn!).toUtc().add(const Duration(hours: 8));
      sessionStart = 'STARTED AT ${DateFormat('hh:mm:ss a').format(dtStart)}';
    }

    // Always show real-time ticking clock
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now().toUtc().add(const Duration(hours: 8))),
      builder: (ctx, snapshot) {
        final dt = snapshot.data ?? DateTime.now().toUtc().add(const Duration(hours: 8));
        String label = state.activeLog != null 
            ? (state.activeLog!.isFieldwork ? 'ACTIVE FIELDWORK SHIFT' : 'ACTIVE RESTRICTED SHIFT')
            : 'STANDARD TIME REGISTRY';
        
        return _buildStaticClockUI(context, dt, label, subtitle: sessionStart);
      },
    );
  }

  Widget _buildStaticClockUI(BuildContext context, DateTime dt, String label, {String? subtitle}) {
    final timeStr = DateFormat('hh:mm').format(dt);
    final secStr = DateFormat(':ss').format(dt);
    final periodStr = DateFormat('a').format(dt);

    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: context.colors.onSurfaceVariant,
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
              style: context.text.displayLarge?.copyWith(fontSize: 72, letterSpacing: -2.0),
            ),
            Text(
              secStr,
              style: context.text.displayMedium?.copyWith(
                fontSize: 32,
                color: context.colors.outlineVariant,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              periodStr,
              style: context.text.displayMedium?.copyWith(
                fontSize: 24,
                color: context.colors.tertiary,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBar(BuildContext context, bool isClockedIn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusPill(
          context,
          Icons.location_on, 
          isClockedIn ? 'GPS: Locked' : 'GPS: Active',
          isClockedIn ? context.colors.primary : context.colors.secondary,
        ),
        const SizedBox(width: 24),
        _buildStatusPill(
          context,
          Icons.camera_alt, 
          isClockedIn ? 'Liveness: Verified' : 'Liveness: Required',
          isClockedIn ? context.colors.primary : context.colors.secondary,
        ),
      ],
    );
  }

  Widget _buildStatusPill(BuildContext context, IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isClockedIn, TimeclockController notifier, TimeclockState state) {
    if (state.punchPhase == PunchPhase.done) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.outlineVariant.withAlpha(50)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: context.colors.primary),
              const SizedBox(width: 12),
              Text(
                'SHIFT COMPLETED',
                style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.primary, letterSpacing: 1.0),
              ),
            ],
          ),
        ),
      );
    }

    String overline = '';
    String title = '';
    IconData icon = Icons.camera_front;
    Color iconBgColor = context.colors.primary;
    Color iconColor = context.colors.onPrimary;

    switch (state.punchPhase) {
      case PunchPhase.amIn:
        overline = state.isFieldworkMode ? 'OFF-SITE FIELDWORK' : 'MORNING ARRIVAL';
        title = 'CLOCK IN (AM)';
        iconBgColor = context.colors.primary;
        break;
      case PunchPhase.lunchOut:
        overline = 'MIDDAY DEPARTURE';
        title = 'START LUNCH BREAK';
        icon = Icons.restaurant;
        iconBgColor = context.colors.tertiary;
        break;
      case PunchPhase.lunchIn:
        overline = 'AFTERNOON RETURN';
        title = 'END LUNCH BREAK';
        iconBgColor = context.colors.primary;
        break;
      case PunchPhase.pmOut:
        overline = 'END REGISTRY';
        title = 'CLOCK OUT (PM)';
        icon = Icons.stop_circle;
        iconBgColor = context.colors.error;
        break;
      case PunchPhase.done:
        break;
    }

    return Column(
      children: [
        if (state.punchPhase == PunchPhase.amIn) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: state.isFieldworkMode 
                  ? context.colors.tertiaryContainer.withAlpha(40)
                  : context.colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: state.isFieldworkMode ? context.colors.tertiary : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.terrain, 
                      size: 20, 
                      color: state.isFieldworkMode ? context.colors.tertiary : context.colors.onSurfaceVariant
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'FIELDWORK OFF-SITE MODE',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: context.colors.onSurfaceVariant,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: state.isFieldworkMode, 
                  onChanged: (val) => notifier.toggleFieldworkMode(val),
                  activeColor: context.colors.tertiary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Dynamic Single Punch Button
        GestureDetector(
          onTap: state.isLoading ? null : () => notifier.punchTimeclock(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: state.isFieldworkMode && state.punchPhase == PunchPhase.amIn
                  ? Border.all(color: context.colors.tertiary, width: 2)
                  : CivicHorizonTheme.ghostBorder(context),
              boxShadow: CivicHorizonTheme.ambientGlow(context),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overline,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: context.colors.primary,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: state.punchPhase == PunchPhase.pmOut ? context.colors.error : context.colors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: state.isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(
                    icon,
                    color: iconColor,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(BuildContext context, TimeclockState state, String formattedProgress) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HOURGLASS PROGRESS',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: context.colors.onPrimary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    state.accumulatedHours.toStringAsFixed(1),
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: context.colors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '/ ${state.targetHours} Hours',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.colors.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'COMPLETED THIS CYCLE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: context.colors.onPrimary.withOpacity(0.7),
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
                  value: state.accumulatedHours / state.targetHours,
                  strokeWidth: 8,
                  backgroundColor: context.colors.onPrimary.withOpacity(0.1),
                  color: context.colors.tertiary,
                ),
              ),
              Text(
                '$formattedProgress%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: context.colors.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
