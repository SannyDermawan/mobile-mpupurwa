/// Ukuran tetap yang berulang di HTML.
abstract final class AppDimens {
  /// Jarak kiri-kanan halaman (`padding: 0 22px`).
  static const double gutter = 22;

  /// Lebar maksimum "frame" ponsel di HTML (`.phone`, 390px) tanpa border.
  /// Dipakai sebagai acuan desain, bukan batasan: layout tetap fleksibel
  /// untuk lebar 360 sampai 430 dp.
  static const double designWidth = 370;

  static const double radiusSm = 11; // input
  static const double radiusMd = 12; // tombol
  static const double radiusButtonAuth = 13;
  static const double radiusCard = 16;
  static const double radiusPill = 30;
}
