import '../model/koleksi_model.dart';

/// Sumber data koleksi museum. ViewModel hanya bergantung pada antarmuka ini,
/// jadi data dummy bisa diganti API tanpa mengubah ViewModel atau layar.
abstract class KoleksiRepository {
  /// Seluruh koleksi yang tampil di Katalog.
  Future<List<Koleksi>> fetchAll();
}
