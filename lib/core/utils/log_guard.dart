/// Time-travel guard — SRS §6.1.
///
/// If the device clock is moved to the past so that `T_now < T_last_logged`,
/// the system must reject the write and show the casual "mesin waktu"
/// dialog. Future-dated manual logs are rejected for the same reason.
library;

/// Thrown when a log write violates the time-travel guard.
/// [message] is ready-to-show casual UI copy.
final class TimeTravelException implements Exception {
  const TimeTravelException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Validates [loggedAt] against the device time and the stored latest log.
///
/// - `loggedAt > now` → future-dated write, reject.
/// - `loggedAt < latestLoggedAt` → device clock moved backwards past the
///   latest stored log (SRS §6.1), reject.
void validateNewLog(
  DateTime loggedAt, {
  required DateTime now,
  DateTime? latestLoggedAt,
}) {
  if (loggedAt.isAfter(now)) {
    throw const TimeTravelException(
      'Waduh! Kamu punya mesin waktu ya? Tanggalnya nggak boleh di masa depan dong.',
    );
  }
  if (latestLoggedAt != null && loggedAt.isBefore(latestLoggedAt)) {
    throw const TimeTravelException(
      'Waduh! Kamu punya mesin waktu ya? Tanggal HP kamu kok kembali ke masa '
      'lalu. Benerin dulu yuk jamnya biar KTK ga bingung!',
    );
  }
}
