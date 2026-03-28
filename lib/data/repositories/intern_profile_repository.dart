import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/intern_profile.dart';

class InternProfileRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<InternProfile> getProfile() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('intern_profile', limit: 1);
    
    if (maps.isNotEmpty) {
      return InternProfile.fromMap(maps.first);
    }
    
    // Fallback default
    return InternProfile(name: '', agencyOffice: '', supervisorName: '');
  }

  Future<void> saveProfile(InternProfile profile) async {
    final db = await _dbHelper.database;
    // Wipe and aggressively replace since it's a singleton pattern without rowid requirements
    await db.execute('DELETE FROM intern_profile');
    await db.insert('intern_profile', profile.toMap());
  }
}
