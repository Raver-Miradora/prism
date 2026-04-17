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
      version: 13,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 13) {
      try {
        await db.execute('CREATE INDEX IF NOT EXISTS idx_time_logs_date ON time_logs(date)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_daily_reports_date ON daily_reports(date)');
      } catch (_) {}
    }
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE intern_profile ADD COLUMN profile_image_path TEXT');
      } catch (_) {}
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE intern_settings ADD COLUMN office_lat REAL');
        await db.execute('ALTER TABLE intern_settings ADD COLUMN office_lng REAL');
        await db.execute('ALTER TABLE intern_settings ADD COLUMN program_type TEXT DEFAULT "OJT"');
      } catch (_) {}
    }
    if (oldVersion < 11) {
      try {
        await db.execute('ALTER TABLE intern_settings ADD COLUMN school_name TEXT');
        await db.execute('ALTER TABLE intern_settings ADD COLUMN course_program TEXT');
      } catch (_) {}
    }
    if (oldVersion < 12) {
      try {
        await db.execute('ALTER TABLE time_logs ADD COLUMN is_geofence_bypassed INTEGER NOT NULL DEFAULT 0');
      } catch (_) {}
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE time_logs ADD COLUMN is_fieldwork INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE time_logs ADD COLUMN status TEXT DEFAULT "WORK"');
        await db.execute('ALTER TABLE time_logs ADD COLUMN remarks TEXT');
      } catch (_) {}
    }
    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE time_logs ADD COLUMN time_lunch_out TEXT');
        await db.execute('ALTER TABLE time_logs ADD COLUMN time_lunch_in TEXT');
      } catch (_) {}
    }
    if (oldVersion < 6) {
      try {
        await db.execute('ALTER TABLE time_logs ADD COLUMN fieldwork_location TEXT');
        await db.execute('ALTER TABLE time_logs ADD COLUMN fieldwork_purpose TEXT');
      } catch (_) {}
    }
    if (oldVersion < 7) {
      // Phase 2 Migration: 4-Column Sequence + Manual Flags
      await db.execute('BEGIN TRANSACTION');
      try {
        // 1. Create temporary table
        await db.execute('''
          CREATE TABLE time_logs_new (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            am_in TEXT,
            am_out TEXT,
            pm_in TEXT,
            pm_out TEXT,
            lat_am_in REAL,
            lng_am_in REAL,
            is_manual_am_in INTEGER NOT NULL DEFAULT 0,
            is_manual_am_out INTEGER NOT NULL DEFAULT 0,
            is_manual_pm_in INTEGER NOT NULL DEFAULT 0,
            lat_pm_out REAL,
            lng_pm_out REAL,
            is_manual_pm_out INTEGER NOT NULL DEFAULT 0,
            photo_am_in TEXT,
            photo_pm_out TEXT,
            sync_status INTEGER NOT NULL DEFAULT 0,
            is_fieldwork INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL DEFAULT "WORK",
            remarks TEXT,
            fieldwork_location TEXT,
            fieldwork_purpose TEXT
          )
        ''');

        // 2. Copy data with mapping
        await db.execute('''
          INSERT INTO time_logs_new (
            id, date, am_in, am_out, pm_in, pm_out, 
            lat_am_in, lng_am_in, lat_pm_out, lng_pm_out, 
            photo_am_in, photo_pm_out, 
            sync_status, is_fieldwork, status, remarks, 
            fieldwork_location, fieldwork_purpose
          )
          SELECT 
            id, date, time_in, time_lunch_out, time_lunch_in, time_out, 
            latitude_in, longitude_in, latitude_out, longitude_out, 
            photo_path_in, photo_path_out, 
            sync_status, is_fieldwork, status, remarks, 
            fieldwork_location, fieldwork_purpose
          FROM time_logs
        ''');

        // 3. Swap tables
        await db.execute('DROP TABLE time_logs');
        await db.execute('ALTER TABLE time_logs_new RENAME TO time_logs');
        
        await db.execute('COMMIT');
      } catch (e) {
        await db.execute('ROLLBACK');
        rethrow;
      }
    }
    
    if (oldVersion < 9) {
      // V9 MASTER WIPE: Force drops all legacy data schema to ensure zero-error clean states on packaged builds
      await db.execute('DROP TABLE IF EXISTS time_logs');
      await db.execute('DROP TABLE IF EXISTS time_logs_new');
      await db.execute('DROP TABLE IF EXISTS daily_reports');
      await db.execute('DROP TABLE IF EXISTS intern_profile');
      await db.execute('DROP TABLE IF EXISTS intern_settings');
      await _createDB(db, newVersion);
    }

    if (oldVersion < 10) {
      // V10: Non-destructive — adds record_status for formal attendance classification
      try {
        await db.execute("ALTER TABLE time_logs ADD COLUMN record_status TEXT NOT NULL DEFAULT 'PRESENT'");
      } catch (_) {} // Column may already exist on fresh installs from _createDB
    }
  }

  Future _createDB(Database db, int version) async {
    // time_logs (V9 compliant: Simplified AM IN / PM OUT model)
    await db.execute('''
      CREATE TABLE time_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        am_arrival_time TEXT,
        am_arrival_photo_path TEXT,
        pm_departure_time TEXT,
        pm_departure_photo_path TEXT,
        lat_am_arrival REAL,
        lng_am_arrival REAL,
        is_manual_am_arrival INTEGER NOT NULL DEFAULT 0,
        lat_pm_departure REAL,
        lng_pm_departure REAL,
        is_manual_pm_departure INTEGER NOT NULL DEFAULT 0,
        sync_status INTEGER NOT NULL DEFAULT 0,
        is_fieldwork INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT "WORK",
        record_status TEXT NOT NULL DEFAULT 'PRESENT',
        remarks TEXT,
        fieldwork_location TEXT,
        fieldwork_purpose TEXT,
        is_geofence_bypassed INTEGER NOT NULL DEFAULT 0
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
        program_type TEXT NOT NULL DEFAULT "OJT",
        school_name TEXT,
        course_program TEXT
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
      'school_name': '',
      'course_program': '',
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
