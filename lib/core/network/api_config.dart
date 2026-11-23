/// Konfigurasi API Web Admin untuk aplikasi pengunjung.
///
/// Diisi saat menjalankan aplikasi:
///
/// ```text
/// flutter run --dart-define=API_BASE_URL=http://localhost:5000      # web / desktop
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000       # emulator Android
/// flutter run --dart-define=API_BASE_URL=https://<domain-backend>   # produksi
/// ```
///
/// Kosong (bawaan) berarti aplikasi memakai data bawaan di `assets/data/` dan
/// tidak menghubungi server sama sekali. Endpoint yang dipakai: `/api/public/...`.
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL');

  /// `true` bila `API_BASE_URL` diisi.
  static bool get enabled => baseUrl.isNotEmpty;

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
