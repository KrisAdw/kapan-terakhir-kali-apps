import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/app_tokens.dart';
import '../../core/widgets/clock_mascot.dart';
import '../../data/di.dart';
import '../../data/models/activity.dart';
import 'widgets/add_activity_sheet.dart';
import 'widgets/activity_card.dart';
import 'widgets/category_chip_bar.dart';
import 'widgets/quick_update_sheet.dart';
import 'viewmodels/home_viewmodel.dart';

/// SCR-01 — Main Dashboard (PRD §7): pencarian instan, filter kategori
/// horizontal, kartu aktivitas days-since, FAB "+".
final class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.onOpenDetail});

  /// Navigasi ke detail (Fase 3). Untuk kini: snackbar placeholder.
  final void Function(String activityId)? onOpenDetail;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

final class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _openManualLog(Activity a) =>
      showQuickUpdateSheet(context, ref, a);

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(homeSearchProvider);
    final filter = ref.watch(homeFilterProvider);
    final activitiesAsync = ref.watch(activitiesStreamProvider);

    return Scaffold(
      backgroundColor: AppT.cream,
      // FAB neo-brutalist custom (design.md §7): kuning, border ink,
      // hard shadow 5px blur 0 — FloatingActionButton bawaan tidak bisa
      // menampilkan offset shadow tanpa blur.
      floatingActionButton: _KtkFab(onTap: () => showAddActivitySheet(context)),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header + search (design.md §7 Form Input) ──────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: TextField(
                onChanged: (v) =>
                    ref.read(homeSearchProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: 'Cari aktivitas...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppT.inkSoft,
                  ),
                  suffixIcon: search.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppT.inkSoft,
                          ),
                          onPressed: () =>
                              ref.read(homeSearchProvider.notifier).state = '',
                        ),
                  filled: true,
                  fillColor: AppT.surface,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppT.ink,
                      width: AppT.borderW,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const CategoryChipBar(),
            const SizedBox(height: 12),
            // ── List / states ───────────────────────────────────────────
            Expanded(
              child: activitiesAsync.when(
                loading: () => const _LoadingState(),
                error: (e, _) => _ErrorState(
                  message:
                      'Waduh! Otak KTK lagi korslet sebentar nih. '
                      'Tenang, catatan kamu aman kok di memori HP.',
                  onRetry: () {
                    // Restart rantai provider: database → repository → stream.
                    ref.invalidate(databaseProvider);
                  },
                ),
                data: (activities) {
                  // Satu-satunya tempat filter diterapkan (mudah dites).
                  final filtered = applyHomeFilters(
                    activities,
                    categoryId: filter,
                    query: search,
                  );
                  if (activities.isEmpty) return const _EmptyState();
                  if (filtered.isEmpty) {
                    return _NoMatchState(
                      query: search,
                      isCategoryFilter: search.trim().isEmpty,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final a = filtered[i];
                      return ActivityCard(
                        activity: a,
                        onManualLog: () => _openManualLog(a),
                        onOpenDetail: () {
                          final cb = widget.onOpenDetail;
                          if (cb != null) {
                            cb(a.id);
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Sabar ya, halaman detail datang di Fase 3 😉',
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── States (PRD §7) ─────────────────────────────────────────────────────

final class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ClockMascot(size: 130),
            const SizedBox(height: 20),
            const Text(
              'Waduh, masih kosong melompong nih!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppT.fontDisplay,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppT.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yuk, masukin aktivitas pertama kamu dengan tombol "+" di '
              'bawah. Biar temen kamu (si KTK) ini bisa bantu jagain '
              'ingatan sepelemu!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppT.fontBody,
                fontSize: 14,
                height: 1.5,
                color: AppT.inkSoft.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer sederhana — bentuk kartu beranda (PRD §7 Loading State).
final class _LoadingState extends StatefulWidget {
  const _LoadingState();

  @override
  State<_LoadingState> createState() => _LoadingStateState();
}

final class _LoadingStateState extends State<_LoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = 0.25 + 0.45 * _c.value;
        return Opacity(
          opacity: t,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, _) => Container(
              height: 96,
              decoration: BoxDecoration(
                color: AppT.surface,
                borderRadius: BorderRadius.circular(AppT.radius),
                border: Border.all(color: AppT.divider, width: AppT.borderWs),
              ),
            ),
          ),
        );
      },
    );
  }
}

final class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ClockMascot(size: 110, showQuestionMark: false),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppT.fontBody,
                fontSize: 14,
                height: 1.5,
                color: AppT.inkSoft,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kalau muncul terus? Coba full rebuild (flutter run),\n'
              'bukan hot reload.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppT.fontBody,
                fontSize: 12,
                color: AppT.inkMute,
              ),
            ),
            const SizedBox(height: 20),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppT.radius),
              child: InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(AppT.radius),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppT.yellow,
                    border: Border.all(color: AppT.ink, width: AppT.borderW),
                    borderRadius: BorderRadius.circular(AppT.radius),
                    boxShadow: const [
                      BoxShadow(offset: Offset(3, 3), color: AppT.ink),
                    ],
                  ),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontFamily: AppT.fontDisplay,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppT.ink,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ada aktivitas tapi hasil filter/pencarian kosong (design.md §12 tone).
final class _NoMatchState extends StatelessWidget {
  const _NoMatchState({required this.query, this.isCategoryFilter = false});

  final String query;

  final bool isCategoryFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        isCategoryFilter
            ? 'Belum ada aktivitas di kategori ini.'
            : 'Nggak ada yang cocok sama "$query".\nCoba kata kunci lain?',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: AppT.fontBody,
          fontSize: 14,
          height: 1.5,
          color: AppT.inkSoft,
        ),
      ),
    );
  }
}

/// FAB neo-brutalist (design.md §7 FAB): 56×56, radius 14, kuning, border
/// ink 2.5px, hard shadow 5px blur 0. FloatingActionButton bawaan tidak
/// bisa menampilkan offset shadow tanpa blur, jadi dibuat custom.
final class _KtkFab extends StatelessWidget {
  const _KtkFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppT.yellow,
          borderRadius: BorderRadius.circular(AppT.radiusFab),
          border: Border.all(color: AppT.ink, width: AppT.borderW),
          boxShadow: AppT.shadow,
        ),
        child: const Icon(Icons.add_rounded, size: 28, color: AppT.ink),
      ),
    );
  }
}
