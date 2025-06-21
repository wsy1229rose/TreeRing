import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mood_entry.dart';
import '../models/moodidi.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mood_database.db');

    print('[DEBUG] using _initDatabase → mood_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mood_entries (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        date        TEXT,
        rating      INTEGER NOT NULL,
        description TEXT,
        photoPath   TEXT,
        responses   TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE moodidi (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        keyword    TEXT    NOT NULL,
        type       TEXT    NOT NULL,
        prompt     TEXT    NOT NULL,
        createdAt  TEXT    NOT NULL
      )
    ''');
  }

  Future<int> deleteEntry(DateTime date) async {
  final db = await database;
  return await db.delete(
    'mood_entries',
    where: 'date = ?',
    whereArgs: [date.toIso8601String()],
  );
}



  // ——— MoodEntry CRUD ———

  Future<int> insertMoodEntry(MoodEntry entry) async {
    final db = await database;
    return await db.insert(
      'mood_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MoodEntry?> getEntryByDate(String date) async {
    final db = await database;
    final rows = await db.query(
      'mood_entries',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (rows.isNotEmpty) {
      return MoodEntry.fromMap(rows.first);
    }
    return null;
  }

  Future<List<MoodEntry>> getMoodEntries() async {
    final db = await database;
    final rows = await db.query(
      'mood_entries',
      orderBy: 'date ASC',
    );
    return rows.map((r) => MoodEntry.fromMap(r)).toList();
  }

  Future<int> deleteMoodEntry(String date) async {
    final db = await database;
    return await db.delete(
      'mood_entries',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  // ——— Moodidi CRUD ———

  Future<int> insertMoodidi(Moodidi m) async {
    final db = await database;
    return await db.insert(
      'moodidi',
      m.toMap(),
    );
  }

  Future<List<Moodidi>> getMoodidiList() async {
    final db = await database;
    final rows = await db.query(
      'moodidi',
      orderBy: 'createdAt ASC',
    );
    return rows.map((r) => Moodidi.fromMap(r)).toList();
  }

  Future<int> deleteMoodidi(int id) async {
    final db = await database;
    return await db.delete(
      'moodidi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}