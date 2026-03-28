import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/time_log.dart';
import '../../data/models/daily_report.dart';
import '../../data/models/intern_profile.dart';
import '../../data/models/intern_settings.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('prism.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE intern_profile ADD COLUMN profile_image_path TEXT');
      } catch (e) {
        // Ignore if column already exists
      }
    }
  }

  Future _createDB(Database db, int version) async {
    // time_logs
    await db.execute('''
      CREATE TABLE time_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        time_in TEXT NOT NULL,
        time_out TEXT,
        latitude_in REAL NOT NULL,
        longitude_in REAL NOT NULL,
        latitude_out REAL,
        longitude_out REAL,
        photo_path_in TEXT NOT NULL,
        photo_path_out TEXT,
        sync_status INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // daily_reports
    await db.execute('''
      CREATE TABLE daily_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        raw_notes TEXT NOT NULL,
        formal_report TEXT
      )
    ''');

    // intern_profile
    await db.execute('''
      CREATE TABLE intern_profile (
        name TEXT NOT NULL,
        agency_office TEXT NOT NULL,
        supervisor_name TEXT NOT NULL,
        profile_image_path TEXT
      )
    ''');

    // intern_settings (Singleton row logic)
    await db.execute('''
      CREATE TABLE intern_settings (
        id INTEGER PRIMARY KEY,
        target_hours INTEGER NOT NULL,
        expected_time_in TEXT NOT NULL,
        expected_time_out TEXT NOT NULL,
        lunch_break_mins INTEGER NOT NULL
      )
    ''');

    // Insert Default Settings
    await db.insert('intern_settings', {
      'id': 1,
      'target_hours': 486,
      'expected_time_in': '08:00',
      'expected_time_out': '17:00',
      'lunch_break_mins': 60,
    });
    
    // Insert Default Profile Setup
    await db.insert('intern_profile', {
      'name': '',
      'agency_office': '',
      'supervisor_name': '',
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
