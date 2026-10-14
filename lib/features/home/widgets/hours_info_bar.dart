import 'package:flutter/material.dart';

import '../../../core/constants/museum_hours.dart';
import '../../../core/widgets/app_card.dart';

/// Kotak info jam buka di bawah Beranda. Seluruh jam dan nama hari diambil
/// dari [MuseumHours], tidak ada jam yang ditulis langsung di sini.
class HoursInfoBar extends StatelessWidget {
  const HoursInfoBar({super.key, required this.now});

  /// Waktu sekarang; dipisah supaya bisa diuji untuk hari buka dan hari tutup.
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    const reminder = ' Jam dapat berubah sewaktu-waktu, cek info kunjungan sebelum datang.';
    final open = MuseumHours.isOpenToday(now);

    return InfoBar(
      icon: Icons.info_outline,
      message: TextSpan(
        children: open
            ? [
                TextSpan(text: 'Buka hari ini', style: InfoBar.boldStyle),
                TextSpan(text: ' pukul ${MuseumHours.rangeTextCompact}.$reminder'),
              ]
            : [
                TextSpan(text: 'Tutup hari ini.', style: InfoBar.boldStyle),
                TextSpan(
                  text:
                      ' Museum buka ${MuseumHours.openDaysTextCompact} pukul ${MuseumHours.rangeTextCompact}.$reminder',
                ),
              ],
      ),
    );
  }
}
