import '../../../core/services/link_launcher.dart';
import '../model/koleksi_model.dart';

/// ViewModel halaman Detail Koleksi: menyiapkan teks tampilan (termasuk nilai
/// cadangan kalau data kosong) dan membuka tautan video / PDF.
class KoleksiDetailViewModel {
  const KoleksiDetailViewModel(this.koleksi, this._launcher);

  final Koleksi koleksi;
  final LinkLauncher _launcher;

  bool get hasImage => koleksi.fotoUrl.isNotEmpty;
  bool get hasVideo => (koleksi.videoUrl ?? '').isNotEmpty;
  bool get hasPdf => (koleksi.pdfUrl ?? '').isNotEmpty;
  bool get hasActions => hasVideo || hasPdf;

  String get era => koleksi.era.toUpperCase();

  /// Kalimat pengantar di bawah judul, disusun dari data arca itu sendiri.
  String get ringkasan {
    final bagian = <String>[
      'Koleksi Museum Mpu Purwa',
      if (koleksi.era.isNotEmpty) 'masa ${_judul(koleksi.era)}',
      if (koleksi.periode.isNotEmpty) koleksi.periode,
    ];
    return '${bagian.join(' · ')}.';
  }

  String get asal => _orDefault(koleksi.asal, 'Malang Raya');
  String get periode => _orDefault(koleksi.periode, 'Abad 13');
  String get kerajaan => _orDefault(koleksi.era, 'Singosari');
  String get material => _orDefault(koleksi.material, 'Batu Andesit');

  String get sejarah => _orDefault(
    koleksi.sejarah,
    'Ganesya digambarkan duduk di atas tikus, wahana yang melambangkan kemampuan '
    'menembus rintangan sekecil apa pun. Arca ini dipuja sebagai penghalau rintangan '
    'dan pelindung ilmu pengetahuan pada masa Kerajaan Singosari.',
  );

  /// Membuka video koleksi. `true` kalau berhasil dibuka.
  Future<bool> openVideo() => _launcher.open(koleksi.videoUrl!);

  /// Membuka dokumen PDF koleksi. `true` kalau berhasil dibuka.
  Future<bool> openPdf() => _launcher.open(koleksi.pdfUrl!);

  static String _judul(String teks) =>
      teks.isEmpty ? teks : teks[0].toUpperCase() + teks.substring(1).toLowerCase();

  static String _orDefault(String value, String fallback) => value.isNotEmpty ? value : fallback;
}
