import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../storage/session_storage.dart';
import 'visitor_profile.dart';

/// Status login dan data pengunjung. Dibaca lewat `context.watch<AuthController>()`.
///
/// Sementara backend untuk aplikasi mobile belum ada, login hanya mengatur
/// status dan memakai [VisitorProfile.dummy]. Sesi disimpan lewat
/// [SessionStorage] sehingga tetap ada setelah aplikasi ditutup.
///
/// Router memantau controller ini: begitu [isLoggedIn] berubah, pengguna
/// otomatis diarahkan ke Beranda (login) atau Auth Gate (logout).
class AuthController extends ChangeNotifier {
  AuthController(this._storage);

  final SessionStorage _storage;

  bool _isLoggedIn = false;
  VisitorProfile? _profile;

  bool get isLoggedIn => _isLoggedIn;

  /// Profil pengunjung yang sedang masuk, `null` kalau belum login.
  VisitorProfile? get profile => _profile;

  /// Memulihkan sesi dari penyimpanan lokal. Dipanggil sekali di `main()`
  /// sebelum `runApp`, supaya tidak ada kedipan layar login.
  Future<void> restore() async {
    _isLoggedIn = _storage.isLoggedIn;
    _profile = _isLoggedIn ? _readStoredProfile() : null;
    notifyListeners();
  }

  /// Menandai pengguna sudah masuk.
  // TODO(backend): ganti dengan hasil verifikasi OTP dan profil dari API.
  Future<void> login() async {
    _isLoggedIn = true;
    _profile = _readStoredProfile() ?? VisitorProfile.dummy;
    await _storage.setLoggedIn(true);
    await _storage.saveProfileJson(jsonEncode(_profile!.toJson()));
    notifyListeners();
  }

  /// Keluar dan menghapus sesi lokal.
  Future<void> logout() async {
    _isLoggedIn = false;
    _profile = null;
    await _storage.clear();
    notifyListeners();
  }

  /// Menyimpan perubahan data diri (dipakai halaman Profil Saya).
  Future<void> updateProfile(VisitorProfile profile) async {
    _profile = profile;
    await _storage.saveProfileJson(jsonEncode(profile.toJson()));
    notifyListeners();
  }

  VisitorProfile? _readStoredProfile() {
    final raw = _storage.profileJson;
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return VisitorProfile.fromJson(decoded);
    } on FormatException {
      // Data rusak: abaikan dan pakai profil dummy.
    }
    return null;
  }
}
