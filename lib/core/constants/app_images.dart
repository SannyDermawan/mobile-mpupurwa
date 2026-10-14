/// Path aset gambar. Semua gambar diekstrak dari `Museum_Mpu_Purwa_App.html`
/// (di HTML gambarnya ditanam sebagai base64) dan disimpan di `assets/images/`.
abstract final class AppImages {
  static const String ganesyaTikus = 'assets/images/ganesya_tikus.jpg';
  static const String brahma = 'assets/images/brahma.jpg';
  static const String prasastiKanjuruhan = 'assets/images/prasasti_kanjuruhan.jpg';

  /// Foto papan "Linimasa Sejarah Nusantara", latar kartu era di Beranda.
  static const String timelineBg = 'assets/images/timeline_bg.jpg';

  /// Latar Auth Gate. Di HTML memakai foto yang sama dengan [brahma].
  static const String authGateBg = brahma;
}
