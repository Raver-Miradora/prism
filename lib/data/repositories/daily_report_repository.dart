import 'package:sqflite/sqflite.dart';
import '../models/daily_report.dart';
import '../../core/database/database_helper.dart';

class DailyReportRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert or logically update a daily report based on its date string
  Future<void> saveReport(DailyReport report) async {
    final db = await _dbHelper.database;
    
    // Check if report exists for this date to preserve ID if necessary
    final existing = await getReportByDate(report.date);

    if (existing != null) {
      await db.update(
        'daily_reports',
        report.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      await db.insert(
        'daily_reports',
        report.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Retrieve the single report for a specific ISO8601 date string
  Future<DailyReport?> getReportByDate(String dateStr) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_reports',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (maps.isNotEmpty) {
      return DailyReport.fromMap(maps.first);
    }
    return null;
  }
}
