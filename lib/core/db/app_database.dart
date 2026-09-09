import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'standard_categories.dart';

/// Local SQLite database — SRS §4.
///
/// Raw `sqlite3` (no codegen): the schema, the two query indexes
/// (`IDX_LOG_ACTIVITY_ID`, `IDX_LOG_LOGGED_AT`) and the
/// `ON DELETE CASCADE` FK (SRS §3.3) are created in plain SQL below.
/// Timestamps are stored as INTEGER milliseconds-since-epoch (local wall
/// clock, matching how they were captured) and converted back on read.
final class AppDatabase {
  AppDatabase._(this._db);

  final Database _db;

  /// Production: file-backed DB in the app documents directory.
  static Future<AppDatabase> open() async {
    final dir = await getApplicationDocumentsDirectory();
    return _openFile(p.join(dir.path, 'ktk.sqlite'));
  }

  /// Explicit path (used by integration tests / backup-restore later).
  static AppDatabase openFile(String path) => _openFile(path);

  /// Tests: in-memory DB.
  static AppDatabase inMemory() {
    final db = AppDatabase._(sqlite3.openInMemory());
    db._init();
    return db;
  }

  static AppDatabase _openFile(String path) {
    final db = AppDatabase._(sqlite3.open(path));
    db._init();
    return db;
  }

  void _init() {
    // FK enforcement is OFF by default in SQLite — required for the
    // cascade delete rule (SRS §3.3).
    _db.execute('PRAGMA foreign_keys = ON;');
    _db.execute('PRAGMA journal_mode = WAL;');
    _db.execute('''
      CREATE TABLE IF NOT EXISTS activities (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL CHECK (length(name) BETWEEN 1 AND 100),
        category_id INTEGER NOT NULL,
        icon TEXT NOT NULL DEFAULT '📌',
        is_reminder_active INTEGER NOT NULL DEFAULT 0,
        reminder_interval INTEGER,
        reminder_tone TEXT,
        created_at INTEGER NOT NULL
      );
    ''');
    _db.execute('''
      CREATE TABLE IF NOT EXISTS logs (
        id TEXT PRIMARY KEY,
        activity_id TEXT NOT NULL REFERENCES activities(id)
          ON DELETE CASCADE,
        logged_at INTEGER NOT NULL,
        notes TEXT
      );
    ''');
    // Query indexes — SRS §4 tip (beranda < 500 ms).
    _db.execute(
      'CREATE INDEX IF NOT EXISTS IDX_LOG_ACTIVITY_ID ON logs(activity_id);',
    );
    _db.execute(
      'CREATE INDEX IF NOT EXISTS IDX_LOG_LOGGED_AT ON logs(logged_at);',
    );
    _db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        emoji TEXT NOT NULL,
        color_hex TEXT NOT NULL
      );
    ''');
    _db.execute('''
      CREATE TABLE IF NOT EXISTS user_profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        avatar TEXT NOT NULL,
        joined_at INTEGER NOT NULL
      );
    ''');
    _seedCategories();
  }

  void _seedCategories() {
    final count =
        _db.select('SELECT COUNT(*) AS n FROM categories;').first['n'] as int;
    if (count > 0) return;
    final stmt = _db.prepare(
      'INSERT INTO categories (id, name, emoji, color_hex) '
      'VALUES (?, ?, ?, ?);',
    );
    for (final c in standardCategories) {
      stmt.execute([c.id, c.name, c.emoji, c.colorHex]);
    }
    stmt.close();
  }

  // ── Query helpers ────────────────────────────────────────────────────

  List<Map<String, Object?>> select(
    String sql, [
    List<Object?> args = const [],
  ]) => _db.select(sql, args);

  void execute(String sql, [List<Object?> args = const []]) =>
      _db.execute(sql, args);

  /// Runs [action] inside a transaction; rolls back on any throw.
  T transaction<T>(T Function() action) {
    _db.execute('BEGIN IMMEDIATE;');
    try {
      final result = action();
      _db.execute('COMMIT;');
      return result;
    } catch (_) {
      _db.execute('ROLLBACK;');
      rethrow;
    }
  }

  bool get foreignKeysEnabled {
    final row = _db.select('PRAGMA foreign_keys;').first;
    return row['foreign_keys'] == 1;
  }

  void close() => _db.close();

  /// Best-effort periodic compaction (PRD FR-001).
  void vacuum() => _db.execute('VACUUM;');

  static Future<Directory> defaultDirectory() =>
      getApplicationDocumentsDirectory();
}
