import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ktk/core/design/app_tokens.dart';
import 'package:ktk/core/widgets/clock_mascot.dart';
import 'package:ktk/features/splash/splash_screen.dart';
import 'package:ktk/main.dart';

void main() {
  group('design tokens (design.md §2/§4)', () {
    test('daysSinceColor matches days-counter state colors', () {
      expect(daysSinceColor(0), AppT.green); // Hari ini
      expect(daysSinceColor(5), AppT.blue); // 1–7 hari
      expect(daysSinceColor(15), AppT.orange); // 8–30 hari
      expect(daysSinceColor(31), AppT.red); // >30 hari
    });

    test('shadows are hard offset — blur is always 0', () {
      for (final shadows in [
        AppT.shadow,
        AppT.shadowSm,
        AppT.shadowGreen,
        AppT.shadowYellow,
      ]) {
        for (final s in shadows) {
          expect(s.blurRadius, 0, reason: 'Neo-brutalism: blur must be 0');
        }
      }
    });
  });

  group('ClockMascot', () {
    testWidgets('paints without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Center(child: ClockMascot(size: 120))),
      );
      expect(find.byType(ClockMascot), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('SplashScreen (design.md §9)', () {
    testWidgets('shows brand and mascot, then exits after 2.3s', (
      tester,
    ) async {
      var done = false;
      await tester.pumpWidget(
        MaterialApp(home: SplashScreen(onDone: () => done = true)),
      );

      expect(find.text('KTK'), findsOneWidget);
      expect(find.text('Kapan Terakhir Kali...?'), findsOneWidget);
      expect(find.byType(ClockMascot), findsOneWidget);

      // Fade starts at 1.8s but exit happens at 2.3s.
      await tester.pump(const Duration(milliseconds: 1800));
      expect(done, isFalse);
      await tester.pump(const Duration(milliseconds: 501));
      expect(done, isTrue);
    });
  });

  group('AppShell navigation (design.md §9)', () {
    testWidgets('starts on Beranda and switches between all 4 tabs', (
      tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: KtkApp()));
      // Skip the 2.3s splash.
      await tester.pump(const Duration(milliseconds: 2301));

      // Header shows the current tab title; nav labels are uppercase.
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('BERANDA'), findsOneWidget);

      await tester.tap(find.text('INSIGHT'));
      await tester.pumpAndSettle();
      expect(find.text('Insight'), findsOneWidget);

      await tester.tap(find.text('PROFIL'));
      await tester.pumpAndSettle();
      expect(find.text('Profil'), findsOneWidget);

      await tester.tap(find.text('PENGATURAN'));
      await tester.pumpAndSettle();
      expect(find.text('Pengaturan'), findsOneWidget);

      await tester.tap(find.text('BERANDA'));
      await tester.pumpAndSettle();
      expect(find.text('Beranda'), findsOneWidget);
    });
  });
}
