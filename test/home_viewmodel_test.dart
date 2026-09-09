import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ktk/core/db/app_database.dart';
import 'package:ktk/data/di.dart';
import 'package:ktk/data/models/activity.dart';
import 'package:ktk/data/repositories/activity_repository.dart';
import 'package:ktk/features/home/viewmodels/home_viewmodel.dart';
import 'package:ktk/features/home/widgets/activity_card.dart';
import 'package:ktk/features/home/widgets/category_chip_bar.dart';

Activity _activity({
  String id = 'a1',
  String name = 'Ganti Oli',
  int days = 5,
  int count = 3,
}) {
  final now = DateTime(2026, 9, 9, 12);
  return Activity(
    id: id,
    name: name,
    categoryId: 1,
    icon: '🛵',
    isReminderActive: false,
    createdAt: now.subtract(const Duration(days: 40)),
    lastLoggedAt: days < 0 ? null : now.subtract(Duration(days: days)),
    logCount: count,
    avgIntervalDays: count > 1 ? 12.5 : null,
  );
}

ProviderContainer _containerWithDb(AppDatabase db) {
  final container = ProviderContainer(
    overrides: [
      activityRepositoryProvider.overrideWith(
        (ref) async =>
            ActivityRepository(db, clock: () => DateTime(2026, 9, 9, 10)),
      ),
    ],
  );
  return container;
}

void main() {
  group('applyHomeFilters', () {
    final list = [
      _activity(id: 'a1', name: 'Ganti Oli Motor', days: 5),
      _activity(id: 'a2', name: 'Cuci AC', days: 40),
      _activity(id: 'a3', name: 'Oli Kawasaki', days: 0, count: 1),
    ];

    test('no filter returns all', () {
      expect(applyHomeFilters(list, categoryId: null, query: '').length, 3);
    });

    test('category filter (AND semantics)', () {
      expect(applyHomeFilters(list, categoryId: 1, query: '').length, 3);
      expect(applyHomeFilters(list, categoryId: 9, query: ''), isEmpty);
    });

    test('search is case-insensitive substring', () {
      expect(
        applyHomeFilters(list, categoryId: null, query: 'oli').map((a) => a.id),
        ['a1', 'a3'],
      );
      expect(
        applyHomeFilters(
          list,
          categoryId: null,
          query: 'CUCI',
        ).map((a) => a.id),
        ['a2'],
      );
    });

    test('category + search combine (AND)', () {
      expect(
        applyHomeFilters(
          list,
          categoryId: 1,
          query: 'kawasaki',
        ).map((a) => a.id),
        ['a3'],
      );
    });

    test('whitespace query = no filter', () {
      expect(applyHomeFilters(list, categoryId: null, query: '   ').length, 3);
    });
  });

  group('HomeController.quickLog', () {
    late ProviderContainer container;
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.inMemory();
      container = _containerWithDb(db);
      addTearDown(() {
        container.dispose();
        db.close();
      });
    });

    test('create → quick log marks just-logged, log persisted', () async {
      final controller = container.read(homeControllerProvider);
      final err = await controller.createActivity(
        name: '  Ganti Oli Motor  ',
        categoryId: 1,
        icon: '🛵',
      );
      expect(err, isNull);

      final repo = await container.read(activityRepositoryProvider.future);
      final all = await repo.watchAllActivities().first;
      expect(all.single.name, 'Ganti Oli Motor'); // trimmed

      final ok = await controller.quickLog(all.single);
      expect(ok, isNull);
      expect(container.read(justLoggedIdsProvider), contains(all.single.id));

      // Log tersimpan dengan timestamp clock (2026-09-09 10:00 → 0 hari).
      final view = await repo.watchAllActivities().first;
      expect(view.single.logCount, 1);
      expect(view.single.daysSince(), 0);
    });

    test('createActivity rejects blank names with casual copy', () async {
      final controller = container.read(homeControllerProvider);
      expect(
        await controller.createActivity(name: '   ', categoryId: 1, icon: '📌'),
        isNotNull,
      );
    });

    test('deleteActivity cascades history (SRS §3.3)', () async {
      final controller = container.read(homeControllerProvider);
      await controller.createActivity(
        name: 'Cuci AC',
        categoryId: 2,
        icon: '🏠',
      );
      final repo = await container.read(activityRepositoryProvider.future);
      final a = (await repo.watchAllActivities().first).single;
      await repo.addLog(a.id);

      await controller.deleteActivity(a.id);
      expect(repo.logsOf(a.id), isEmpty);
    });
  });

  group('ActivityCard widget', () {
    testWidgets('renders name, category, days number', (tester) async {
      final db = AppDatabase.inMemory();
      final container = _containerWithDb(db);
      addTearDown(() {
        container.dispose();
        db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ActivityCard(
                activity: _activity(days: 5),
                onManualLog: () {},
                onOpenDetail: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('GANTI OLI'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('HARI LALU'), findsOneWidget);
      expect(find.text('🔧 Maintenance'), findsOneWidget);
    });

    testWidgets('tap quick-log writes a log and shows just-logged state', (
      tester,
    ) async {
      final db = AppDatabase.inMemory();
      final container = _containerWithDb(db);
      addTearDown(() {
        container.dispose();
        db.close();
      });

      final repo = await container.read(activityRepositoryProvider.future);
      final created = await repo.createActivity(
        name: 'Ganti Oli',
        categoryId: 1,
        icon: '🛵',
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ActivityCard(
                activity: created,
                onManualLog: () {},
                onOpenDetail: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.push_pin_rounded));
      await tester.pumpAndSettle();

      expect(container.read(justLoggedIdsProvider), contains(created.id));
      expect(find.text('DICATAT. AMAN.'), findsOneWidget);
      expect(repo.logsOf(created.id), hasLength(1));

      // Biarkan timer just-logged (1.6 s) habis agar tidak ada timer
      // pending saat test selesai.
      await tester.pump(const Duration(milliseconds: 1600));
      expect(
        container.read(justLoggedIdsProvider),
        isNot(contains(created.id)),
      );
    });

    testWidgets('tap body toggles expanded panel', (tester) async {
      final db = AppDatabase.inMemory();
      final container = _containerWithDb(db);
      addTearDown(() {
        container.dispose();
        db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ActivityCard(
                activity: _activity(days: 5, count: 2),
                onManualLog: () {},
                onOpenDetail: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Log Manual'), findsNothing);

      await tester.tap(find.text('GANTI OLI'));
      await tester.pumpAndSettle();
      expect(find.text('Log Manual'), findsOneWidget);
      expect(find.text('Detail →'), findsOneWidget);
      // TERAKHIR + rata-rata tampil di panel.
      expect(find.textContaining('RATA-RATA: ~13 HARI'), findsOneWidget);
    });
  });

  group('CategoryChipBar widget', () {
    testWidgets('tap chip updates filter state', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: CategoryChipBar())),
        ),
      );

      expect(container.read(homeFilterProvider), isNull);
      await tester.tap(find.text('Kesehatan'));
      expect(container.read(homeFilterProvider), 4);
      await tester.tap(find.text('Semua'));
      expect(container.read(homeFilterProvider), isNull);
    });
  });
}
