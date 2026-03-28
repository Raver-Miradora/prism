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

  /// Returns the *active* uncompleted log for today (has timeOut == null).
  Future<TimeLog?> getActiveLogForToday(String dateISO) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'time_logs',
      where: 'date = ? AND time_out IS NULL',
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
      where: 'time_out IS NOT NULL',
    );

    double total = 0.0;
    // Fast loop summing durations
    for (var m in maps) {
       try {
          final inTime = DateTime.parse(m['time_in']);
          final outTime = DateTime.parse(m['time_out']);
          var diff = outTime.difference(inTime).inMinutes.toDouble();
          
          if (diff > 240) { // Over 4 hours assumes lunch
             diff -= 60; // Usually 1 hour logic, could sync to InternSettings later
          }

          total += diff / 60.0;
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
