import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_tokens.dart';
import '../../../core/widgets/ktk_sheet.dart';
import '../viewmodels/home_viewmodel.dart';

/// Add Activity Sheet (PRD §7 Activity Form — versi quick-add dari sheet;
/// form lengkap dengan konfigurasi reminder menyusul di Fase 4).
Future<void> showAddActivitySheet(BuildContext context) {
  return showKtkSheet(
    context: context,
    builder: (_) => const _AddActivitySheet(),
  );
}

final class _AddActivitySheet extends ConsumerStatefulWidget {
  const _AddActivitySheet();

  @override
  ConsumerState<_AddActivitySheet> createState() => _AddActivitySheetState();
}

final class _AddActivitySheetState extends ConsumerState<_AddActivitySheet> {
  final _nameController = TextEditingController();
  int _category = 10;
  String _icon = '📌';
  bool _saving = false;
  String? _error;

  static const _iconChoices = [
    '📌',
    '🔧',
    '🛵',
    '🏠',
    '💆',
    '💊',
    '💰',
    '💻',
    '👥',
    '📋',
    '🚗',
    '🧹',
    '🏃',
    '🎸',
    '🐶',
    '🌱',
    '📚',
    '✂️',
    '🧺',
    '🗓️',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final String? error;
    try {
      error = await ref
          .read(homeControllerProvider)
          .createActivity(
            name: _nameController.text,
            categoryId: _category,
            icon: _icon,
          );
    } catch (_) {
      // DB gagal dibuka (mis. plugin native belum terdaftar) — jangan
      // biarkan tombol nyangkut di "Nyimpen..." selamanya.
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Waduh, gagal nyimpen. Coba lagi ya!';
      });
      return;
    }
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Aktivitas Baru',
          style: TextStyle(
            fontFamily: AppT.fontDisplay,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppT.ink,
          ),
        ),
        const Text(
          'MAU KTK JAGAIN YANG MANA?',
          style: TextStyle(
            fontFamily: AppT.fontBody,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: AppT.trackingLabel,
            color: AppT.inkSoft,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          autofocus: true,
          maxLength: 100,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(
            fontFamily: AppT.fontDisplay,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'mis. Ganti Oli Motor',
            hintStyle: TextStyle(
              fontFamily: AppT.fontDisplay,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: AppT.inkMute.withValues(alpha: 0.7),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppT.ink,
                width: AppT.borderW,
              ),
            ),
          ),
          onSubmitted: (_) => _save(),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(
              fontFamily: AppT.fontBody,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppT.red,
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          'KATEGORI',
          style: TextStyle(
            fontFamily: AppT.fontBody,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: AppT.trackingLabel,
            color: AppT.inkSoft,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var id = 1; id <= 10; id++)
              GestureDetector(
                onTap: () => setState(() => _category = id),
                child: AnimatedContainer(
                  duration: AppT.transition,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _category == id ? AppT.ink : AppT.cream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppT.ink,
                      width: _category == id ? AppT.borderW : AppT.borderWs,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        categoryEmoji(id),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        categoryLabel(id),
                        style: TextStyle(
                          fontFamily: AppT.fontBody,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _category == id ? AppT.cream : AppT.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'IKON',
          style: TextStyle(
            fontFamily: AppT.fontBody,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: AppT.trackingLabel,
            color: AppT.inkSoft,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _iconChoices.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final emoji = _iconChoices[i];
              final selected = emoji == _icon;
              return GestureDetector(
                onTap: () => setState(() => _icon = emoji),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppT.yellow : AppT.surface,
                    borderRadius: BorderRadius.circular(AppT.radiusSm),
                    border: Border.all(
                      color: AppT.ink,
                      width: selected ? AppT.borderW : AppT.borderWs,
                    ),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              );
            },
          ),
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
