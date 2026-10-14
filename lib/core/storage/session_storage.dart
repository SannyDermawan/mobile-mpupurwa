import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan lokal untuk sesi login (via `shared_preferences`), supaya
/// pengguna tetap masuk setelah aplikasi ditutup.
class SessionStorage {
  SessionStorage(this._prefs);

  static const _keyLoggedIn = 'session.logged_in';
  static const _keyProfile = 'session.profile_json';

  final SharedPreferences _prefs;

  static Future<SessionStorage> create() async =>
      SessionStorage(await SharedPreferences.getInstance());

  bool get isLoggedIn => _prefs.getBool(_keyLoggedIn) ?? false;

  Future<void> setLoggedIn(bool value) => _prefs.setBool(_keyLoggedIn, value);

  /// Profil terakhir yang disimpan dalam bentuk JSON, atau `null`.
  String? get profileJson => _prefs.getString(_keyProfile);

  Future<void> saveProfileJson(String json) => _prefs.setString(_keyProfile, json);

  /// Menghapus semua data sesi (dipanggil saat logout).
  Future<void> clear() async {
    await _prefs.remove(_keyLoggedIn);
    await _prefs.remove(_keyProfile);
  }
}
