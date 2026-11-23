import 'koleksi_model.dart';

/// Satu rekomendasi hasil analisis teks: arca [id] mirip dengan [skor]
/// (0 sampai 1, kemiripan kosinus) terhadap arca yang sedang dilihat.
class KoleksiSerupa {
  const KoleksiSerupa({required this.id, required this.skor});

  final String id;
  final double skor;

  factory KoleksiSerupa.fromJson(Map<String, dynamic> json) {
    final skor = json['skor'];
    return KoleksiSerupa(id: '${json['id']}', skor: skor is num ? skor.toDouble() : 0);
  }
}

/// Koleksi lengkap beserta skor kemiripannya, siap ditampilkan.
class KoleksiTerkait {
  const KoleksiTerkait({required this.koleksi, required this.skor});

  final Koleksi koleksi;
  final double skor;

  /// Teks untuk badge, mis. `42% mirip`.
  String get label => '${(skor * 100).round()}% mirip';
}
