import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/civic_horizon_theme.dart';
import '../controllers/timeclock_controller.dart';
import '../services/app_feedback.dart';
import 'widgets/prism_drawer.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/clock_in_widget.dart';
import 'widgets/progress_ring_widget.dart';
import 'widgets/dtr_heatmap_card.dart';
import 'widgets/prism_mentor_bottom_sheet.dart';
import '../services/security_service.dart';
import '../controllers/reports_controller.dart';

class DashboardTimeclock extends ConsumerStatefulWidget {
  const DashboardTimeclock({super.key});

  @override
  ConsumerState<DashboardTimeclock> createState() => _DashboardTimeclockState();
}

class _DashboardTimeclockState extends ConsumerState<DashboardTimeclock> {
  // W8 Fix: Create the clock stream ONCE in initState, not on every build()
  late final Stream<DateTime> _clockStream;

  @override
  void initState() {
    super.initState();
    _clockStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now().toUtc().add(const Duration(hours: 8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timeclockControllerProvider);
    final notifier = ref.read(timeclockControllerProvider.notifier);
    final autoTimeAsync = ref.watch(autoTimeProvider);
    final isAutoTimeEnabled = autoTimeAsync.value ?? true; // Default to true during loading to avoid flicker

    // Error listener
    ref.listen(timeclockControllerProvider.select((s) => s.errorMessage), (prev, next) {
      if (next != null && next.isNotEmpty && mounted) {
        AppFeedback.showError(context, next);
        notifier.clearError();
      }
    });

    final isClockedIn = state.activeLog != null;

    return Scaffold(
      backgroundColor: context.colors.surface,
      drawer: const PrismDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: const PrismMentorBottomSheet(),
            ),
          );
        },
        backgroundColor: context.colors.primary,
        child: Icon(Icons.auto_awesome, color: context.colors.onPrimary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(context),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0, bottom: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        _buildDigitalClock(context, state),
                        const SizedBox(height: 32),
                        if (!isAutoTimeEnabled) _buildSecurityLockBanner(context),
                        const SizedBox(height: 16),
                        _buildStatusBar(context, isClockedIn),
                        const SizedBox(height: 32),
                        _buildActionButtons(context, isClockedIn, notifier, state, isAutoTimeEnabled),
                        const SizedBox(height: 16),
                        _buildLogAbsenceButton(context, ref),
                        const SizedBox(height: 32),
                        ProgressRingWidget(
                          accumulatedHours: state.accumulatedHours,
                          targetHours: state.targetHours.toDouble(),
                        ),
                        const SizedBox(height: 32),
                        const DtrHeatmapCard(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                  if (state.isLoading)
                    Container(
                      color: Colors.black12,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
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
    if (state.activeLog != null && state.activeLog!.amArrivalTime != null) {
      final dtStart = DateTime.parse(state.activeLog!.amArrivalTime!).toUtc().add(const Duration(hours: 8));
      sessionStart = 'STARTED AT ${DateFormat('hh:mm:ss a').format(dtStart)}';
    }

    // Always show real-time ticking clock using the persistent stream from initState
    return StreamBuilder<DateTime>(
      stream: _clockStream,
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

  Widget _buildActionButtons(BuildContext context, bool isClockedIn, TimeclockController notifier, TimeclockState state, bool isAutoTimeEnabled) {
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
                  onChanged: (val) {
                    if (val) {
                      _showFieldworkAuthorizationDialog(context, notifier);
                    } else {
                      notifier.toggleFieldworkMode(false);
                    }
                  },
                  activeThumbColor: context.colors.tertiary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Standardized Single Punch Button
        ClockInWidget(
          onPressed: isAutoTimeEnabled ? () => notifier.punchTimeclock() : null,
          title: title,
          overline: overline,
          icon: icon,
          iconBgColor: isAutoTimeEnabled ? iconBgColor : context.colors.outline,
          iconColor: iconColor,
          isErrorStyle: state.punchPhase == PunchPhase.pmOut,
        ),
      ],
    );
  }

  Widget _buildLogAbsenceButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => _showLogAbsenceDialog(context, ref),
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colors.onSurfaceVariant,
        side: BorderSide(color: context.colors.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(Icons.edit_calendar_outlined, size: 18, color: context.colors.onSurfaceVariant),
      label: Text(
        'Log Absence / Leave / Holiday',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }

  void _showLogAbsenceDialog(BuildContext context, WidgetRef ref) {
    DateTime selectedDate = DateTime.now().toUtc().add(const Duration(hours: 8));
    String selectedStatus = 'ABSENT';
    // Controller now owned by the dialog's lifetime via onClosed disposal
    final remarksController = TextEditingController();

    final statusOptions = {
      'ABSENT': 'Absent',
      'EXCUSED': 'Excused / Leave',
      'HOLIDAY_FULL': 'Holiday (Whole Day)',
      'HOLIDAY_AM': 'Holiday (AM Only)',
      'HOLIDAY_PM': 'Holiday (PM Only)',
    };

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                  if (picked != null) setDialogState(() => selectedDate = picked);
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Attendance Status',
                  labelStyle: TextStyle(fontSize: 12),
                  border: OutlineInputBorder(),
                ),
                items: statusOptions.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 14))))
                    .toList(),
                onChanged: (val) => setDialogState(() => selectedStatus = val!),
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
                final remarks = remarksController.text;
                await ref.read(timeclockControllerProvider.notifier).logAttendanceStatus(
                  selectedDate,
                  selectedStatus,
                  remarks,
                );
                // Also refresh the Reports screen if open
                ref.read(reportsControllerProvider.notifier).loadData(
                  ref.read(reportsControllerProvider).selectedYear,
                  ref.read(reportsControllerProvider).selectedMonth,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    ).whenComplete(remarksController.dispose); // ✅ Dispose guaranteed on close
  }

  void _showFieldworkAuthorizationDialog(BuildContext context, TimeclockController notifier) {
    final locController = TextEditingController();
    final purposeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.gavel, color: context.colors.error, size: 24),
            const SizedBox(width: 12),
            Text('Fieldwork Authorization', style: context.text.titleLarge),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please provide the mandatory details for your deployment site today.',
                style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: locController,
                decoration: InputDecoration(
                  labelText: 'LOCATION NAME / SITE',
                  labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: context.colors.primary),
                  hintText: 'e.g. City Plaza, Regional Hub...',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: purposeController,
                decoration: InputDecoration(
                  labelText: 'OFFICIAL PURPOSE',
                  labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: context.colors.primary),
                  hintText: 'e.g. Stakeholder meeting, site audit...',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.errorContainer.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.colors.error.withAlpha(50)),
                ),
                child: Column(
                  children: [
                    Text(
                      'LEGAL WARNING',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: context.colors.error),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fieldwork logs are flagged for physical supervisor verification. Falsifying government time records is a violation of deployment terms.',
                      style: TextStyle(fontSize: 11, color: context.colors.error, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: TextStyle(color: context.colors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                notifier.toggleFieldworkMode(
                  true,
                  location: locController.text,
                  purpose: purposeController.text,
                );
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
            ),
            child: const Text('I AGREE & PROCEED'),
          ),
        ],
      ),
    ).whenComplete(() {
      // ✅ Both controllers disposed deterministically when dialog closes
      locController.dispose();
      purposeController.dispose();
    });
  }

  Widget _buildSecurityLockBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.errorContainer.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.error, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.security_update_warning, color: context.colors.onErrorContainer, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SECURITY LOCK',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: context.colors.onErrorContainer,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Enable 'Automatic Date & Time' in Android Settings to log attendance.",
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.onErrorContainer,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
