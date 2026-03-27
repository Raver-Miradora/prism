import 'package:intl/intl.dart';
import '../../data/models/time_log.dart';
import '../../data/models/intern_settings.dart';

class HourglassEngine {
  /// Calculates the accumulated hours for a single [TimeLog]
  /// Deducts lunch break if the shift duration exceeded 4 hours.
  static double calculateActualHours(TimeLog log, InternSettings settings) {
    if (log.timeOut == null) return 0.0;

    final In = DateTime.parse(log.timeIn);
    final Out = DateTime.parse(log.timeOut!);
    
    final difference = Out.difference(In);
    double totalHours = difference.inMinutes / 60.0;

    // Standard Philippine Civil Service rule: Deduct lunch break (usually 1 hr)
    // if work extended past noon and duration is typically over 4 hours.
    if (totalHours > 4.0) {
      totalHours -= (settings.lunchBreakMins / 60.0);
    }

    // Floor to nearest two decimals
    return double.parse(totalHours.toStringAsFixed(2));
  }

  /// Calculates total minute-based tardiness.
  /// Compares actual `timeIn` against `expectedTimeIn` (e.g. "08:00")
  static int calculateLateDeductions(TimeLog log, String expectedInTime) {
    final In = DateTime.parse(log.timeIn);
    
    try {
      final formatter = DateFormat("HH:mm");
      final expectedTimeParsed = formatter.parse(expectedInTime);
      final expectedDateTime = DateTime(
        In.year, In.month, In.day, 
        expectedTimeParsed.hour, expectedTimeParsed.minute
      );

      final difference = In.difference(expectedDateTime);
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
