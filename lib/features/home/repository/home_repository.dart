import '../../../core/constants/app_images.dart';
import '../../collections/model/koleksi_model.dart';
import '../../collections/repository/koleksi_repository.dart';
import '../model/home_models.dart';

/// Sumber data Beranda. UI hanya bergantung pada antarmuka ini, jadi
/// [DummyHomeRepository] bisa diganti implementasi API tanpa mengubah layar.
abstract class HomeRepository {
  Future<HomeContent> loadContent();
}

/// Data statis yang disalin dari HTML (`selectEra` / `eraData` dan kartu
/// "Koleksi Unggulan").
// TODO(backend): ganti dengan implementasi yang memakai ApiClient.
class DummyHomeRepository implements HomeRepository {
  const DummyHomeRepository();

  static const _featured = [
    FeaturedCollection(
      id: 'ganesya',
      eraLabel: 'Singosari',
      title: 'Arca Ganesya Tikus',
      subtitle: 'Satu-satunya di Indonesia',
      imageAsset: AppImages.ganesyaTikus,
      imageFocusY: 0.25,
    ),
    FeaturedCollection(
      id: 'brahma',
      eraLabel: 'Kanjuruhan',
      title: 'Arca Brahma',
      subtitle: 'Simbol penciptaan',
      imageAsset: AppImages.brahma,
      imageFocusY: 0.20,
    ),
    FeaturedCollection(
      id: 'catur',
      eraLabel: 'Tumapel',
      title: 'Siwa Catur Muka',
      subtitle: 'Empat wajah, empat arah',
    ),
  ];

  static const _eras = [
    EraInfo(
      key: 'kanjuruhan',
      name: 'Kanjuruhan',
      period: 'Abad 8–9',
      title: 'Awal Peradaban Malang Raya',
      description: 'Kerajaan Hindu tertua yang tercatat di wilayah Malang, dikenal lewat Prasasti Dinoyo — cikal bakal peradaban yang kelak melahirkan Tumapel dan Singosari.',
      backgroundAsset: AppImages.timelineBg,
      katalogFilter: 'Kanjuruhan',
    ),
    EraInfo(
      key: 'tumapel',
      name: 'Tumapel',
      period: 'Abad 12–13',
      title: 'Cikal Bakal Singosari',
      description: 'Kadipaten yang menjadi awal kekuasaan Ken Arok, sebelum berkembang dan berganti nama menjadi Kerajaan Singosari yang lebih besar.',
      backgroundAsset: AppImages.timelineBg,
      katalogFilter: 'Tumapel',
    ),
    EraInfo(
      key: 'singosari',
      name: 'Singosari',
      period: 'Abad 13',
      title: 'Puncak Seni Arca Malang',
      description: 'Kerajaan besar pewaris Tumapel yang meninggalkan banyak arca dan candi megah, termasuk Ganesha, Brahma, dan Bodhisatwa Avalokitecvara.',
      backgroundAsset: AppImages.timelineBg,
      katalogFilter: 'Singosari',
    ),
    EraInfo(
      key: 'majapahit',
      name: 'Majapahit',
      period: 'Abad 14–15',
      title: 'Kerajaan Nusantara Terbesar',
      description: 'Kerajaan Hindu-Buddha terbesar di Nusantara yang menyatukan wilayah Malang sebagai bagian dari kekuasaannya di bawah Gajah Mada.',
      backgroundAsset: AppImages.timelineBg,
    ),
  ];

  @override
  Future<HomeContent> loadContent() async => const HomeContent(featured: _featured, eras: _eras);
}

/// Beranda yang isi "Koleksi Unggulan" dan jumlah koleksinya diambil dari data
/// koleksi sungguhan ([KoleksiRepository]), jadi selalu cocok dengan Katalog.
/// Linimasa era tetap dari [base].
class KoleksiHomeRepository implements HomeRepository {
  const KoleksiHomeRepository(
    this._koleksi, {
    this.base = const DummyHomeRepository(),
    this.jumlahUnggulan = 3,
  });

  final KoleksiRepository _koleksi;
  final HomeRepository base;
  final int jumlahUnggulan;

  @override
  Future<HomeContent> loadContent() async {
    final dasar = await base.loadContent();
    final semua = await _koleksi.fetchAll();
    return HomeContent(
      featured: pilihUnggulan(semua, jumlahUnggulan),
      eras: dasar.eras,
      totalKoleksi: semua.length,
    );
  }

  /// Memilih koleksi unggulan: yang punya foto lebih dulu, dengan era yang
  /// berbeda-beda supaya Beranda tidak terlihat seragam.
  static List<FeaturedCollection> pilihUnggulan(List<Koleksi> semua, int jumlah) {
    final berfoto = semua.where((k) => k.fotoUrl.isNotEmpty).toList();
    final pilihan = <Koleksi>[];
    final eraTerpakai = <String>{};
    for (final k in berfoto) {
      if (pilihan.length == jumlah) break;
      if (eraTerpakai.add(k.era.toLowerCase())) pilihan.add(k);
    }
    for (final k in berfoto) {
      if (pilihan.length == jumlah) break;
      if (!pilihan.contains(k)) pilihan.add(k);
    }
    return [
      for (final k in pilihan)
        FeaturedCollection(
          id: k.id,
          eraLabel: k.era.isEmpty ? '' : k.era[0].toUpperCase() + k.era.substring(1).toLowerCase(),
          title: k.nama,
          subtitle: k.periode.isNotEmpty ? k.periode : k.material,
          imageAsset: k.fotoUrl,
          imageFocusY: 0.3,
        ),
    ];
  }
}
