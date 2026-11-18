import '../model/visit_record.dart';

/// Sumber data kunjungan pengunjung: status hari ini dan riwayatnya.
///
/// [VisitStatusViewModel] dan `ProfileViewModel` hanya bergantung pada
/// antarmuka ini, jadi implementasi dummy bisa diganti API tanpa mengubah
/// ViewModel maupun layar.
abstract class VisitRepository {
  /// Apakah kunjungan hari ini sudah tercatat.
  bool get recordedToday;

  /// Mencatat kunjungan hari ini.
  // TODO(backend): kirim hasil scan QR ke server.
  Future<void> recordToday();

  /// Mengembalikan status hari ini ke "belum tercatat".
  Future<void> resetToday();

  /// Riwayat kunjungan, yang terbaru di urutan pertama.
  Future<List<VisitRecord>> fetchHistory();
}

/// Status hanya disimpan di memori, jadi kembali "belum tercatat" saat
/// aplikasi dibuka ulang (sama seperti `visitConfirmedToday` di HTML).
/// Riwayat berisi data dummy dari desain.
// TODO(backend): sinkronkan dengan data kunjungan dari server.
class InMemoryVisitRepository implements VisitRepository {
  bool _recordedToday = false;

  @override
  bool get recordedToday => _recordedToday;

  @override
  Future<void> recordToday() async => _recordedToday = true;

  @override
  Future<void> resetToday() async => _recordedToday = false;

  @override
  Future<List<VisitRecord>> fetchHistory() async => const [
    VisitRecord(dateLabel: '22 Sep 2026'),
    VisitRecord(dateLabel: '03 Agu 2026'),
    VisitRecord(dateLabel: '17 Mei 2026'),
  ];
}
