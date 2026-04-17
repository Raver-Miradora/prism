import 'package:intl/intl.dart';
import '../../data/models/time_log.dart';
import '../../data/models/intern_settings.dart';

class HourglassEngine {
  /// Consistent parsing helper that returns Unix Epoch if malformed to prevent crashes
  static DateTime safeParse(String? dateStr, [DateTime? fallback]) {
    if (dateStr == null || dateStr.isEmpty) return fallback ?? DateTime(1970);
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return fallback ?? DateTime(1970);
    }
  }

  /// Calculates the accumulated hours for a single [TimeLog]
  static double calculateActualHours(TimeLog log, InternSettings settings) {
    if (isMissedPunch(log)) return 0.0;
    
    double totalHours = 0.0;

    if (log.amArrivalTime != null && log.pmDepartureTime != null) {
      final start = safeParse(log.amArrivalTime);
      final end = safeParse(log.pmDepartureTime);
      totalHours = end.difference(start).inMinutes / 60.0;
      
      // Apply 1-hour lunch break deduction if shift length > 5 hours
      if (totalHours > 5.0) {
        totalHours -= 1.0;
      }
    }

    // Philippines Government 4-Day Workweek Logic (GIP Program)
    if (settings.programType == 'GIP') {
      final firstTime = log.amArrivalTime != null ? safeParse(log.amArrivalTime) : null;
      if (firstTime != null && (firstTime.weekday == DateTime.friday || 
          firstTime.weekday == DateTime.saturday || 
          firstTime.weekday == DateTime.sunday)) {
        return 0.0;
      }
    }

    return double.parse(totalHours.clamp(0.0, 24.0).toStringAsFixed(2));
  }

  /// Calculates total minute-based tardiness.
  static int calculateLateDeductions(TimeLog log, String expectedInTime) {
    if (log.amArrivalTime == null) return 0;
    
    final inTime = safeParse(log.amArrivalTime);
    if (inTime.year == 1970) return 0; // Invalid parse
    
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
    } catch (_) {}
    return 0;
  }

  /// Calculates the officially rendered hours according to government DTR rules.
  static double calculateDtrRenderedHours(TimeLog log, InternSettings settings) {
    if (isMissedPunch(log)) return 0.0;
    if (log.amArrivalTime == null || log.pmDepartureTime == null) return 0.0;
    
    // 1. Calculate Late Arrival (Tardiness)
    int lateMinutes = calculateLateDeductions(log, settings.expectedTimeIn);
    
    // 2. Calculate Early Departure
    int earlyMinutes = 0;
    try {
      final timeOut = safeParse(log.pmDepartureTime);
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
    if (log.status != 'WORK') return false;
    final bool isIncomplete = log.amArrivalTime != null && log.pmDepartureTime == null;
    if (!isIncomplete) return false;

    try {
      if (log.date.isEmpty) return false;
      final logDate = safeParse(log.date);
      if (logDate.year == 1970) return false;
      
      final now = DateTime.now().toUtc().add(const Duration(hours: 8));
      final today = DateTime(now.year, now.month, now.day);
      
      return logDate.isBefore(today);
    } catch (_) {
      return false;
    }
  }
}
