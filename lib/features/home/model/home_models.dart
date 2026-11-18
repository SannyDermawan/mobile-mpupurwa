/// Model kecil khusus Beranda. Bukan model koleksi lengkap (itu milik Teman 1);
/// satu-satunya kontrak dengan layar koleksi adalah [FeaturedCollection.id],
/// yang dipakai untuk membuka rute `koleksi/:id`.
class FeaturedCollection {
  const FeaturedCollection({
    required this.id,
    required this.eraLabel,
    required this.title,
    required this.subtitle,
    this.imageAsset,
    this.imageFocusY = 0.5,
  });

  /// Id koleksi (`ganesya`, `brahma`, `catur`), sama dengan kunci di HTML.
  final String id;

  /// Badge era di atas judul, mis. "Singosari".
  final String eraLabel;
  final String title;
  final String subtitle;

  /// Foto kartu. `null` berarti kartu memakai ikon di atas latar gelap.
  final String? imageAsset;

  /// Posisi vertikal foto saat dipotong (`background-position: center N%`),
  /// dalam rentang 0..1.
  final double imageFocusY;
}

/// Satu era di linimasa Beranda.
class EraInfo {
  const EraInfo({
    required this.key,
    required this.name,
    required this.period,
    required this.title,
    required this.description,
    required this.backgroundAsset,
    this.katalogFilter,
  });

  /// Kunci era (`kanjuruhan`, `tumapel`, ...).
  final String key;

  /// Nama di node linimasa, mis. "Kanjuruhan".
  final String name;

  /// Keterangan tahun di bawah nama, mis. "Abad 8–9".
  final String period;

  /// Judul kartu detail, mis. "Awal Peradaban Malang Raya".
  final String title;
  final String description;
  final String backgroundAsset;

  /// Nilai query `?era=` untuk membuka Katalog. `null` berarti era ini
  /// tidak punya filter, sehingga tombol "Lihat Koleksi Era Ini" disembunyikan.
  final String? katalogFilter;

  /// Label kecil di kartu detail, mis. "Kanjuruhan · Abad 8–9".
  String get label => '$name · $period';
}

/// Seluruh isi dinamis Beranda.
class HomeContent {
  const HomeContent({required this.featured, required this.eras});

  final List<FeaturedCollection> featured;
  final List<EraInfo> eras;
}
