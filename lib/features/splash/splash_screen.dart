import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/design/app_tokens.dart';
import '../../core/widgets/clock_mascot.dart';

/// Splash screen — design.md §9: mascot, brand "KTK", three pulsing dots.
/// Lasts 2.3s with fade-out starting at 1.8s, then [onDone] is invoked.
/// (For Phase 0 it always routes to the main shell; the onboarding check
/// arrives with the profile store in Phase 6.)
final class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

final class _SplashScreenState extends State<SplashScreen> {
  bool _fading = false;
  Timer? _exitTimer;

  @override
  void initState() {
    super.initState();
    // Fade-out begins at 1.8s; hard exit at 2.3s (design.md §9).
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _fading = true);
    });
    _exitTimer = Timer(const Duration(milliseconds: 2300), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppT.cream,
      body: AnimatedOpacity(
        opacity: _fading ? 0 : 1,
        duration: AppT.sheetIn,
        curve: Curves.easeOut,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ClockMascot(size: 150),
              const SizedBox(height: 24),
              // Brand — display 42–72px Caveat 700 (design.md §3).
              Text(
                'KTK',
                style: TextStyle(
                  fontFamily: AppT.fontDisplay,
                  fontSize: 64,
                  fontWeight: FontWeight.w700,
                  color: AppT.ink,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Kapan Terakhir Kali...?',
                style: TextStyle(
                  fontFamily: AppT.fontBody,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: AppT.trackingLabel,
                  color: AppT.inkSoft,
                ),
              ),
              const SizedBox(height: 36),
              const _PulsingDots(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three dots pulsing with a 0.2s offset each (design.md §8 dotPulse).
final class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

final class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Each dot offset by 0.2s of the 1.2s cycle.
              final t = (_controller.value + i * 0.2 / 1.2) % 1;
              // dip to 0.3 opacity / 0.8 scale, peak at 1.0 / 1.2.
              final phase = (1 - (2 * t - 1).abs()).clamp(0.0, 1.0);
              final scale = 0.8 + 0.4 * phase;
              final opacity = 0.3 + 0.7 * phase;
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppT.yellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppT.ink, width: 1.5),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
