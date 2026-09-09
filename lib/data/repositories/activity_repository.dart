import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../core/db/app_database.dart';
import '../../core/utils/log_guard.dart';
import '../models/activity.dart';

/// All data access for activities and their logs — the only SQL consumer.
///
/// [watchAllActivities] re-queries on a short interval so the home screen
/// stays reactive; the write path itself is a single indexed INSERT, well
/// under the 500 ms budget (SRS §5). Timestamps cross the DB boundary as
/// epoch milliseconds (see `AppDatabase` docs).
final class ActivityRepository {
  ActivityRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const _uuid = Uuid();

  final AppDatabase _db;
  final DateTime Function() _clock;

  // ── Queries ──────────────────────────────────────────────────────────

  /// Home dashboard stream: every activity with its last-log date and
  /// history count. Re-emits at most every 250 ms after a change.
  Stream<List<Activity>> watchAllActivities() {
    late StreamController<List<Activity>> controller;
    Timer? timer;
    List<Activity>? last;

    Future<void> emit() async {
      final rows = _queryActivities();
      if (last == null || _listChanged(last!, rows)) {
        last = rows;
        controller.add(rows);
      }
    }

    controller = StreamController<List<Activity>>(
      onListen: () async {
        await emit();
        timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
          if (!controller.isClosed) emit();
        });
      },
      onPause: () => timer?.cancel(),
      onResume: () async {
        await emit();
        timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
          if (!controller.isClosed) emit();
        });
      },
      onCancel: () => timer?.cancel(),
    );
    return controller.stream;
  }

  List<Activity> _queryActivities() {
    final rows = _db.select('''
      SELECT a.id, a.name, a.category_id, a.icon, a.is_reminder_active,
             a.reminder_interval, a.reminder_tone, a.created_at,
             COUNT(l.id) AS log_count, MAX(l.logged_at) AS last_logged_at
      FROM activities a
      LEFT JOIN logs l ON l.activity_id = a.id
      GROUP BY a.id
      ORDER BY MAX(l.logged_at) IS NOT NULL DESC,
               MAX(l.logged_at) ASC, a.created_at DESC;
    ''');
    return [for (final r in rows) _rowToActivity(r)];
  }

  /// Latest log date for one activity — guard input for [addLog].
  DateTime? latestLogDate(String activityId) {
    final rows = _db.select(
      'SELECT MAX(logged_at) AS t FROM logs WHERE activity_id = ?;',
      [activityId],
    );
    final ms = rows.first['t'] as int?;
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Remaining Log rows for an activity — lets tests prove the cascade
  /// delete actually removed the history (SRS §3.3).
  List<LogEntry> logsOf(String activityId) {
    final rows = _db.select(
      'SELECT id, activity_id, logged_at, notes FROM logs '
      'WHERE activity_id = ? ORDER BY logged_at DESC;',
      [activityId],
    );
    return [for (final r in rows) _rowToLog(r)];
  }

  // ── Mutations ────────────────────────────────────────────────────────

  /// Creates an activity card (no logs yet — days-since stays empty).
  Future<Activity> createActivity({
    required String name,
    required int categoryId,
    String icon = '📌',
    ReminderTone? reminderTone,
    bool isReminderActive = false,
    int? reminderInterval,
  }) async {
    final id = _uuid.v4();
    final now = _clock();
    _db.execute(
      'INSERT INTO activities '
      '(id, name, category_id, icon, is_reminder_active, reminder_interval, '
      ' reminder_tone, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?);',
      [
        id,
        name,
        categoryId,
        icon,
        isReminderActive ? 1 : 0,
        reminderInterval,
        reminderTone?.dbValue,
        now.millisecondsSinceEpoch,
      ],
    );
    return Activity(
      id: id,
      name: name,
      categoryId: categoryId,
      icon: icon,
      isReminderActive: isReminderActive,
      reminderInterval: reminderInterval,
      reminderTone: reminderTone,
      createdAt: now,
      lastLoggedAt: null,
      logCount: 0,
    );
  }

  /// One-tap quick log / manual log. Enforces the time-travel guard
  /// (SRS §6.1) before writing; the write itself is a single fast INSERT.
  Future<LogEntry> addLog(
    String activityId, {
    DateTime? loggedAt,
    String? notes,
  }) async {
    final at = loggedAt ?? _clock();
    validateNewLog(
      at,
      now: _clock(),
      latestLoggedAt: latestLogDate(activityId),
    );

    final entry = LogEntry(
      id: _uuid.v4(),
      activityId: activityId,
      loggedAt: at,
    );
    _db.execute(
      'INSERT INTO logs (id, activity_id, logged_at, notes) VALUES (?, ?, ?, ?);',
      [entry.id, entry.activityId, at.millisecondsSinceEpoch, notes],
    );
    return entry;
  }

  /// Manual log with notes — Premium only (PRD Feature 01). The gating
  /// check lives in the ViewModel; this method only persists.
  Future<LogEntry> addLogWithNotes(
    String activityId, {
    required String notes,
    DateTime? loggedAt,
  }) => addLog(activityId, loggedAt: loggedAt, notes: notes);

  /// Hapus satu entri riwayat (tombol hapus di detail, PRD §7).
  Future<void> deleteLog(String logId) async {
    _db.execute('DELETE FROM logs WHERE id = ?;', [logId]);
  }

  /// Deletes the card AND all its history via ON DELETE CASCADE (SRS §3.3).
  Future<void> deleteActivity(String activityId) async {
    _db.execute('DELETE FROM activities WHERE id = ?;', [activityId]);
  }

  // ── Categories ───────────────────────────────────────────────────────

  List<Category> categories() => [
    for (final r in _db.select(
      'SELECT id, name, emoji, color_hex FROM categories ORDER BY id;',
    ))
      Category(
        id: r['id'] as int,
        name: r['name'] as String,
        emoji: r['emoji'] as String,
        colorHex: r['color_hex'] as String,
      ),
  ];

  // ── Internals ────────────────────────────────────────────────────────

  Activity _rowToActivity(Map<String, Object?> r) {
    final lastMs = r['last_logged_at'] as int?;
    return Activity(
      id: r['id'] as String,
      name: r['name'] as String,
      categoryId: r['category_id'] as int,
      icon: r['icon'] as String,
      isReminderActive: (r['is_reminder_active'] as int) == 1,
      reminderInterval: r['reminder_interval'] as int?,
      reminderTone: r['reminder_tone'] == null
          ? null
          : ReminderTone.fromDb(r['reminder_tone'] as String),
      createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
      lastLoggedAt: lastMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastMs),
      logCount: r['log_count'] as int,
    );
  }

  LogEntry _rowToLog(Map<String, Object?> r) => LogEntry(
    id: r['id'] as String,
    activityId: r['activity_id'] as String,
    loggedAt: DateTime.fromMillisecondsSinceEpoch(r['logged_at'] as int),
    notes: r['notes'] as String?,
  );

  bool _listChanged(List<Activity> a, List<Activity> b) {
    if (a.length != b.length) return true;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return true;
    }
    return false;
  }
}
