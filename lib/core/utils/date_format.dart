/// Formatting tanggal & label waktu untuk UI — gaya design.md §7
/// ("TERAKHIR: SENIN, 8 SEP" dsb). Lokal Indonesia.
library;

const List<String> _dayNames = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// "Senin, 8 Sep 2026".
String formatFullDate(DateTime d) =>
    '${_dayNames[d.weekday - 1]}, ${d.day} ${_monthNames[d.month - 1]} ${d.year}';

/// "SEN, 8 SEP".
String formatShortDate(DateTime d) =>
    '${_dayNames[d.weekday - 1].substring(0, 3).toUpperCase()}, '
    '${d.day} ${_monthNames[d.month - 1].toUpperCase()}';

/// "SENIN, 8 SEP" (tanpa tahun, untuk expanded card).
String formatCardDate(DateTime d) =>
    '${_dayNames[d.weekday - 1].toUpperCase()}, ${d.day} ${_monthNames[d.month - 1].toUpperCase()}';

/// Pratinjau pilihan di Quick Update sheet: "Senin, 8 Sep 2026 · 21:00".
String formatSheetDate(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${_dayNames[d.weekday - 1]}, ${d.day} ${_monthNames[d.month - 1]} '
      '${d.year} · $hh:$mm';
}
