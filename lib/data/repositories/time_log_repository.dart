import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/time_log.dart';

class TimeLogRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> insertLog(TimeLog log) async {
    final db = await _dbHelper.database;
    await db.insert(
      'time_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateLog(TimeLog log) async {
    final db = await _dbHelper.database;
    await db.update(
      'time_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  /// Returns the log for today, if it exists.
  Future<TimeLog?> getActiveLogForToday(String dateISO) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'time_logs',
      where: 'date = ?',
      whereArgs: [dateISO],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return TimeLog.fromMap(maps.first);
    }
    return null;
  }

  /// Sum the accumulated minutes over all completed logs
  Future<double> getAccumulatedHours() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'time_logs',
    );

    double total = 0.0;
    // Fast loop summing durations
    for (var m in maps) {
       try {
          double dayTotal = 0.0;
          if (m['am_in'] != null && m['am_out'] != null) {
              final inTime = DateTime.parse(m['am_in']);
              final outTime = DateTime.parse(m['am_out']);
              dayTotal += outTime.difference(inTime).inMinutes / 60.0;
          }
          if (m['pm_in'] != null && m['pm_out'] != null) {
              final inTime = DateTime.parse(m['pm_in']);
              final outTime = DateTime.parse(m['pm_out']);
              dayTotal += outTime.difference(inTime).inMinutes / 60.0;
          }
          total += dayTotal;
       } catch (_) {}
    }
    return total;
  }

  /// Get all logs for a specific year and month
  Future<List<TimeLog>> getLogsForMonth(int year, int month) async {
    final db = await _dbHelper.database;
    final String paddedMonth = month.toString().padLeft(2, '0');
    final String prefix = "$year-$paddedMonth-";

    final List<Map<String, dynamic>> maps = await db.query(
      'time_logs',
      where: 'date LIKE ?',
      whereArgs: ['$prefix%'],
      orderBy: 'date ASC',
    );

    return maps.map((m) => TimeLog.fromMap(m)).toList();
  }
}
