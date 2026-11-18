import '../../../core/constants/museum_hours.dart';
import '../../../core/services/link_launcher.dart';
import '../model/museum_info.dart';

/// ViewModel layar Info: menyediakan data kunjungan dan membuka tautan
/// (peta, telepon, media sosial) lewat [LinkLauncher].
class InfoViewModel {
  const InfoViewModel(this._launcher, {this.info = MuseumInfo.data});

  final LinkLauncher _launcher;
  final MuseumInfo info;

  /// Baris kartu "Jam Operasional", dari satu-satunya sumber jam buka.
  List<HoursEntry> get hours => MuseumHours.rows;

  /// Semua aksi mengembalikan `false` kalau tautan tidak bisa dibuka.
  Future<bool> openMaps() => _launcher.open(info.mapsUrl);
  Future<bool> callMuseum() => _launcher.open(info.phoneUrl);
  Future<bool> openInstagram() => _launcher.open(info.instagramUrl);
  Future<bool> openYoutube() => _launcher.open(info.youtubeUrl);
}
