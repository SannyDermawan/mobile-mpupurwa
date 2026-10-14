import 'package:flutter_test/flutter_test.dart';
import 'package:museum_mpupurwa_app/core/constants/museum_hours.dart';

void main() {
  test('buka Senin sampai Jumat, tutup Sabtu dan Minggu', () {
    // 12 Oktober 2026 adalah hari Senin.
    for (var day = 12; day <= 16; day++) {
      expect(MuseumHours.isOpenToday(DateTime(2026, 10, day)), isTrue, reason: 'tanggal $day');
    }
    expect(MuseumHours.isOpenToday(DateTime(2026, 10, 17)), isFalse); // Sabtu
    expect(MuseumHours.isOpenToday(DateTime(2026, 10, 18)), isFalse); // Minggu
  });

  test('teks jam buka mengikuti admin web', () {
    expect(MuseumHours.rangeText, '08.00 – 16.00');
    expect(MuseumHours.rangeTextCompact, '08.00–16.00');
    expect(MuseumHours.openDaysText, 'Senin – Jumat');
    expect(MuseumHours.rows.map((r) => '${r.label}|${r.value}'), [
      'Senin – Jumat|08.00 – 16.00',
      'Sabtu – Minggu|Tutup',
    ]);
  });
}
