import 'package:flutter/foundation.dart';

import '../model/koleksi_model.dart';
import '../model/koleksi_serupa.dart';
import '../repository/koleksi_repository.dart';
import '../repository/serupa_repository.dart';

/// ViewModel bagian "Koleksi serupa" di halaman Detail Koleksi.
///
/// Menggabungkan dua sumber: daftar id + skor kemiripan dari
/// [SerupaRepository] (hasil model ML) dan data lengkap arca dari
/// [KoleksiRepository]. Kalau salah satunya gagal, bagian ini cukup kosong dan
/// layar Detail tetap berfungsi.
class KoleksiSerupaViewModel extends ChangeNotifier {
  KoleksiSerupaViewModel(this._koleksi, this._serupa, {required this.koleksiId});

  final KoleksiRepository _koleksi;
  final SerupaRepository _serupa;
  final String koleksiId;

  List<KoleksiTerkait> _items = const [];
  bool _isLoading = false;
  bool _disposed = false;

  List<KoleksiTerkait> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final rekomendasi = await _serupa.ambil(koleksiId);
      final semua = await _koleksi.fetchAll();
      final peta = <String, Koleksi>{for (final k in semua) k.id: k};
      _items = [
        for (final r in rekomendasi)
          if (peta[r.id] != null && r.id != koleksiId)
            KoleksiTerkait(koleksi: peta[r.id]!, skor: r.skor),
      ];
    } on Object {
      _items = const [];
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
