import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_tokens.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/activity.dart';
import '../viewmodels/home_viewmodel.dart';

/// Kartu aktivitas beranda — mirror 1:1 ActivityCard di prototype
/// `KTKMobileApp/src/App.tsx`:
/// - Latar kartu **putih** (AppT.surface #FFFEF7), shadow ink 5px keras.
/// - Dua baris: atas = ikon + nama + kategori + caret berputar; bawah =
///   angka days-since besar di kiri + tombol quick log 54×54 di kanan.
/// - Belum dicatat: angka diganti teks italic "Belum pernah dicatat...".
/// - Just-logged: latar #F0FFF4, shadow hijau, angka → centang.
/// Tap body membuka panel #F5EFD4 dengan **animasi smooth**: ukuran
/// di-animate via AnimatedSize + konten fade+slide via AnimatedSwitcher
/// (design.md §8: ≤300 ms).
final class ActivityCard extends ConsumerStatefulWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.onManualLog,
    required this.onOpenDetail,
    this.onEdited,
  });

  final Activity activity;

  /// Buka Quick Update Bottom Sheet (SCR-02).
  final VoidCallback onManualLog;

  /// Buka halaman detail (Fase 3 — untuk kini tampilkan snackbar).
  final VoidCallback onOpenDetail;

  /// Callback ketika kartu diubah (rename) via swipe-to-edit.
  final ValueChanged<String>? onEdited;

  @override
  ConsumerState<ActivityCard> createState() => _ActivityCardState();
}

final class _ActivityCardState extends ConsumerState<ActivityCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    final justLogged = ref.watch(justLoggedIdsProvider).contains(a.id);
    final days = a.daysSince();

    return Dismissible(
      key: ValueKey('dismiss-${a.id}'),
      direction: DismissDirection.endToStart,
      background: _swipeBackground(context),
      confirmDismiss: (direction) => _confirmDelete(context),
      onDismissed: (_) => ref.read(homeControllerProvider).deleteActivity(a.id),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: AppT.transition,
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: justLogged ? AppT.greenTint : AppT.surface,
            border: Border.all(color: AppT.ink, width: AppT.borderW),
            borderRadius: BorderRadius.circular(AppT.radius + 2),
            boxShadow: justLogged ? AppT.shadowGreen : AppT.shadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Baris 1: ikon + nama + kategori + caret ────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppT.fontDisplay,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppT.ink,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${categoryEmoji(a.categoryId)} '
                          '${categoryLabel(a.categoryId)}',
                          style: TextStyle(
                            fontFamily: AppT.fontBody,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.06,
                            color: colorFromHex(categoryHex(a.categoryId)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (a.isReminderActive) ...[
                    const Icon(
                      Icons.notifications_active_rounded,
                      size: 14,
                      color: AppT.orange,
                    ),
                    const SizedBox(width: 6),
                  ],
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: AppT.transition,
                    curve: Curves.easeOut,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppT.inkMute,
                    ),
                  ),
                ],
              ),
              // ── Baris 2: angka days-since + tombol quick log ───────────
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: justLogged
                          ? const _JustLoggedBadge()
                          : _DaysBlock(days: days),
                    ),
                    const SizedBox(width: 12),
                    _QuickLogButton(
                      justLogged: justLogged,
                      onTap: () => _quickLog(a),
                      onLongPress: widget.onManualLog,
                    ),
                  ],
                ),
              ),
              // ── Panel expanded (animasi smooth, design.md §8) ──────────
              // AnimatedSize: tinggi panel tumbuh/mengecil mulus;
              // AnimatedSwitcher: konten fade+slide masuk/keluar.
              ClipRect(
                child: AnimatedSize(
                  duration: AppT.transition,
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: AppT.transition,
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.08),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _expanded
                        ? KeyedSubtree(
                            key: ValueKey('panel-${a.id}'),
                            child: _panel(),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Panel expanded — animasi dua lapis: AnimatedSize (height smooth,
  /// 250 ms easeOut) + AnimatedSwitcher (fade + slide konten).
  Widget _panel() {
    final a = widget.activity;
    final lastLine = a.lastLoggedAt == null
        ? 'Belum pernah dicatat — tap pin di kanan biar KTK jagain.'
        : 'TERAKHIR: ${formatCardDate(a.lastLoggedAt!)}'
              '${a.avgIntervalDays == null ? '' : ' · RATA-RATA: ~${a.avgIntervalDays!.round()} HARI'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppT.panel,
            borderRadius: BorderRadius.circular(AppT.radiusSm),
            border: Border.all(color: AppT.ink, width: AppT.borderWs),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                lastLine,
                style: const TextStyle(
                  fontFamily: AppT.fontBody,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppT.inkSoft,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _PanelButton(
                      label: 'Log Manual',
                      icon: Icons.edit_note_rounded,
                      background: AppT.cream,
                      foreground: AppT.ink,
                      onTap: widget.onManualLog,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PanelButton(
                      label: 'Detail →',
                      icon: Icons.chevron_right_rounded,
                      background: AppT.ink,
                      foreground: AppT.cream,
                      onTap: widget.onOpenDetail,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _quickLog(Activity a) async {
    // Umpan balik taktil ringan (PRD §7 Key Interactions).
    HapticFeedback.mediumImpact();
    final error = await ref.read(homeControllerProvider).quickLog(a);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final a = widget.activity;
    final delete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppT.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppT.radius),
          side: const BorderSide(color: AppT.ink, width: AppT.borderW),
        ),
        title: const Text(
          'Hapus kartu ini?',
          style: TextStyle(fontFamily: AppT.fontDisplay, fontSize: 24),
        ),
        content: Text(
          '"${a.name}" beserta ${a.logCount} riwayatnya akan hilang. '
          'Nggak bisa di-undo lho!',
          style: const TextStyle(fontFamily: AppT.fontBody, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(fontFamily: AppT.fontBody),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                fontFamily: AppT.fontBody,
                fontWeight: FontWeight.w700,
                color: AppT.red,
              ),
            ),
          ),
        ],
      ),
    );
    return delete ?? false;
  }

  Widget _swipeBackground(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppT.red,
        borderRadius: BorderRadius.circular(AppT.radius),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: AppT.cream),
    );
  }
}

