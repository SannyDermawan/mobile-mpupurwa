import '../../../core/constants/app_images.dart';
import 'home_models.dart';

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
      description: 'Kerajaan besar pewaris Tumapel yang meninggalkan banyak arca dan candi megah, termasuk koleksi langka seperti Ganesya Tikus.',
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
