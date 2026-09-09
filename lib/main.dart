import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_shell.dart';
import 'app/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: KtkApp()));
}

/// App phases (design.md §9): splash → main. The `onboarding` phase is
/// inserted by Phase 6 once the profile store exists.
enum AppPhase { splash, main }

/// Root widget driving the phase state machine.
final class KtkApp extends ConsumerStatefulWidget {
  const KtkApp({super.key});

  @override
  ConsumerState<KtkApp> createState() => _KtkAppState();
}

final class _KtkAppState extends ConsumerState<KtkApp> {
  AppPhase _phase = AppPhase.splash;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KTK: Kapan Terakhir Kali...?',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: switch (_phase) {
        AppPhase.splash => SplashScreen(
          onDone: () => setState(() => _phase = AppPhase.main),
        ),
        AppPhase.main => const AppShell(),
      },
    );
  }
}
