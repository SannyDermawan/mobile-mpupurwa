/// Semua nama dan path rute aplikasi, termasuk milik Teman 1 dan Teman 2.
/// Pakai konstanta ini untuk berpindah halaman, jangan menulis path langsung:
///
/// ```dart
/// context.go(AppRoutes.booking);
/// context.go(AppRoutes.koleksiDetail('ganesya'));
/// context.go(AppRoutes.katalogDenganEra('Tumapel'));
/// ```
abstract final class AppRoutes {
  // --- Path ---
  static const String authgate = '/authgate';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';

  static const String beranda = '/beranda';
  static const String katalog = '/katalog'; // menerima query ?era=
  static const String koleksi = '/koleksi/:id';
  static const String info = '/info';
  static const String profil = '/profil';
  static const String scanQr = '/scan-qr';
  static const String kunjunganTercatat = '/kunjungan-tercatat';
  static const String booking = '/booking';
  static const String statusBooking = '/status-booking';

  // --- Nama (untuk `context.goNamed`) ---
  static const String authgateName = 'authgate';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String otpName = 'otp';
  static const String berandaName = 'beranda';
  static const String katalogName = 'katalog';
  static const String koleksiName = 'koleksi';
  static const String infoName = 'info';
  static const String profilName = 'profil';
  static const String scanQrName = 'scan-qr';
  static const String kunjunganTercatatName = 'kunjungan-tercatat';
  static const String bookingName = 'booking';
  static const String statusBookingName = 'status-booking';

  /// Rute yang boleh dibuka tanpa login.
  static const Set<String> authFlow = {authgate, login, register, otp};

  /// Path layar yang menyalakan tab di navbar (Beranda, Katalog, Booking, Info).
  static const Set<String> tabRoots = {beranda, katalog, booking, info};

  /// `/koleksi/<id>`, mis. `/koleksi/ganesya`.
  static String koleksiDetail(String id) => '/koleksi/${Uri.encodeComponent(id)}';

  /// `/katalog?era=<era>`, mis. `/katalog?era=Tumapel`. Nilai era yang dikenal
  /// di Katalog: Kanjuruhan, Tumapel, Singosari, Prasasti.
  static String katalogDenganEra(String era) =>
      Uri(path: katalog, queryParameters: {'era': era}).toString();
}
