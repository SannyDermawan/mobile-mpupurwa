import '../../../core/network/api_client.dart';
import '../model/koleksi_model.dart';
import 'koleksi_repository.dart';

/// Mengambil koleksi dari Web Admin (`GET /api/public/collections`).
///
/// Data bawaan di `assets/data/koleksi.json` ([fallback]) dipakai untuk dua hal:
///
/// 1. **Cadangan penuh** bila server tidak terjangkau, supaya aplikasi tetap
///    bisa dipakai di dalam museum yang sinyalnya buruk.
/// 2. **Pelengkap per arca**: foto bawaan dipakai bila admin belum mengunggah
///    foto, dan id arca bawaan dipakai bila namanya sama. Id inilah kunci
///    rekomendasi "Koleksi serupa" (`koleksi_serupa.json`), sedangkan id di
///    database berupa angka otomatis yang berbeda tiap instalasi.
class ApiKoleksiRepository implements KoleksiRepository {
  ApiKoleksiRepository(this._client, {required this.fallback});

  final ApiClient _client;
  final KoleksiRepository fallback;

  List<Koleksi>? _cache;

  @override
  Future<List<Koleksi>> fetchAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final bundled = await fallback.fetchAll();
    try {
      final data = await _client.getJson('/api/public/collections');
      final fromServer = parse(data, bundled);
      // Server kosong sama saja dengan belum diisi: pakai data bawaan.
      return _cache = fromServer.isEmpty ? bundled : fromServer;
    } on ApiException {
      return bundled; // tidak di-cache: coba lagi saat dibuka berikutnya
    }
  }

  /// Mengubah balasan API menjadi [Koleksi], dilengkapi data bawaan.
  /// Dipisah supaya mudah diuji.
  static List<Koleksi> parse(Object? data, List<Koleksi> bundled) {
    if (data is! List) throw const ApiException('Daftar koleksi dari server tidak valid.');
    final byName = {for (final k in bundled) _key(k.nama): k};

    String text(Object? v) => v is String ? v.trim() : '';
    String? textOrNull(Object? v) => text(v).isEmpty ? null : text(v);

    final hasil = <Koleksi>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final nama = text(raw['name']);
      final local = byName[_key(nama)];
      final foto = text(raw['photoUrl']);
      hasil.add(
        Koleksi(
          id: local?.id ?? '${raw['id']}',
          nama: nama,
          era: text(raw['era']),
          asal: text(raw['origin']),
          periode: text(raw['period']),
          material: text(raw['material']),
          sejarah: text(raw['meaning']),
          fotoUrl: foto.isNotEmpty ? foto : (local?.fotoUrl ?? ''),
          videoUrl: textOrNull(raw['videoUrl']),
          pdfUrl: textOrNull(raw['pdfUrl']),
        ),
      );
    }
    return hasil;
  }

  static String _key(String nama) => nama.trim().toLowerCase();
}
