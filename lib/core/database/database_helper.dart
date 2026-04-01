import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      version: 5,
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
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE intern_settings ADD COLUMN office_lat REAL');
        await db.execute('ALTER TABLE intern_settings ADD COLUMN office_lng REAL');
        await db.execute('ALTER TABLE intern_settings ADD COLUMN program_type TEXT DEFAULT "OJT"');
      } catch (e) {
        // Ignore if columns already exist
      }
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE time_logs ADD COLUMN is_fieldwork INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE time_logs ADD COLUMN status TEXT DEFAULT "WORK"');
        await db.execute('ALTER TABLE time_logs ADD COLUMN remarks TEXT');
      } catch (e) {
        // Ignore if columns already exist
      }
    }
    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE time_logs ADD COLUMN time_lunch_out TEXT');
        await db.execute('ALTER TABLE time_logs ADD COLUMN time_lunch_in TEXT');
      } catch (e) {
        // Ignore if columns already exist
      }
    }
  }

  Future _createDB(Database db, int version) async {
    // time_logs
    await db.execute('''
      CREATE TABLE time_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        time_in TEXT,
        time_lunch_out TEXT,
        time_lunch_in TEXT,
        time_out TEXT,
        latitude_in REAL,
        longitude_in REAL,
        latitude_out REAL,
        longitude_out REAL,
        photo_path_in TEXT,
        photo_path_out TEXT,
        sync_status INTEGER NOT NULL DEFAULT 0,
        is_fieldwork INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT "WORK",
        remarks TEXT
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
        lunch_break_mins INTEGER NOT NULL,
        office_lat REAL,
        office_lng REAL,
        program_type TEXT NOT NULL DEFAULT "OJT"
      )
    ''');

    // Insert Default Settings
    await db.insert('intern_settings', {
      'id': 1,
      'target_hours': 486,
      'expected_time_in': '08:00',
      'expected_time_out': '17:00',
      'lunch_break_mins': 60,
      'program_type': 'OJT',
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
