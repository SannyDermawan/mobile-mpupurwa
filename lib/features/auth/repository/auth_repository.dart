import '../model/visitor_profile.dart';

/// Sesi login yang dipulihkan dari penyimpanan.
class AuthSession {
  const AuthSession({required this.isLoggedIn, this.profile});

  const AuthSession.loggedOut() : isLoggedIn = false, profile = null;

  final bool isLoggedIn;

  /// Profil tersimpan; `null` kalau belum login atau datanya rusak.
  final VisitorProfile? profile;
}

/// Sumber data sesi dan profil pengunjung.
///
/// [AuthViewModel] hanya mengenal antarmuka ini. Implementasi sekarang
/// ([LocalAuthRepository]) memakai penyimpanan lokal; nanti bisa diganti
/// implementasi yang memanggil API tanpa mengubah ViewModel maupun layar.
abstract class AuthRepository {
  /// Membaca sesi yang tersimpan dari pemakaian sebelumnya.
  Future<AuthSession> restoreSession();

  /// Menandai pengguna masuk dan mengembalikan profilnya.
  // TODO(backend): ganti dengan verifikasi OTP dan profil dari API.
  Future<VisitorProfile> signIn();

  /// Menyimpan perubahan data diri.
  Future<void> saveProfile(VisitorProfile profile);

  /// Menghapus sesi lokal.
  Future<void> signOut();
}
