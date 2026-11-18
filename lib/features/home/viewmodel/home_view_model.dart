import 'package:flutter/foundation.dart';

import '../model/home_models.dart';
import '../repository/home_repository.dart';

/// ViewModel Beranda: memuat isi dinamis lewat [HomeRepository] dan
/// menyimpan state layar (memuat, gagal, atau berhasil).
///
/// View cukup membaca [content], [isLoading], dan [hasError], lalu memanggil
/// [load] untuk memuat ulang.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._repository);

  final HomeRepository _repository;

  HomeContent? _content;
  bool _isLoading = false;
  bool _hasError = false;
  bool _disposed = false;

  /// Isi Beranda; `null` selama belum berhasil dimuat.
  HomeContent? get content => _content;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  /// Memuat (atau memuat ulang) isi Beranda dari repository.
  Future<void> load() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      _content = await _repository.loadContent();
    } on Object {
      _content = null;
      _hasError = true;
    }
    if (_disposed) return;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
