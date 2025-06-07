import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mood_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'treering.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE mood_entries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            rating INTEGER,
            factors TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertMoodEntry(MoodEntry entry) async {
    final db = await database;
    return await db.insert('mood_entries', entry.toMap());
  }

  Future<List<MoodEntry>> getMoodEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('mood_entries', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => MoodEntry.fromMap(maps[i]));
  }
} 