/// Konfigurasi API. Belum dipakai oleh layar mana pun: backend yang ada baru
/// punya endpoint untuk admin web, belum untuk aplikasi mobile.
abstract final class ApiConfig {
  /// `10.0.2.2` adalah alamat komputer host dari dalam emulator Android.
  /// Ganti ke alamat server sebenarnya (atau `--dart-define=API_BASE_URL=...`).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