/// Angka days-since besar (Caveat 64, warna state) + label di bawahnya.
/// Belum dicatat → teks italic "Belum pernah dicatat..." seperti prototype.
final class _DaysBlock extends StatelessWidget {
  const _DaysBlock({required this.days});

  final int? days;

  @override
  Widget build(BuildContext context) {
    if (days == null) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          'Belum pernah dicatat...',
          style: TextStyle(
            fontFamily: AppT.fontDisplay,
            fontSize: 17,
            fontStyle: FontStyle.italic,
            color: AppT.inkMute,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$days',
          style: TextStyle(
            fontFamily: AppT.fontDisplay,
            fontSize: 64,
            fontWeight: FontWeight.w700,
            height: 1,
            color: daysSinceColor(days!),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _daysLabel(days!),
          style: TextStyle(
            fontFamily: AppT.fontBody,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.14,
            color: daysSinceColor(days!),
          ),
        ),
      ],
    );
  }
}

String _daysLabel(int days) {
  if (days == 0) return 'HARI INI';
  if (days == 1) return 'KEMARIN';
  return 'HARI LALU';
}

/// State just-logged: centang besar hijau + "DICATAT. AMAN." (prototype).
final class _JustLoggedBadge extends StatelessWidget {
  const _JustLoggedBadge();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_rounded, size: 54, color: AppT.green),
        SizedBox(height: 4),
        Text(
          'DICATAT. AMAN.',
          style: TextStyle(
            fontFamily: AppT.fontBody,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.14,
            color: AppT.green,
          ),
        ),
      ],
    );
  }
}

/// Tombol quick log 54×54 — kuning, radius 10 (radiusSm+2), shadow 3px;
/// just-logged → hijau + shadow mengecil (prototype "pressed" look).
/// Long-press = buka Quick Update sheet (manual date).
final class _QuickLogButton extends StatelessWidget {
  const _QuickLogButton({
    required this.justLogged,
    required this.onTap,
    required this.onLongPress,
  });

  final bool justLogged;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: justLogged ? null : onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: AppT.justLogged,
        curve: Curves.easeOut,
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: justLogged ? AppT.green : AppT.yellow,
          borderRadius: BorderRadius.circular(AppT.radiusSm + 2),
          border: Border.all(color: AppT.ink, width: AppT.borderW),
          boxShadow: justLogged ? AppT.shadowXs : AppT.shadowSm,
        ),
        child: Icon(
          justLogged ? Icons.check_rounded : Icons.push_pin_rounded,
          size: 24,
          color: AppT.ink,
        ),
      ),
    );
  }
}

/// Panel button — mirror tombol prototype: cream (Log Manual) / ink
/// (Detail), border ink, hard shadow kecil, fill di BoxDecoration yang
/// sama dengan shadow agar shadow terpaint di belakang fill.
final class _PanelButton extends StatelessWidget {
  const _PanelButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppT.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppT.radiusSm),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: AppT.ink, width: AppT.borderW),
            borderRadius: BorderRadius.circular(AppT.radiusSm),
            boxShadow: const [
              BoxShadow(offset: Offset(2, 2), blurRadius: 0, color: AppT.ink),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppT.fontBody,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
