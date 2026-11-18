import 'dart:convert';

import '../../../core/storage/session_storage.dart';
import '../model/visitor_profile.dart';
import 'auth_repository.dart';

/// [AuthRepository] yang menyimpan sesi lewat [SessionStorage]
/// (`shared_preferences`), jadi pengguna tetap masuk setelah aplikasi ditutup.
///
/// Backend untuk aplikasi mobile belum ada, sehingga [signIn] memakai
/// [VisitorProfile.dummy] bila belum ada profil tersimpan.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._storage);

  final SessionStorage _storage;

  @override
  Future<AuthSession> restoreSession() async {
    if (!_storage.isLoggedIn) return const AuthSession.loggedOut();
    return AuthSession(isLoggedIn: true, profile: _readStoredProfile());
  }

  @override
  Future<VisitorProfile> signIn() async {
    final profile = _readStoredProfile() ?? VisitorProfile.dummy;
    await _storage.setLoggedIn(true);
    await _storage.saveProfileJson(jsonEncode(profile.toJson()));
    return profile;
  }

  @override
  Future<void> saveProfile(VisitorProfile profile) =>
      _storage.saveProfileJson(jsonEncode(profile.toJson()));

  @override
  Future<void> signOut() => _storage.clear();

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
