import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_tokens.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/log_guard.dart';
import '../../../core/widgets/ktk_sheet.dart';
import '../../../data/di.dart';
import '../../../data/models/activity.dart';

/// SCR-02 — Quick Update Bottom Sheet (SRS §2.1.2): bawa default waktu
/// sekarang, bisa disesuaikan untuk mencatat waktu lampau; notes = Premium
/// (field terkunci sampai Fase 7 paywall).
Future<void> showQuickUpdateSheet(
  BuildContext context,
  WidgetRef ref,
  Activity activity,
) {
  return showKtkSheet(
    context: context,
    builder: (_) => _QuickUpdateSheet(activity: activity),
  );
}

final class _QuickUpdateSheet extends ConsumerStatefulWidget {
  const _QuickUpdateSheet({required this.activity});

  final Activity activity;

  @override
  ConsumerState<_QuickUpdateSheet> createState() => _QuickUpdateSheetState();
}

final class _QuickUpdateSheetState extends ConsumerState<_QuickUpdateSheet> {
  late DateTime _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = DateTime.now();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Kapan terakhir kali?',
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selected),
      helpText: 'Jam berapa?',
    );
    if (!mounted) return;
    setState(() {
      _selected = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _selected.hour,
        time?.minute ?? _selected.minute,
      );
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = await ref.read(activityRepositoryProvider.future);
    try {
      await repo.addLog(widget.activity.id, loggedAt: _selected);
    } on TimeTravelException catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
      return;
    } catch (_) {
      // DB gagal (mis. plugin native belum terdaftar) — reset tombol agar
      // tidak nyangkut di "Nyimpen..." selamanya.
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waduh, gagal nyimpen. Coba lagi ya!')),
      );
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          a.name,
          style: const TextStyle(
            fontFamily: AppT.fontDisplay,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppT.ink,
          ),
        ),
        const Text(
          'KAPAN TERAKHIR DILAKUIN?',
          style: TextStyle(
            fontFamily: AppT.fontBody,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: AppT.trackingLabel,
            color: AppT.inkSoft,
          ),
        ),
        const SizedBox(height: 16),
        // Date preview + picker — design.md §7 Form Input.
        Material(
          color: AppT.surface,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                border: Border.all(color: AppT.ink, width: AppT.borderW),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: AppT.ink,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      formatSheetDate(_selected),
                      style: const TextStyle(
                        fontFamily: AppT.fontDisplay,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppT.ink,
                      ),
                    ),
                  ),
                  const Icon(Icons.edit_rounded, size: 16, color: AppT.inkSoft),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Notes — Premium only (design.md §11). Field terkunci sementara;
        // paywall menyusul di Fase 7.
        Stack(
          children: [
            TextField(
              enabled: false,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Tambahin catatan... (Premium)',
                hintStyle: const TextStyle(fontFamily: AppT.fontBody),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppT.ink,
                    width: AppT.borderW,
                  ),
                ),
              ),
            ),
            const Positioned(
              right: 12,
              top: 12,
              child: Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: AppT.inkSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        KtkPrimaryButton(
          label: _saving ? 'Nyimpen...' : 'Simpan',
          onTap: _saving ? null : _save,
        ),
      ],
    );
  }
}
