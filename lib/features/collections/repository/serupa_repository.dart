import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/koleksi_serupa.dart';

/// Sumber daftar "Koleksi Serupa" per arca.
abstract class SerupaRepository {
  /// Arca yang paling mirip dengan [koleksiId], urut dari yang paling mirip.
  /// Kosong kalau arca itu belum punya rekomendasi.
  Future<List<KoleksiSerupa>> ambil(String koleksiId);
}

/// Membaca hasil analisis teks dari `assets/data/koleksi_serupa.json`, yang
/// dibuat oleh `ml/build_serupa.py` (TF-IDF / embedding + kemiripan kosinus).
class AssetSerupaRepository implements SerupaRepository {
  AssetSerupaRepository({AssetBundle? bundle, this.path = 'assets/data/koleksi_serupa.json'})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String path;

  Map<String, List<KoleksiSerupa>>? _cache;

  @override
  Future<List<KoleksiSerupa>> ambil(String koleksiId) async {
    final peta = _cache ??= parse(await _bundle.loadString(path));
    return peta[koleksiId] ?? const [];
  }

  /// Mengubah isi JSON menjadi peta `id arca → rekomendasi`.
  static Map<String, List<KoleksiSerupa>> parse(String source) {
    final data = jsonDecode(source);
    final serupa = data is Map<String, dynamic> ? data['serupa'] : null;
    if (serupa is! Map<String, dynamic>) {
      throw const FormatException('koleksi_serupa.json tidak punya kunci "serupa"');
    }
    return {
      for (final e in serupa.entries)
        e.key: [
          if (e.value is List)
            for (final x in e.value as List)
              if (x is Map<String, dynamic>) KoleksiSerupa.fromJson(x),
        ],
    };
  }
}
