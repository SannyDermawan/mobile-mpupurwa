import 'package:flutter/foundation.dart';

import '../model/visitor_profile.dart';
import '../repository/auth_repository.dart';

/// ViewModel sesi login dan data pengunjung. Dipakai bersama oleh banyak layar,
/// jadi dibaca lewat `context.watch<AuthViewModel>()`.
///
/// Alurnya satu arah: View memanggil [login] / [logout] / [updateProfile],
/// ViewModel meneruskan ke [AuthRepository], lalu `notifyListeners()` membuat
/// View dan router menyesuaikan diri.
///
/// Router memantau ViewModel ini: begitu [isLoggedIn] berubah, pengguna
/// otomatis diarahkan ke Beranda (login) atau Auth Gate (logout).
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository);

  final AuthRepository _repository;

  bool _isLoggedIn = false;
  VisitorProfile? _profile;

  bool get isLoggedIn => _isLoggedIn;

  /// Profil pengunjung yang sedang masuk, `null` kalau belum login.
  VisitorProfile? get profile => _profile;

  /// Memulihkan sesi dari penyimpanan lokal. Dipanggil sekali di `main()`
  /// sebelum `runApp`, supaya tidak ada kedipan layar login.
  Future<void> restore() async {
    final session = await _repository.restoreSession();
    _isLoggedIn = session.isLoggedIn;
    _profile = session.isLoggedIn ? session.profile : null;
    notifyListeners();
  }

  /// Menandai pengguna sudah masuk.
  Future<void> login() async {
    _profile = await _repository.signIn();
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Keluar dan menghapus sesi lokal.
  Future<void> logout() async {
    _isLoggedIn = false;
    _profile = null;
    await _repository.signOut();
    notifyListeners();
  }

  /// Menyimpan perubahan data diri (dipakai halaman Profil Saya).
  Future<void> updateProfile(VisitorProfile profile) async {
    _profile = profile;
    await _repository.saveProfile(profile);
    notifyListeners();
  }
}
