import 'package:flutter/foundation.dart';

import '../repository/visit_repository.dart';

/// ViewModel status pencatatan kunjungan hari ini.
///
/// Beranda membaca [visitRecordedToday] untuk memilih banner:
/// "Sedang di museum?" (belum tercatat) atau "Kunjungan hari ini tercatat."
///
/// Layar Scan QR memanggil [markVisitRecorded] begitu kunjungan berhasil
/// dicatat, misalnya sebelum pindah ke halaman Kunjungan Tercatat:
///
/// ```dart
/// context.read<VisitStatusViewModel>().markVisitRecorded();
/// ```
class VisitStatusViewModel extends ChangeNotifier {
  VisitStatusViewModel({VisitRepository? repository})
    : _repository = repository ?? InMemoryVisitRepository() {
    _visitRecordedToday = _repository.recordedToday;
  }

  final VisitRepository _repository;

  bool _visitRecordedToday = false;

  bool get visitRecordedToday => _visitRecordedToday;

  void markVisitRecorded() {
    if (_visitRecordedToday) return;
    _visitRecordedToday = true;
    notifyListeners();
    _repository.recordToday();
  }

  /// Mengembalikan ke "belum tercatat" (mis. saat pergantian akun).
  void reset() {
    if (!_visitRecordedToday) return;
    _visitRecordedToday = false;
    notifyListeners();
    _repository.resetToday();
  }
}
