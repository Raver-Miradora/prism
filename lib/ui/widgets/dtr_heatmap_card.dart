import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../controllers/reports_controller.dart';
import '../../core/theme/civic_horizon_theme.dart';
import '../../core/utils/hourglass_engine.dart';
import '../../data/models/intern_settings.dart';

class DtrHeatmapCard extends ConsumerWidget {
  const DtrHeatmapCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsControllerProvider);
    final notifier = ref.read(reportsControllerProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final isCurrentMonth = state.selectedYear == now.year && state.selectedMonth == now.month;

    final firstDayOfMonth = DateTime(state.selectedYear, state.selectedMonth, 1);
    final monthName = DateFormat('MMMM yyyy').format(firstDayOfMonth);
    final daysInMonth = DateTime(state.selectedYear, state.selectedMonth + 1, 0).day;
    
    // Calendar alignment: Sunday = 0
    final startingWeekday = firstDayOfMonth.weekday % 7; 
    
    final logs = state.logsStatus.valueOrNull ?? [];
    
    // Robust log mapping
    final Map<int, dynamic> logMap = {};
    for (var log in logs) {
      try {
        final date = DateTime.parse(log.date);
        logMap[date.day] = log;
      } catch (_) {}
    }
    
    final settings = state.settingsStatus.valueOrNull;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: CivicHorizonTheme.ghostBorder(context),
        boxShadow: CivicHorizonTheme.ambientGlow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, notifier, colors, monthName, isCurrentMonth),
          const SizedBox(height: 20),
          _buildWeekdayHeaders(context),
          const SizedBox(height: 8),
          if (state.logsStatus.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(strokeWidth: 2)))
          else
            _buildCalendarGrid(context, colors, startingWeekday, daysInMonth, logMap, settings, state),
          const SizedBox(height: 20),
          _buildHeatmapLegend(context, colors),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ReportsController notifier, ColorScheme colors, String monthName, bool isCurrentMonth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ATTENDANCE HEATMAP',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: context.colors.outline,
            letterSpacing: 1.5,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: () => notifier.changeMonth(-1),
              visualDensity: VisualDensity.compact,
              color: colors.primary,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                monthName.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: colors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: isCurrentMonth ? null : () => notifier.changeMonth(1),
              visualDensity: VisualDensity.compact,
              color: colors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((d) => SizedBox(
        width: 28,
        child: Center(
          child: Text(
            d,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: context.colors.outline.withValues(alpha: 0.5),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context, 
    ColorScheme colors, 
    int startingWeekday, 
    int daysInMonth, 
    Map<int, dynamic> logMap, 
    InternSettings? settings,
    ReportsState state,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: startingWeekday + daysInMonth,
      itemBuilder: (context, index) {
        if (index < startingWeekday) return const SizedBox.shrink();
        
        final day = index - startingWeekday + 1;
        final log = logMap[day];
        final date = DateTime(state.selectedYear, state.selectedMonth, day);
        final isFuture = date.isAfter(DateTime.now());
        final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
        
        Color squareColor = context.colors.surfaceContainerHighest;
        String tooltipText = '${DateFormat('EEEE, MMM d').format(date)}: No record';
        bool hasError = false;
        double hours = 0.0;
        
        if (log != null && settings != null) {
          final isMissed = HourglassEngine.isMissedPunch(log);
          if (isMissed) {
             hasError = true;
             squareColor = context.colors.errorContainer;
             tooltipText = '${DateFormat('EEEE, MMM d').format(date)}: Missed Punch! Zero hours credited for incomplete shift.';
          } else if (log.status == 'WORK') {
            hours = HourglassEngine.calculateDtrRenderedHours(log, settings);
            tooltipText = '${DateFormat('EEEE, MMM d').format(date)}: $hours hrs rendered';
            if (hours >= 8.0) {
              squareColor = colors.primary;
            } else if (hours > 0) {
              squareColor = colors.primary.withValues(alpha: 0.4);
            }
          } else {
            String statusLabel = log.status;
            if (statusLabel.startsWith('HOLIDAY')) statusLabel = 'Holiday';
            tooltipText = '${DateFormat('EEEE, MMM d').format(date)}: $statusLabel';
            squareColor = colors.tertiary.withValues(alpha: 0.4);
          }
        } else if (isFuture) {
          squareColor = colors.surface.withValues(alpha: 0.05);
        } else if (isWeekend) {
           tooltipText = '${DateFormat('EEEE, MMM d').format(date)}: Weekend';
           squareColor = context.colors.surfaceContainerHighest.withValues(alpha: 0.5);
        }

        final isPerfect = !hasError && hours >= 8.0;

        return Tooltip(
          message: tooltipText,
          triggerMode: TooltipTriggerMode.tap,
          preferBelow: false,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: squareColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: (hasError)
                ? [BoxShadow(color: context.colors.error.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))]
                : (isPerfect) 
                  ? [BoxShadow(color: colors.primary.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))]
                  : null,
              border: Border.all(
                color: hasError ? context.colors.error.withValues(alpha: 0.2) : colors.outline.withValues(alpha: 0.05),
                width: 1,
              ),
              gradient: (hasError)
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [context.colors.error, context.colors.errorContainer],
                  )
                : (isPerfect)
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.primary, colors.primary.withValues(alpha: 0.85)],
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: (isPerfect)
                    ? colors.onPrimary.withValues(alpha: 0.5)
                    : hasError 
                      ? context.colors.onError.withValues(alpha: 0.7)
                      : context.colors.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeatmapLegend(BuildContext context, ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _legendSquare(context.colors.errorContainer),
        const SizedBox(width: 4),
        Text('Missed', style: TextStyle(fontSize: 9, color: context.colors.outline)),
        const SizedBox(width: 12),
        Text('Less', style: TextStyle(fontSize: 9, color: context.colors.outline)),
        const SizedBox(width: 4),
        _legendSquare(context.colors.surfaceContainerHighest),
        _legendSquare(colors.primary.withValues(alpha: 0.4)),
        _legendSquare(colors.primary),
        const SizedBox(width: 4),
        Text('More', style: TextStyle(fontSize: 9, color: context.colors.outline)),
      ],
    );
  }

  Widget _legendSquare(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
