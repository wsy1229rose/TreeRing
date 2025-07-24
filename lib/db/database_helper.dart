import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mood_entry.dart';
import '../models/moodidi.dart';
import '../models/moodidi_entry.dart';

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

    await db.execute('''
      CREATE TABLE moodidi_entries (
        keyword    TEXT    NOT NULL,
        entry      NUMERIC NOT NULL,
        createdAt  TEXT    NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_mood_entries_date ON mood_entries(date);');

  }

  Future<List<MoodEntry>> getAllMoodEntries() async {
    final db   = await database;
    final rows = await db.query(
      'mood_entries',
      orderBy: 'date DESC',
    );
    // Convert each map into a MoodEntry via your factory
    return rows.map((row) => MoodEntry.fromMap(row)).toList();
  }

  Future<List<MoodidiEntry>> getAllMoodidiEntries(String keyword) async {
    final db   = await database;
    final rows = await db.query(
      'moodidi_entries',
      where: 'keyword = ?',
      whereArgs: [keyword],
      orderBy: 'createdAt DESC',
    );
    // Convert each map into a MoodidiEntry via your factory
    return rows.map((row) => MoodidiEntry.fromMap(row)).toList();
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

/*Future<MoodEntry?> getMoodEntryByDate(String date) async {
    final db = await database;
    final rows = await db.query(                    // unused
      'mood_entries',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (rows.isNotEmpty) {
      return MoodEntry.fromMap(rows.first);
    }
    return null;
  }

   Future<int> deleteMoodEntry(String date) async {
     final db = await database;
     return await db.delete(                         // unused
       'mood_entries',
       where: 'date = ?',
       whereArgs: [date],
     );
   }*/

  // ——— Moodidi CRUD ———

  Future<int> insertMoodidi(Moodidi m) async {
    final db = await database;
    return await db.insert(
      'moodidi',
      m.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
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

    final result = await db.query(
      'moodidi',
      columns: ['keyword'],
      where: 'id = ?',
      whereArgs: [id],
    );
    final keyword = result.first['keyword'] as String;

    await db.delete(
      'moodidi_entries',
      where: 'keyword = ?',
      whereArgs: [keyword],
    );

    return await db.delete(
      'moodidi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  // ——— MoodidiEntry CRUD ———

  Future<int> insertMoodidiEntry(MoodidiEntry entry) async {
    final db = await database;
    return await db.insert(
      'moodidi_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /*Future<int> deleteMoodidiEntry(String date) async {
    final db = await database;
    return await db.delete(
      'moodidi_entries',
      where: 'createdAt = ?',
      whereArgs: [date],
    );
  }*/
}