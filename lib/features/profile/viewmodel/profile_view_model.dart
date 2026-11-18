import 'package:flutter/foundation.dart';

import '../../auth/model/visitor_profile.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import '../../visit/model/visit_record.dart';
import '../../visit/repository/visit_repository.dart';
import '../../visit/viewmodel/visit_status_view_model.dart';

/// ViewModel layar Profil Saya: menyiapkan data diri dari [AuthViewModel],
/// riwayat kunjungan dari [VisitRepository], dan aksi keluar akun.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._auth, this._visits, this._visitStatus) {
    _auth.addListener(notifyListeners);
  }

  final AuthViewModel _auth;
  final VisitRepository _visits;
  final VisitStatusViewModel _visitStatus;

  List<VisitRecord> _history = const [];
  bool _disposed = false;

  /// Profil yang sedang masuk. Cadangan dummy hanya dipakai kalau layar
  /// terbuka tanpa sesi.
  VisitorProfile get profile => _auth.profile ?? VisitorProfile.dummy;

  /// Baris di bawah nama, mis. `Mahasiswa · Surabaya`.
  String get subtitle => '${profile.educationLevel} · ${profile.domicile}';

  List<VisitRecord> get history => _history;

  /// Memuat riwayat kunjungan.
  Future<void> load() async {
    _history = await _visits.fetchHistory();
    if (!_disposed) notifyListeners();
  }

  /// Keluar akun. Router otomatis mengarahkan ke Auth Gate begitu status login berubah.
  Future<void> logout() async {
    _visitStatus.reset();
    await _auth.logout();
  }

  @override
  void dispose() {
    _disposed = true;
    _auth.removeListener(notifyListeners);
    super.dispose();
  }
}
