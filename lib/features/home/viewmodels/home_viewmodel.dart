import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/utils/log_guard.dart';
import '../../../data/di.dart';
import '../../../data/models/activity.dart';
import '../../../data/repositories/activity_repository.dart';

/// Filter chip aktif — null = "Semua" (design.md §7 Chip).
final homeFilterProvider = StateProvider<int?>((ref) => null);

/// Query pencarian instan (PRD §7 Main Dashboard).
final homeSearchProvider = StateProvider<String>((ref) => '');

/// Stream seluruh aktivitas + last log (reaktif, lihat repository).
final activitiesStreamProvider = StreamProvider<List<Activity>>((ref) async* {
  final repo = await ref.watch(activityRepositoryProvider.future);
  yield* repo.watchAllActivities();
});

/// Set id kartu yang baru di-quick-log → animasi just-logged sementara
/// (design.md §7: background #F0FFF4, shadow green, label "Dicatat. Aman.").
final justLoggedIdsProvider = StateProvider<Set<String>>((ref) => {});

/// Aksi Home (PRD §7 Key Interactions): quick log, tambah kartu, hapus.
final homeControllerProvider = Provider<HomeController>((ref) {
  return HomeController(ref);
});

final class HomeController {
  HomeController(this._ref);

  final Ref _ref;

  Future<ActivityRepository> _repo() =>
      _ref.read(activityRepositoryProvider.future);

  /// One-tap quick log (PRD Feature 01): tulis log tanpa navigasi/modal,
  /// set state just-logged selama 1.6 s, lalu kembalikan null saat sukses.
  /// Guard time-travel (SRS §6.1) → pesan error siap-tampilkan.
  Future<String?> quickLog(Activity activity) async {
    final repo = await _repo();
    try {
      await repo.addLog(activity.id);
    } on TimeTravelException catch (e) {
      return e.message;
    }
    final ids = {..._ref.read(justLoggedIdsProvider), activity.id};
    _ref.read(justLoggedIdsProvider.notifier).state = ids;
    Timer(const Duration(milliseconds: 1600), () {
      final current = _ref.read(justLoggedIdsProvider);
      _ref.read(justLoggedIdsProvider.notifier).state = {...current}
        ..remove(activity.id);
    });
    return null;
  }

  /// Menyimpan kartu baru dari AddActivitySheet. Returns error message or
  /// null on success.
  Future<String?> createActivity({
    required String name,
    required int categoryId,
    required String icon,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'Isi dulu dong nama aktivitasnya.';
    }
    final repo = await _repo();
    await repo.createActivity(
      name: trimmed,
      categoryId: categoryId,
      icon: icon,
    );
    return null;
  }

  /// Swipe-to-delete kartu (PRD §7) — cascade membersihkan riwayat
  /// (SRS §3.3).
  Future<void> deleteActivity(String activityId) async {
    final repo = await _repo();
    await repo.deleteActivity(activityId);
  }

  /// Edit cepat via swipe (PRD §7).
  Future<void> renameActivity(String activityId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final repo = await _repo();
    await repo.updateActivity(activityId, name: trimmed);
  }
}

/// Terapkan filter kategori + pencarian pada daftar aktivitas.
/// Top-level agar mudah di-unit-test.
List<Activity> applyHomeFilters(
  List<Activity> activities, {
  required int? categoryId,
  required String query,
}) {
  var list = activities;
  if (categoryId != null) {
    list = list.where((a) => a.categoryId == categoryId).toList();
  }
  final q = query.trim().toLowerCase();
  if (q.isNotEmpty) {
    list = list.where((a) => a.name.toLowerCase().contains(q)).toList();
  }
  return list;
}
