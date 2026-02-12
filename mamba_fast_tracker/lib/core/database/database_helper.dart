import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mamba_fast_tracker/core/utils/constants.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.fastingProtocolsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        fasting_hours INTEGER NOT NULL,
        eating_hours INTEGER NOT NULL,
        is_custom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.fastingSessionsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        protocol_name TEXT NOT NULL,
        fasting_hours INTEGER NOT NULL,
        eating_hours INTEGER NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        elapsed_seconds INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.mealsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories INTEGER NOT NULL,
        date_time TEXT NOT NULL
      )
    ''');

    // Insert default protocols
    await db.insert(AppConstants.fastingProtocolsTable, {
      'name': '12:12',
      'fasting_hours': 12,
      'eating_hours': 12,
      'is_custom': 0,
    });
    await db.insert(AppConstants.fastingProtocolsTable, {
      'name': '16:8',
      'fasting_hours': 16,
      'eating_hours': 8,
      'is_custom': 0,
    });
    await db.insert(AppConstants.fastingProtocolsTable, {
      'name': '18:6',
      'fasting_hours': 18,
      'eating_hours': 6,
      'is_custom': 0,
    });
  }
}
