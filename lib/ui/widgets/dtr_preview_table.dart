import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/time_log.dart';
import '../../data/models/intern_settings.dart';
import '../../core/utils/hourglass_engine.dart';
import '../../core/theme/civic_horizon_theme.dart';

class DtrPreviewTable extends StatelessWidget {
  final List<TimeLog> logs;
  final InternSettings settings;
  final int year;
  final int month;

  const DtrPreviewTable({
    super.key,
    required this.logs,
    required this.settings,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    // Map logs to day indices
    final Map<int, TimeLog> logMap = {};
    for (var log in logs) {
      final d = DateTime.parse(log.date);
      if (d.year == year && d.month == month) {
        logMap[d.day] = log;
      }
    }

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final timeFormatter = DateFormat('hh:mm');

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.outlineVariant.withAlpha(50)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            horizontalMargin: 12,
            headingRowHeight: 40,
            dataRowMinHeight: 32,
            dataRowMaxHeight: 32,
            headingTextStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
            columns: const [
              DataColumn(label: Text('Day')),
              DataColumn(label: Text('AM Arrival')),
              DataColumn(label: Text('PM Departure')),
              DataColumn(label: Text('Late (m)')),
            ],
            rows: List.generate(daysInMonth, (index) {
              final day = index + 1;
              final log = logMap[day];

              String amArrival = '-';
              String pmDeparture = '-';
              String lateMins = '-';

              if (log != null) {
                if (log.status != 'WORK') {
                  amArrival = log.status;
                } else {
                  if (log.amArrivalTime != null) {
                    amArrival = timeFormatter.format(DateTime.parse(log.amArrivalTime!));
                  }
                  if (log.pmDepartureTime != null) {
                    pmDeparture = timeFormatter.format(DateTime.parse(log.pmDepartureTime!));
                  }
                  
                  final late = HourglassEngine.calculateLateDeductions(log, settings.expectedTimeIn);
                  if (late > 0) lateMins = '$late';
                }
              }

              return DataRow(cells: [
                DataCell(Text('$day', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                DataCell(Text(amArrival, style: const TextStyle(fontSize: 11))),
                DataCell(Text(pmDeparture, style: const TextStyle(fontSize: 11))),
                DataCell(Text(lateMins, style: TextStyle(fontSize: 11, color: lateMins != '-' ? Colors.red : null))),
              ]);
            }),
          ),
        ),
      ),
    );
  }
}
