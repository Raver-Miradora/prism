import 'package:intl/intl.dart';
import '../../data/models/time_log.dart';
import '../../data/models/intern_settings.dart';

class HourglassEngine {
  /// Calculates the accumulated hours for a single [TimeLog]
  /// Sums total elapsed time from amArrivalTime to pmDepartureTime.
  /// Deducts 1 hour if the elapsed time exceeds 5 hours (lunch break).
  static double calculateActualHours(TimeLog log, InternSettings settings) {
    if (isMissedPunch(log)) return 0.0;
    
    double totalHours = 0.0;

    if (log.amArrivalTime != null && log.pmDepartureTime != null) {
      final start = DateTime.parse(log.amArrivalTime!);
      final end = DateTime.parse(log.pmDepartureTime!);
      totalHours = end.difference(start).inMinutes / 60.0;
      
      // Apply 1-hour lunch break deduction if shift length > 5 hours
      if (totalHours > 5.0) {
        totalHours -= 1.0;
      }
    }

    // Philippines Government 4-Day Workweek Logic (GIP Program)
    if (settings.programType == 'GIP') {
      final firstTime = log.amArrivalTime != null ? DateTime.parse(log.amArrivalTime!) : null;
      if (firstTime != null && (firstTime.weekday == DateTime.friday || 
          firstTime.weekday == DateTime.saturday || 
          firstTime.weekday == DateTime.sunday)) {
        return 0.0;
      }
    }

    return double.parse(totalHours.clamp(0.0, 24.0).toStringAsFixed(2));
  }

  /// Calculates total minute-based tardiness.
  /// Compares actual `amArrivalTime` against `expectedTimeIn` (e.g. "08:00")
  static int calculateLateDeductions(TimeLog log, String expectedInTime) {
    if (log.amArrivalTime == null) return 0;
    
    final inTime = DateTime.parse(log.amArrivalTime!);
    
    try {
      final formatter = DateFormat("HH:mm");
      final expectedTimeParsed = formatter.parse(expectedInTime);
      final expectedDateTime = DateTime(
        inTime.year, inTime.month, inTime.day, 
        expectedTimeParsed.hour, expectedTimeParsed.minute
      );

      final difference = inTime.difference(expectedDateTime);
      // Only count late minutes, not early arrivals
      if (difference.inMinutes > 0) {
        return difference.inMinutes;
      }
    } catch (_) {
       // fallback if format parsing fails
    }
    return 0;
  }

  /// Calculates the officially rendered hours according to government DTR rules.
  /// Standard shift is assumed to be 8 hours. Excess minutes (overtime) are ignored.
  /// Late arrivals and early departures are considered undertime and deducted.
  static double calculateDtrRenderedHours(TimeLog log, InternSettings settings) {
    if (isMissedPunch(log)) return 0.0;
    if (log.amArrivalTime == null || log.pmDepartureTime == null) return 0.0;
    
    // 1. Calculate Late Arrival (Tardiness)
    int lateMinutes = calculateLateDeductions(log, settings.expectedTimeIn);
    
    // 2. Calculate Early Departure
    int earlyMinutes = 0;
    try {
      final timeOut = DateTime.parse(log.pmDepartureTime!);
      final expectedOut = DateFormat('HH:mm').parse(settings.expectedTimeOut);
      final expectedOutDT = DateTime(timeOut.year, timeOut.month, timeOut.day, expectedOut.hour, expectedOut.minute);
      final diffOut = expectedOutDT.difference(timeOut);
      if (diffOut.inMinutes > 0) earlyMinutes = diffOut.inMinutes;
    } catch (_) {}
    
    // 3. Deduct total undertime from the standard 8.0 hours
    int totalUndertime = lateMinutes + earlyMinutes;
    double expectedShiftHours = 8.0;
    
    double renderedHours = expectedShiftHours - (totalUndertime / 60.0);
    return renderedHours < 0.0 ? 0.0 : double.parse(renderedHours.toStringAsFixed(2));
  }

  /// Detects if a punch is "Orphaned" (Incomplete and in the past).
  static bool isMissedPunch(TimeLog log) {
    // If status is not WORK (e.g. ABSENT, HOLIDAY), it's not a "missed punch" in this context
    if (log.status != 'WORK') return false;

    // Check if entry is incomplete
    final bool isIncomplete = log.amArrivalTime != null && log.pmDepartureTime == null;
    if (!isIncomplete) return false;

    // Validate if the record belongs to a previous day
    try {
      if (log.date.isEmpty) return false;
      final logDate = DateTime.parse(log.date);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // If it happened before today and is still incomplete, it's missed.
      return logDate.isBefore(today);
    } catch (_) {
      return false;
    }
  }
}
