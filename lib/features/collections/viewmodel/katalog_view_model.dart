import 'package:flutter/foundation.dart';

import '../model/koleksi_model.dart';
import '../repository/koleksi_repository.dart';

/// ViewModel Katalog Koleksi: memuat daftar koleksi, menyimpan kata kunci
/// pencarian dan era terpilih, lalu menghitung daftar yang tampil.
class KatalogViewModel extends ChangeNotifier {
  /// [initialEra] berasal dari query `?era=` (mis. dari linimasa Beranda).
  /// Nilai yang tidak dikenal diabaikan, sehingga filter tetap "Semua".
  KatalogViewModel(this._repository, {String? initialEra}) {
    final match = eraOptions.where((e) => e.toLowerCase() == initialEra?.toLowerCase());
    if (match.isNotEmpty) _selectedEra = match.first;
  }

  /// Pilihan chip era. "Semua" berarti tanpa filter era.
  static const String semua = 'Semua';
  static const List<String> eraOptions = [semua, 'Kanjuruhan', 'Tumapel', 'Singosari', 'Prasasti'];

  final KoleksiRepository _repository;

  List<Koleksi> _all = const [];
  String _query = '';
  String _selectedEra = semua;
  bool _isLoading = false;
  bool _hasError = false;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get selectedEra => _selectedEra;

  /// Koleksi yang lolos pencarian nama dan filter era.
  List<Koleksi> get filtered {
    final query = _query.toLowerCase();
    return _all.where((item) {
      final matchesSearch = item.nama.toLowerCase().contains(query);
      final matchesEra = _selectedEra == semua || item.era.toUpperCase() == _selectedEra.toUpperCase();
      return matchesSearch && matchesEra;
    }).toList();
  }

  /// Memuat daftar koleksi dari repository.
  Future<void> load() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      _all = await _repository.fetchAll();
    } on Object {
      _all = const [];
      _hasError = true;
    }
    if (_disposed) return;
    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _query = query;
    notifyListeners();
  }

  void selectEra(String era) {
    _selectedEra = era;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
