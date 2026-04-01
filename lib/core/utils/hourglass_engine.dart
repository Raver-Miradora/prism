import 'package:intl/intl.dart';
import '../../data/models/time_log.dart';
import '../../data/models/intern_settings.dart';

class HourglassEngine {
  /// Calculates the accumulated hours for a single [TimeLog]
  /// Deducts lunch break if the shift duration exceeded 4 hours.
  /// Calculates the accumulated hours for a single [TimeLog]
  /// Deducts lunch break if the shift duration exceeded 4 hours.
  static double calculateActualHours(TimeLog log, InternSettings settings) {
    if (log.timeIn == null || log.timeOut == null) return 0.0;

    final In = DateTime.parse(log.timeIn!);
    final Out = DateTime.parse(log.timeOut!);
    
    // Philippines Government 4-Day Workweek Logic (Starting March 9, 2026)
    // GIP interns typically work Mon-Thu to ensure a 40-hour week (10hr/day).
    // Fridays are technically non-working for this scheme.
    if (settings.programType == 'GIP') {
      if (In.weekday == DateTime.friday || 
          In.weekday == DateTime.saturday || 
          In.weekday == DateTime.sunday) {
        return 0.0;
      }
    }

    final difference = Out.difference(In);
    double totalHours = difference.inMinutes / 60.0;

    // Standard Rule: Deduct lunch break (typically 1 hr) if work > 4 hours
    if (totalHours > 4.0) {
      totalHours -= (settings.lunchBreakMins / 60.0);
    }

    return double.parse(totalHours.toStringAsFixed(2));
  }

  /// Calculates total minute-based tardiness.
  /// Compares actual `timeIn` against `expectedTimeIn` (e.g. "08:00")
  static int calculateLateDeductions(TimeLog log, String expectedInTime) {
    if (log.timeIn == null) return 0;
    
    final In = DateTime.parse(log.timeIn!);
    
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
    } catch (e) {
       // fallback if format parsing fails
    }
    return 0;
  }
}
