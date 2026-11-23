import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/koleksi_model.dart';
import 'koleksi_repository.dart';

/// Membaca data koleksi dari `assets/data/koleksi.json`.
///
/// Berkas yang sama dipakai pipeline ML (`ml/build_serupa.py`), jadi menambah
/// arca cukup mengedit satu file JSON (plus foto di `assets/images/` dan PDF di
/// `ml/data/pdf/`).
class JsonKoleksiRepository implements KoleksiRepository {
  JsonKoleksiRepository({AssetBundle? bundle, this.path = 'assets/data/koleksi.json'})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String path;

  List<Koleksi>? _cache;

  @override
  Future<List<Koleksi>> fetchAll() async {
    return _cache ??= parse(await _bundle.loadString(path));
  }

  /// Mengubah isi JSON menjadi daftar [Koleksi]. Dipisah supaya mudah diuji.
  static List<Koleksi> parse(String source) {
    final data = jsonDecode(source);
    if (data is! List) throw const FormatException('koleksi.json harus berupa daftar');
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) Koleksi.fromJson(item),
    ];
  }
}
