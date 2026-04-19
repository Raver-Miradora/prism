import 'package:intl/intl.dart';

/// Centralized date utility for PRISM.
/// Eliminates duplicated date-formatting and UTC+8 computation across controllers and screens.
/// 
/// This extension provides standard formatting for [DateTime] objects to match
/// the SQLite key formats and human-readable display requirements.
extension PrismDateUtils on DateTime {
  /// Returns this DateTime formatted as 'yyyy-MM-dd'.
  /// This is the primary key format used in the PRISM journal and timeclock databases.
  String toIsoDate() => DateFormat('yyyy-MM-dd').format(this);

  /// Returns this DateTime formatted as a human-readable display string (e.g., 'April 19, 2026').
  /// Used for major headers and profile displays.
  String toDisplayDate() => DateFormat('MMMM dd, yyyy').format(this);

  /// Returns this DateTime formatted as a short day label (e.g., 'Apr 19').
  /// Used for small list items and recent history strips.
  String toShortDate() => DateFormat('MMM d').format(this);
}

/// Static helpers for PRISM datetime computations.
class PrismDate {
  PrismDate._(); // prevent instantiation

  /// Returns the current time in the Philippine timezone (UTC+8).
  /// Use this everywhere instead of duplicating the .toUtc().add(Duration(hours: 8)) pattern.
  static DateTime nowUtc8() =>
      DateTime.now().toUtc().add(const Duration(hours: 8));

  /// Returns the current date as an ISO string ('yyyy-MM-dd') in UTC+8.
  static String todayIso() => nowUtc8().toIsoDate();

  /// Parses an ISO date string safely. Returns null if the string is invalid or the sentinel value.
  static DateTime? tryParseDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty || isoDate == '1970-01-01') return null;
    try {
      return DateTime.parse(isoDate);
    } catch (_) {
      return null;
    }
  }
}
