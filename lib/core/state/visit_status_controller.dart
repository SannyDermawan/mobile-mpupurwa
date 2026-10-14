import 'package:flutter/foundation.dart';

/// Status pencatatan kunjungan hari ini.
///
/// Beranda (Leader) membaca [visitRecordedToday] untuk memilih banner:
/// "Sedang di museum?" (belum tercatat) atau "Kunjungan hari ini tercatat."
///
/// Layar Scan QR (Teman 2) memanggil [markVisitRecorded] begitu kunjungan
/// berhasil dicatat, misalnya sebelum pindah ke halaman Kunjungan Tercatat:
///
/// ```dart
/// context.read<VisitStatusController>().markVisitRecorded();
/// ```
///
/// Status hanya disimpan di memori, jadi kembali "belum tercatat" saat
/// aplikasi dibuka ulang (sama seperti `visitConfirmedToday` di HTML).
// TODO(backend): sinkronkan dengan data kunjungan dari server.
class VisitStatusController extends ChangeNotifier {
  bool _visitRecordedToday = false;

  bool get visitRecordedToday => _visitRecordedToday;

  void markVisitRecorded() {
    if (_visitRecordedToday) return;
    _visitRecordedToday = true;
    notifyListeners();
  }

  /// Mengembalikan ke "belum tercatat" (mis. saat pergantian akun).
  void reset() {
    if (!_visitRecordedToday) return;
    _visitRecordedToday = false;
    notifyListeners();
  }
}
