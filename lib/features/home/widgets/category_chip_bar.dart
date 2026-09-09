import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_tokens.dart';
import '../viewmodels/home_viewmodel.dart';

/// Filter chip horizontal "Semua + 10 kategori" (PRD §7 Main Dashboard,
/// design.md §7 Chip: aktif = background ink, teks cream).
final class CategoryChipBar extends ConsumerWidget {
  const CategoryChipBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(homeFilterProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 11,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          // Index 0 = "Semua" (filter null), 1..10 = id kategori.
          final categoryId = i == 0 ? null : i;
          final active = selected == categoryId;
          final label = categoryId == null
              ? 'Semua'
              : categoryLabel(categoryId);
          final emoji = categoryId == null
              ? ''
              : '${categoryEmoji(categoryId)} ';

          return GestureDetector(
            onTap: () =>
                ref.read(homeFilterProvider.notifier).state = categoryId,
            child: AnimatedContainer(
              duration: AppT.transition,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppT.ink : AppT.cream,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppT.ink,
                  width: active ? AppT.borderW : AppT.borderWs,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (emoji.isNotEmpty)
                      Text(emoji, style: const TextStyle(fontSize: 12)),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppT.fontBody,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? AppT.cream : AppT.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
