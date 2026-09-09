import 'package:flutter/foundation.dart' show immutable;

import '../../core/db/standard_categories.dart';
import '../../core/utils/days_since.dart' as day_math;

/// Reminder tone of voice (SRS §4: SANTAI / SARCASTIC / SUPORTIF).
enum ReminderTone {
  santai('SANTAI'),
  sarcastic('SARCASTIC'),
  suportif('SUPORTIF');

  const ReminderTone(this.dbValue);

  final String dbValue;

  static ReminderTone fromDb(String v) => ReminderTone.values.firstWhere(
    (t) => t.dbValue == v,
    orElse: () => ReminderTone.santai,
  );
}

/// Status langganan — IAP nyata menyusul di Fase 7 (PRD FR-002).
enum SubscriptionPlan { basic, premium }

/// UI-facing model for an activity (design.md §10 variant of SRS §4).
@immutable
final class Activity {
  const Activity({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.icon,
    required this.isReminderActive,
    this.reminderInterval,
    this.reminderTone,
    required this.createdAt,
    required this.lastLoggedAt,
    required this.logCount,
  });

  /// UUID v4 (SRS §4).
  final String id;

  final String name;

  /// 1–10 standar; kategori Kesehatan mengunci tone ke SUPORTIF (SRS §3.2).
  final int categoryId;

  /// Emoji pilihan user (design.md §5).
  final String icon;

  final bool isReminderActive;

  /// Interval hari (nullable, SRS §4).
  final int? reminderInterval;

  final ReminderTone? reminderTone;

  final DateTime createdAt;

  /// Tanggal log terakhir — null jika belum pernah dicatat.
  final DateTime? lastLoggedAt;

  /// Jumlah riwayat tersimpan (untuk gating tampilan 5 entri, FR-002).
  final int logCount;

  /// Selisih hari kalender lokal (SRS §3.1) — null jika belum ada log.
  int? daysSince({DateTime? now}) =>
      lastLoggedAt == null ? null : day_math.daysSince(lastLoggedAt!, now: now);

  /// Kategori Kesehatan → tone dikunci SUPORTIF (safety-critical, SRS §3.2).
  bool get isHealthCategory => categoryId == kHealthCategoryId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Activity &&
          other.id == id &&
          other.name == name &&
          other.categoryId == categoryId &&
          other.icon == icon &&
          other.isReminderActive == isReminderActive &&
          other.reminderInterval == reminderInterval &&
          other.reminderTone == reminderTone &&
          other.createdAt == createdAt &&
          other.lastLoggedAt == lastLoggedAt &&
          other.logCount == logCount;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    categoryId,
    icon,
    isReminderActive,
    reminderInterval,
    reminderTone,
    createdAt,
    lastLoggedAt,
    logCount,
  );
}

/// UI-facing model for a single history entry (SRS §4 Log).
@immutable
final class LogEntry {
  const LogEntry({
    required this.id,
    required this.activityId,
    required this.loggedAt,
    this.notes,
  });

  final String id;

  final String activityId;

  final DateTime loggedAt;

  /// Catatan tambahan — Premium only (PRD Feature 01).
  final String? notes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogEntry &&
          other.id == id &&
          other.activityId == activityId &&
          other.loggedAt == loggedAt &&
          other.notes == notes;

  @override
  int get hashCode => Object.hash(id, activityId, loggedAt, notes);
}

/// UI-facing category (seeded standard 10, design.md §2).
@immutable
final class Category {
  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorHex,
  });

  final int id;

  final String name;

  final String emoji;

  /// `#RRGGBB` (design.md §2).
  final String colorHex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          other.id == id &&
          other.name == name &&
          other.emoji == emoji &&
          other.colorHex == colorHex;

  @override
  int get hashCode => Object.hash(id, name, emoji, colorHex);
}
