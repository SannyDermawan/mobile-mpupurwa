/// Satu-satunya sumber jam buka Museum Mpu Purwa, mengikuti admin web:
/// **Senin sampai Jumat pukul 08.00–16.00, Sabtu dan Minggu tutup.**
///
/// Jam buka di HTML desain (08.00–15.00, Senin tutup) sudah usang dan tidak
/// boleh disalin. Layar mana pun yang menampilkan jam buka (Beranda, Info,
/// dan seterusnya) wajib memakai kelas ini, jangan menulis jam langsung.
abstract final class MuseumHours {
  static const int openHour = 8;
  static const int openMinute = 0;
  static const int closeHour = 16;
  static const int closeMinute = 0;

  /// Hari buka memakai nomor `DateTime.weekday` (Senin = 1 … Minggu = 7).
  static const Set<int> openWeekdays = {
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
  };

  static const String firstOpenDayName = 'Senin';
  static const String lastOpenDayName = 'Jumat';
  static const String closedDaysName = 'Sabtu – Minggu';

  static String get openTime => _format(openHour, openMinute);
  static String get closeTime => _format(closeHour, closeMinute);

  /// "08.00 – 16.00" (dengan spasi), untuk baris jam operasional.
  static String get rangeText => '$openTime – $closeTime';

  /// "08.00–16.00" (tanpa spasi), untuk kalimat seperti "pukul 08.00–16.00".
  static String get rangeTextCompact => '$openTime–$closeTime';

  /// "Senin – Jumat", untuk baris jam operasional.
  static String get openDaysText => '$firstOpenDayName – $lastOpenDayName';

  /// "Senin–Jumat", untuk kalimat.
  static String get openDaysTextCompact => '$firstOpenDayName–$lastOpenDayName';

  /// Apakah [now] jatuh di hari buka (hanya mengecek hari, bukan jam).
  static bool isOpenToday(DateTime now) => openWeekdays.contains(now.weekday);

  /// Baris untuk kartu "Jam Operasional": label hari dan jamnya.
  static List<HoursEntry> get rows => [
    HoursEntry(openDaysText, rangeText),
    const HoursEntry(closedDaysName, 'Tutup'),
  ];

  static String _format(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';
}

/// Satu baris jam operasional, mis. `Senin – Jumat` → `08.00 – 16.00`.
class HoursEntry {
  const HoursEntry(this.label, this.value);

  final String label;
  final String value;
}
