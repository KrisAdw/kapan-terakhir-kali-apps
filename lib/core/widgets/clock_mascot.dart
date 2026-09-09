import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/app_tokens.dart';

/// KTK mascot: an anthropomorphic wristwatch that looks confused — raised
/// eyebrows, a question-mark speech bubble, and a sweat drop (design.md §13).
/// Drawn with [CustomPaint] so no image assets are needed. Used on splash,
/// onboarding and empty states; never dominant in the UI.
final class ClockMascot extends StatelessWidget {
  const ClockMascot({super.key, this.size = 120, this.showQuestionMark = true});

  /// Square logical size of the drawing.
  final double size;

  /// Whether the "?" speech bubble is shown.
  final bool showQuestionMark;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MascotPainter(showQuestionMark: showQuestionMark),
    );
  }
}

final class _MascotPainter extends CustomPainter {
  const _MascotPainter({required this.showQuestionMark});

  final bool showQuestionMark;

  @override
  void paint(Canvas canvas, Size size) {
    // Design space: 100×100 units, scaled to the actual widget size.
    final u = size.width / 100;

    final stroke = Paint()
      ..color = AppT.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * u
      ..strokeCap = StrokeCap.round;
    final thinStroke = Paint()
      ..color = AppT.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * u
      ..strokeCap = StrokeCap.round;
    final fillInk = Paint()..color = AppT.ink;

    // Strap lugs (top & bottom), drawn first so the watch head overlaps them.
    final strapFill = Paint()..color = AppT.yellow;
    for (final top in [6 * u, 78 * u]) {
      final strap = RRect.fromRectAndRadius(
        Rect.fromLTWH(43 * u, top, 14 * u, 16 * u),
        Radius.circular(5 * u),
      );
      canvas.drawRRect(strap, strapFill);
      canvas.drawRRect(strap, thinStroke);
    }

    // Hard offset shadow — blur is always 0 (design.md §4).
    canvas.drawCircle(
      Offset(54 * u, 56 * u),
      36 * u,
      Paint()..color = AppT.ink,
    );

    // Watch head.
    final bodyCenter = Offset(50 * u, 52 * u);
    canvas.drawCircle(bodyCenter, 36 * u, Paint()..color = AppT.surface);
    canvas.drawCircle(bodyCenter, 36 * u, stroke);

    // Dial ticks at 12 / 3 / 6 / 9.
    for (final dir in const [
      Offset(0, -1),
      Offset(1, 0),
      Offset(0, 1),
      Offset(-1, 0),
    ]) {
      canvas.drawLine(
        bodyCenter + dir * (27 * u),
        bodyCenter + dir * (32 * u),
        thinStroke,
      );
    }

    // Raised, worried eyebrows.
    for (final x in [41.0, 59.0]) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(x * u, 47 * u),
          width: 12 * u,
          height: 10 * u,
        ),
        math.pi * 1.15,
        math.pi * 0.7,
        false,
        thinStroke,
      );
    }

    // Eyes.
    canvas.drawCircle(Offset(41 * u, 53 * u), 2.4 * u, fillInk);
    canvas.drawCircle(Offset(59 * u, 53 * u), 2.4 * u, fillInk);

    // Small confused "o" mouth.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(50 * u, 64 * u),
        width: 8 * u,
        height: 6 * u,
      ),
      thinStroke,
    );

    // Sweat drop (top-right).
    final drop = Path()
      ..moveTo(84 * u, 22 * u)
      ..quadraticBezierTo(78 * u, 30 * u, 84 * u, 33 * u)
      ..quadraticBezierTo(90 * u, 30 * u, 84 * u, 22 * u)
      ..close();
    canvas.drawPath(drop, Paint()..color = AppT.blue);
    canvas.drawPath(drop, thinStroke);

    // "?" speech bubble.
    if (showQuestionMark) {
      final bubble = RRect.fromRectAndRadius(
        Rect.fromLTWH(64 * u, 0, 32 * u, 22 * u),
        Radius.circular(6 * u),
      );
      canvas.drawRRect(bubble, Paint()..color = AppT.surface);
      canvas.drawRRect(bubble, thinStroke);

      final tail = Path()
        ..moveTo(71 * u, 21 * u)
        ..lineTo(67 * u, 27 * u)
        ..lineTo(77 * u, 22 * u)
        ..close();
      canvas.drawPath(tail, Paint()..color = AppT.surface);
      canvas.drawPath(tail, thinStroke);

      final q = TextPainter(
        text: TextSpan(
          text: '?',
          style: TextStyle(
            fontFamily: AppT.fontDisplay,
            fontSize: 20 * u,
            fontWeight: FontWeight.w700,
            color: AppT.ink,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      q.paint(
        canvas,
        Offset(64 * u + (32 * u - q.width) / 2, (22 * u - q.height) / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_MascotPainter oldDelegate) =>
      oldDelegate.showQuestionMark != showQuestionMark;
}
