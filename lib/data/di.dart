import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/app_database.dart';
import 'repositories/activity_repository.dart';

/// Database singleton. Opening is async but lazy in effect: nothing touches
/// it until the first feature reads data, so the splash phase never waits.
final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  final db = await AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

/// Single repository instance over the app database.
/// In tests, override [databaseProvider] with an in-memory database.
final activityRepositoryProvider = FutureProvider<ActivityRepository>((ref) {
  return ref.watch(databaseProvider.future).then(ActivityRepository.new);
});
