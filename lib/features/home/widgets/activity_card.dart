import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_tokens.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/activity.dart';
import '../viewmodels/home_viewmodel.dart';

/// Kartu aktivitas beranda — design.md §7 ActivityCard.
///
/// Collapsed: nama (Caveat 19 UPPERCASE), kategori, angka days-since besar
/// (Caveat 64, warna state), tombol quick log 54×54. Expanded (tap body):
/// panel #F5EFD4 dengan tanggal terakhir + rata-rata interval + tombol
/// "Log Manual" (Quick Update sheet, SRS §2.1.2) dan "Detail →".
/// Swipe kiri = hapus (PRD §7, cascade SRS §3.3).
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
            color: justLogged ? AppT.greenTint : AppT.cream,
            border: Border.all(color: AppT.ink, width: AppT.borderW),
            borderRadius: BorderRadius.circular(AppT.radius),
            boxShadow: justLogged ? AppT.shadowGreen : AppT.shadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.name.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppT.fontDisplay,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppT.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                        if (a.isReminderActive) ...[
                          const SizedBox(height: 6),
                          const Icon(
                            Icons.notifications_active_rounded,
                            size: 16,
                            color: AppT.orange,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      justLogged
                          ? const Icon(
                              Icons.check_rounded,
                              size: 56,
                              color: AppT.green,
                            )
                          : Text(
                              days == null ? '—' : '$days',
                              style: TextStyle(
                                fontFamily: AppT.fontDisplay,
                                fontSize: 64,
                                fontWeight: FontWeight.w700,
                                height: 1,
                                color: days == null
                                    ? AppT.inkMute
                                    : daysSinceColor(days),
                              ),
                            ),
                      const SizedBox(height: 2),
                      Text(
                        justLogged ? 'DICATAT. AMAN.' : _daysLabel(days),
                        style: TextStyle(
                          fontFamily: AppT.fontBody,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: AppT.trackingLabel,
                          color: justLogged ? AppT.green : AppT.inkSoft,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  _QuickLogButton(
                    justLogged: justLogged,
                    onTap: () => _quickLog(a),
                    onLongPress: widget.onManualLog,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 12),
                _ExpandedPanel(
                  activity: a,
                  onManualLog: widget.onManualLog,
                  onOpenDetail: widget.onOpenDetail,
                ),
              ],
            ],
          ),
        ),
      ),
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

String _daysLabel(int? days) {
  if (days == null) return 'BELUM DICATAT';
  if (days == 0) return 'HARI INI';
  if (days == 1) return 'KEMARIN';
  return 'HARI LALU';
}

/// Tombol lingkaran quick log 54×54 — kuning, hijau saat just-logged
/// (design.md §7). Long-press = buka Quick Update sheet (manual date).
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
          shape: BoxShape.circle,
          border: Border.all(color: AppT.ink, width: AppT.borderW),
          boxShadow: justLogged ? AppT.shadowGreen : AppT.shadowSm,
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

/// Panel expanded — background #F5EFD4, tanggal terakhir + rata-rata,
/// tombol Log Manual & Detail (design.md §7).
final class _ExpandedPanel extends StatelessWidget {
  const _ExpandedPanel({
    required this.activity,
    required this.onManualLog,
    required this.onOpenDetail,
  });

  final Activity activity;
  final VoidCallback onManualLog;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final lastLine = a.lastLoggedAt == null
        ? 'Belum pernah dicatat — tap pin di kanan biar KTK jagain.'
        : 'TERAKHIR: ${formatCardDate(a.lastLoggedAt!)}'
              '${a.avgIntervalDays == null ? '' : ' · RATA-RATA: ~${a.avgIntervalDays!.round()} HARI'}';

    return Container(
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
                  onTap: onManualLog,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PanelButton(
                  label: 'Detail →',
                  icon: Icons.chevron_right_rounded,
                  background: AppT.ink,
                  foreground: AppT.cream,
                  onTap: onOpenDetail,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
      color: background,
      borderRadius: BorderRadius.circular(AppT.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppT.radiusSm),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppT.ink, width: AppT.borderW),
            borderRadius: BorderRadius.circular(AppT.radiusSm),
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
