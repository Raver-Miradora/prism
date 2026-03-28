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

  /// Retrieve all reports for a specific year-month
  Future<List<DailyReport>> getReportsForMonth(int year, int month) async {
    final db = await _dbHelper.database;
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final endDay = DateTime(year, month + 1, 0).day;
    final endDate = '$year-${month.toString().padLeft(2, '0')}-${endDay.toString().padLeft(2, '0')}';
    
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_reports',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );

    return maps.map((m) => DailyReport.fromMap(m)).toList();
  }
}
