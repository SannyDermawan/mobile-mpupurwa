import 'package:url_launcher/url_launcher.dart';

/// Service pembuka tautan eksternal (web, telepon, peta).
///
/// ViewModel bergantung pada antarmuka ini, bukan pada plugin `url_launcher`,
/// sehingga di test cukup diganti dengan implementasi palsu.
abstract class LinkLauncher {
  /// Membuka [url] di aplikasi lain. `true` kalau berhasil dibuka.
  Future<bool> open(String url);
}

/// Implementasi nyata memakai paket `url_launcher`.
class UrlLauncherService implements LinkLauncher {
  const UrlLauncherService();

  @override
  Future<bool> open(String url) async {
    try {
      return await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } on Exception {
      return false;
    }
  }
}
