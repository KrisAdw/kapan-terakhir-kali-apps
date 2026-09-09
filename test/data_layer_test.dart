import 'package:flutter_test/flutter_test.dart';

import 'package:ktk/core/db/app_database.dart';
import 'package:ktk/core/utils/days_since.dart';
import 'package:ktk/core/utils/log_guard.dart';
import 'package:ktk/data/repositories/activity_repository.dart';

void main() {
  group('daysSince (SRS §3.1)', () {
    // 2026-09-09 13:00 local.
    final now = DateTime(2026, 9, 9, 13);

    test('same local day → 0 (Hari Ini)', () {
      expect(daysSince(DateTime(2026, 9, 9, 0, 30), now: now), 0);
      expect(daysSince(DateTime(2026, 9, 9, 12, 59), now: now), 0);
    });

    test(
      'yesterday 23:00 checked at 01:00 today → 1 (calendar day, not 2h)',
      () {
        // SRS §3.1 example: log kemarin 23:00, cek hari ini 01:00.
        expect(
          daysSince(DateTime(2026, 9, 8, 23), now: DateTime(2026, 9, 9, 1)),
          1,
        );
      },
    );

    test('exactly 24h but crosses midnight → 1', () {
      expect(
        daysSince(DateTime(2026, 9, 8, 13), now: DateTime(2026, 9, 9, 13)),
        1,
      );
    });

    test('long gaps', () {
      expect(daysSince(DateTime(2026, 8, 10), now: now), 30);
      expect(daysSince(DateTime(2025, 9, 9), now: now), 365);
    });

    test('future date → negative (guard should have rejected)', () {
      expect(daysSince(DateTime(2026, 9, 10), now: now), lessThan(0));
    });
  });

  group('time-travel guard (SRS §6.1)', () {
    final now = DateTime(2026, 9, 9, 12);
    final lastLog = DateTime(2026, 9, 5, 9);

    test('accepts a normal new log', () {
      expect(
        () => validateNewLog(
          DateTime(2026, 9, 9, 11),
          now: now,
          latestLoggedAt: lastLog,
        ),
        returnsNormally,
      );
    });

    test('accepts a manual backfill after the latest log', () {
      expect(
        () => validateNewLog(
          DateTime(2026, 9, 6, 10),
          now: now,
          latestLoggedAt: lastLog,
        ),
        returnsNormally,
      );
    });

    test('rejects future-dated log with casual copy', () {
      final ex = _catch<TimeTravelException>(
        () => validateNewLog(
          DateTime(2026, 9, 10),
          now: now,
          latestLoggedAt: lastLog,
        ),
      );
      expect(ex.message, contains('mesin waktu'));
    });

    test('rejects log older than latest stored log (clock moved back)', () {
      final ex = _catch<TimeTravelException>(
        () => validateNewLog(
          DateTime(2026, 9, 4),
          now: now,
          latestLoggedAt: lastLog,
        ),
      );
      expect(ex.message, contains('mesin waktu'));
    });
  });

  group('AppDatabase & ActivityRepository', () {
    late AppDatabase db;
    late ActivityRepository repo;

    setUp(() {
      db = AppDatabase.inMemory();
      repo = ActivityRepository(db, clock: () => DateTime(2026, 9, 9, 10));
    });

    tearDown(() {
      db.close();
    });

    test('seeds the 10 standard categories (SRS §4)', () {
      final cats = repo.categories();
      expect(cats.length, 10);
      expect(cats.map((c) => c.id), containsAll([1, 10]));
      expect(cats.firstWhere((c) => c.id == 4).name, 'Kesehatan');
    });

    test('foreign_keys pragma is ON so cascade actually works (SRS §3.3)', () {
      expect(db.foreignKeysEnabled, isTrue);
    });

    test('createActivity persists and stream emits it with no logs', () async {
      final created = await repo.createActivity(
        name: 'Ganti Oli Motor',
        categoryId: 1,
        icon: '🛵',
      );

      final list = await repo.watchAllActivities().first;
      expect(list, hasLength(1));
      final a = list.single;
      expect(a.id, created.id);
      expect(a.name, 'Ganti Oli Motor');
      expect(a.lastLoggedAt, isNull);
      expect(a.logCount, 0);
      expect(a.daysSince(), isNull);
    });

    test('addLog updates lastLoggedAt & logCount via stream', () async {
      final a = await repo.createActivity(name: 'Cuci AC', categoryId: 2);

      await repo.addLog(a.id, loggedAt: DateTime(2026, 9, 5, 15));
      await repo.addLog(a.id, loggedAt: DateTime(2026, 9, 8, 21));

      final view = await repo.watchAllActivities().first;
      expect(view.single.logCount, 2);
      expect(view.single.lastLoggedAt, DateTime(2026, 9, 8, 21));
      // 2026-09-09 10:00 − 2026-09-08 21:00 → 1 hari kalender.
      expect(view.single.daysSince(), 1);
    });

    test('addLog without date uses the injectable clock', () async {
      final a = await repo.createActivity(name: 'Potong Rambut', categoryId: 3);
      await repo.addLog(a.id); // clock: 2026-09-09 10:00

      final view = await repo.watchAllActivities().first;
      expect(view.single.daysSince(), 0);
    });

    test(
      'addLogWithNotes persists the note (Premium feature, FR-002)',
      () async {
        final a = await repo.createActivity(name: 'Servis AC', categoryId: 1);
        await repo.addLogWithNotes(
          a.id,
          loggedAt: DateTime(2026, 9, 8, 9),
          notes: 'Freon belum diganti, cek lagi bulan depan.',
        );

        final logs = repo.logsOf(a.id);
        expect(logs.single.notes, contains('Freon'));
      },
    );

    test('addLog enforces time-travel guard (SRS §6.1)', () async {
      final a = await repo.createActivity(name: 'Backup Laptop', categoryId: 6);
      await repo.addLog(a.id, loggedAt: DateTime(2026, 9, 8));

      await expectLater(
        repo.addLog(a.id, loggedAt: DateTime(2026, 9, 7)), // older than latest
        throwsA(isA<TimeTravelException>()),
      );
      // History untouched — write rejected before INSERT.
      expect(repo.logsOf(a.id), hasLength(1));
    });

    test('deleteLog removes a single history entry', () async {
      final a = await repo.createActivity(name: 'Olahraga', categoryId: 4);
      final l1 = await repo.addLog(a.id, loggedAt: DateTime(2026, 9, 1));
      await repo.addLog(a.id, loggedAt: DateTime(2026, 9, 2));

      await repo.deleteLog(l1.id);
      expect(repo.logsOf(a.id), hasLength(1));
    });

    test('deleteActivity cascades to logs (SRS §3.3)', () async {
      final a = await repo.createActivity(name: 'Ganti Sprei', categoryId: 2);
      await repo.addLog(a.id, loggedAt: DateTime(2026, 9, 1));
      await repo.addLog(a.id, loggedAt: DateTime(2026, 9, 2));

      // Sanity: rows exist before delete.
      expect(repo.logsOf(a.id), hasLength(2));

      await repo.deleteActivity(a.id);

      expect(
        repo.logsOf(a.id),
        isEmpty,
        reason: 'ON DELETE CASCADE must clean Logs',
      );
      expect(await repo.watchAllActivities().first, isEmpty);
    });
  });
}

/// Catches [E] from [body] or rethrows anything else.
E _catch<E extends Object>(Function body) {
  try {
    body();
  } catch (e) {
    if (e is E) return e;
    rethrow;
  }
  throw StateError('Expected $E to be thrown');
}
