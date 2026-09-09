/// Design tokens — the Flutter mirror of the `T` object in `KTKMobileApp/design.md`.
///
/// Single source of truth for colors, borders, shadows, radii, and fonts.
/// Hard rule (AGENT.md §5): no hardcoded hex/shadow values in widgets —
/// everything goes through [AppT].
library;

import 'package:flutter/material.dart';

/// Neo-brutalist design tokens (see `KTKMobileApp/design.md` §2–§8).
abstract final class AppT {
  // ── Background & surface (design.md §2) ──────────────────────────────
  /// Main app background.
  static const Color cream = Color(0xFFFDF6E3);

  /// Cards, sheets — floats above cream.
  static const Color surface = Color(0xFFFFFEF7);

  /// Expanded card panel (slightly darker than cream).
  static const Color panel = Color(0xFFF5EFD4);

  /// Notification preview bubble / quote.
  static const Color bubble = Color(0xFFF0EAD0);

  /// Soft divider border.
  static const Color divider = Color(0xFFEDE8D0);

  // ── Text (design.md §2) ───────────────────────────────────────────────
  /// Primary text, borders, shadows.
  static const Color ink = Color(0xFF1A1A1A);

  /// Secondary text.
  static const Color inkSoft = Color(0xFF555555);

  /// Placeholder, small labels, metadata.
  static const Color inkMute = Color(0xFF888888);

  // ── Accents (design.md §2) ────────────────────────────────────────────
  /// Primary action, FAB, highlights, main CTA.
  static const Color yellow = Color(0xFFFFB703);

  /// Success, just-logged, "today".
  static const Color green = Color(0xFF2DC653);

  /// Danger, delete, most-neglected activity.
  static const Color red = Color(0xFFE63946);

  /// Warning, active bell, 8–30 days.
  static const Color orange = Color(0xFFF2994A);

  /// Info, 1–7 days, stat counts.
  static const Color blue = Color(0xFF2D9CDB);

  /// Just-logged card background.
  static const Color greenTint = Color(0xFFF0FFF4);

  /// Inactive toggle background.
  static const Color toggleOff = Color(0xFFC8C0A0);

  // ── Borders & shadows (design.md §4) ──────────────────────────────────
  /// Main neo-brutalist border: 2.5px solid ink.
  static const double borderW = 2.5;

  /// Secondary border width (1.5px).
  static const double borderWs = 1.5;

  /// Hard offset shadow — cards, CTA, FAB. Blur is ALWAYS 0 (design.md §4).
  static const List<BoxShadow> shadow = [
    BoxShadow(offset: Offset(5, 5), blurRadius: 0, color: ink),
  ];

  /// Small hard shadow — small cards, active inputs, secondary buttons.
  static const List<BoxShadow> shadowSm = [
    BoxShadow(offset: Offset(3, 3), blurRadius: 0, color: ink),
  ];

  /// Just-logged state shadow (green).
  static const List<BoxShadow> shadowGreen = [
    BoxShadow(offset: Offset(5, 5), blurRadius: 0, color: green),
  ];

  /// Premium card / KTK Score tile shadow (yellow).
  static const List<BoxShadow> shadowYellow = [
    BoxShadow(offset: Offset(4, 4), blurRadius: 0, color: yellow),
  ];

  // ── Radii (design.md §4) ──────────────────────────────────────────────
  /// Main cards, big buttons, sheet container.
  static const double radius = 12;

  /// Small buttons, inputs, badges.
  static const double radiusSm = 8;

  /// FAB radius.
  static const double radiusFab = 14;

  // ── Typography (design.md §3) ─────────────────────────────────────────
  /// Display / headings / big day numbers.
  static const String fontDisplay = 'Caveat';

  /// Body copy, labels, metadata.
  static const String fontBody = 'DM Sans';

  /// Uppercase label letter spacing (design.md §3).
  static const double trackingLabel = 0.10;

  // ── Motion (design.md §8: max 300ms, functional only) ────────────────
  /// Standard state-change / transition duration.
  static const Duration transition = Duration(milliseconds: 250);

  /// Sheet slide-up duration.
  static const Duration sheetIn = Duration(milliseconds: 280);

  /// Just-logged state change duration.
  static const Duration justLogged = Duration(milliseconds: 250);
}

/// Days-counter state color, per design.md §2:
/// 0d → green · 1–7d → blue · 8–30d → orange · >30d → red.
Color daysSinceColor(int days) {
  if (days <= 0) return AppT.green;
  if (days <= 7) return AppT.blue;
  if (days <= 30) return AppT.orange;
  return AppT.red;
}
