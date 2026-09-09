import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/app_tokens.dart';

/// Bottom-nav tabs (design.md §9). Order: Beranda · Insight · Profil · Pengaturan.
enum AppTab { home, insight, profile, settings }

/// Main app shell — state-based routing (no go_router; design.md §10),
/// bottom navigation with the active yellow indicator (design.md §7).
/// Screens are Phase 0 placeholders; features land phase by phase.
final class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

final class _AppShellState extends ConsumerState<AppShell> {
  AppTab _tab = AppTab.home;

  static const _titles = {
    AppTab.home: 'Beranda',
    AppTab.insight: 'Insight',
    AppTab.profile: 'Profil',
    AppTab.settings: 'Pengaturan',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppT.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _titles[_tab]!,
                style: const TextStyle(
                  fontFamily: AppT.fontDisplay,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppT.ink,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Text(
                    'Fase 0 — kerangka siap.\n'
                    'Fitur "${_titles[_tab]}" menyusul di fase berikutnya.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppT.fontBody,
                      fontSize: 14,
                      color: AppT.inkSoft,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        current: _tab,
        onChanged: (tab) => setState(() => _tab = tab),
      ),
    );
  }
}

/// 64px bottom nav, 2.5px ink top border, yellow active indicator bar,
/// icon fill when active / regular when not (design.md §7).
final class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.current, required this.onChanged});

  final AppTab current;
  final ValueChanged<AppTab> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget item(AppTab tab, IconData icon, String label) {
      final active = tab == current;
      final color = active ? AppT.ink : AppT.inkMute;
      return Expanded(
        child: InkWell(
          onTap: () => onChanged(tab),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Icon(icon, size: 24, color: color),
                  // Active indicator: 24×3 yellow bar overlapping the top border.
                  if (active)
                    Positioned(
                      top: -17,
                      child: Container(
                        width: 24,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppT.yellow,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(3),
                          ),
                          border: Border.all(color: AppT.ink, width: 1),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontFamily: AppT.fontBody,
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: AppT.trackingLabel,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: AppT.cream,
          border: Border(
            top: BorderSide(color: AppT.ink, width: AppT.borderW),
          ),
        ),
        child: Row(
          children: [
            item(AppTab.home, Icons.home_rounded, 'Beranda'),
            item(AppTab.insight, Icons.bar_chart_rounded, 'Insight'),
            item(AppTab.profile, Icons.person_rounded, 'Profil'),
            item(AppTab.settings, Icons.settings_rounded, 'Pengaturan'),
          ],
        ),
      ),
    );
  }
}
