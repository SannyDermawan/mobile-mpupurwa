import '../../../core/network/api_client.dart';
import '../../auth/model/visitor_profile.dart';
import '../model/visit_record.dart';
import 'visit_repository.dart';

/// Mencatat check-in ke Web Admin (`POST /api/public/visits`) supaya muncul di
/// "Pengunjung hari ini" pada dashboard admin.
///
/// Status "tercatat hari ini" dan riwayat tetap diurus [local]. Pengiriman ke
/// server bersifat usaha terbaik: kalau gagal (mis. tanpa sinyal di dalam
/// museum), pengunjung tetap melihat kunjungannya tercatat, dan kegagalan itu
/// belum diulang otomatis (lihat catatan serah terima).
class ApiVisitRepository implements VisitRepository {
  ApiVisitRepository(this._client, {required this.profile, VisitRepository? local})
    : _local = local ?? InMemoryVisitRepository();

  final ApiClient _client;
  final VisitorProfile? Function() profile;
  final VisitRepository _local;

  static const _levels = {'Mahasiswa', 'Pelajar', 'Umum'};

  @override
  bool get recordedToday => _local.recordedToday;

  @override
  Future<void> recordToday() async {
    await _local.recordToday();
    final p = profile();
    if (p == null) return; // belum login: tidak ada identitas untuk dikirim
    try {
      await _client.postJson('/api/public/visits', {
        'name': p.name,
        'domicile': p.domicile,
        'institution': p.institution,
        'educationLevel': _levels.contains(p.educationLevel) ? p.educationLevel : 'Umum',
      });
    } on ApiException {
      // Usaha terbaik, lihat dokumentasi kelas.
    }
  }

  @override
  Future<void> resetToday() => _local.resetToday();

  @override
  Future<List<VisitRecord>> fetchHistory() => _local.fetchHistory();
}
