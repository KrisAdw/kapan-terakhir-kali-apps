/// Days-since calculation — SRS §3.1.
///
/// Hard rule: the difference is based on the device's **local calendar-day
/// change (local midnight)**, never a raw millisecond diff. An activity done
/// yesterday at 23:00 counts as "1 hari yang lalu" when checked today at
/// 01:00, even though only 2 hours have passed.
library;

/// Calendar days between the local day of [lastLogged] and the local day of
/// [now]. Negative if [lastLogged] is in the future (guard should have
/// rejected that — see `log_guard.dart`).
int daysSince(DateTime lastLogged, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final today = DateTime(ref.year, ref.month, ref.day);
  final logDay = DateTime(lastLogged.year, lastLogged.month, lastLogged.day);

  // Round instead of truncating so DST-cropped days (23h) still count as a
  // full calendar day. No-ops for exact 24h multiples.
  final days = (today.difference(logDay).inMinutes / 1440).round();
  return days;
}
