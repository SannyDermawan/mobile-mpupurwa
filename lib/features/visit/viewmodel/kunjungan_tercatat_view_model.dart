import '../../../core/utils/tanggal_format.dart';
import '../../auth/viewmodel/auth_view_model.dart';

/// ViewModel layar Kunjungan Tercatat: menyiapkan tanggal dan nama pengunjung
/// yang ditampilkan di kartu "Detail Kunjungan".
class KunjunganTercatatViewModel {
  const KunjunganTercatatViewModel(this._auth, {this.visitDate});

  final AuthViewModel _auth;

  /// Tanggal kunjungan. Kosong berarti hari ini.
  final DateTime? visitDate;

  /// Tanggal lengkap, mis. `Rabu, 14 Oktober 2026`.
  String dateText([DateTime? now]) => formatTanggalLengkap(visitDate ?? now ?? DateTime.now());

  /// Nama pengunjung, `null` kalau belum ada sesi.
  String? get visitorName => _auth.profile?.name;

  String get status => 'Tercatat';
}
