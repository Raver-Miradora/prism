import 'package:intl/intl.dart';
import '../../data/models/time_log.dart';
import '../../data/models/intern_settings.dart';

class HourglassEngine {
  /// Calculates the accumulated hours for a single [TimeLog]
  /// Sums total elapsed time from amArrivalTime to pmDepartureTime.
  /// Deducts 1 hour if the elapsed time exceeds 5 hours (lunch break).
  static double calculateActualHours(TimeLog log, InternSettings settings) {
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
}
