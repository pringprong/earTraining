import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
//import 'dart:io';

// Simple model for a saved test result
class TestResult {
  final int? id;
  final String timestamp; // ISO string
  final String levelID;
  final int numQuestions;
  final int score;

  TestResult({
    this.id,
    required this.timestamp,
    required this.levelID,
    required this.numQuestions,
    required this.score,
  });

  factory TestResult.fromMap(Map<String, dynamic> m) => TestResult(
    id: m['id'] as int?,
    timestamp: m['timestamp'] as String,
    levelID: m['levelID'] as String,
    numQuestions: m['numQuestions'] as int,
    score: m['score'] as int,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp,
    'levelID': levelID,
    'numQuestions': numQuestions,
    'score': score,
  };
}

class TestResultsDB {
  static final TestResultsDB instance = TestResultsDB._init();
  static Database? _db;

  TestResultsDB._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('test_results.db');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  FutureOr<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE test_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp TEXT NOT NULL,
      levelID TEXT NOT NULL,
      numQuestions INTEGER NOT NULL,
      score INTEGER NOT NULL
    )
    ''');
  }

  Future<int> insertResult(TestResult entry) async {
    final db = await instance.database;
    return await db.insert('test_results', entry.toMap());
  }

  Future deleteAllResults() async {
    final db = await instance.database;
    return await db.rawDelete("DELETE FROM test_results");
  }

  Future<List<TestResult>> getResultsForLevel(String levelID) async {
    final db = await instance.database;
    final maps = await db.query(
      'test_results',
      where: 'levelID = ?',
      whereArgs: [levelID],
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => TestResult.fromMap(m)).toList();
  }

  Future<List<TestResult>> getAllResults() async {
    final db = await instance.database;
    final maps = await db.query('test_results', orderBy: 'timestamp DESC');
    return maps.map((m) => TestResult.fromMap(m)).toList();
  }

  Future close() async {
    final db = _db;
    if (db != null) await db.close();
    _db = null;
  }
}
