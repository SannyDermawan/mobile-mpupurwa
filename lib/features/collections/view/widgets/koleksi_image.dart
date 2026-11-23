import 'package:flutter/material.dart';

/// Foto koleksi. Alamat yang diawali `assets/` dibaca dari aset aplikasi,
/// selain itu dianggap tautan internet. Kalau kosong atau gagal dimuat,
/// ditampilkan [fallback].
class KoleksiImage extends StatelessWidget {
  const KoleksiImage({
    super.key,
    required this.url,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  final String url;
  final Widget fallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return fallback;
    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: fit, errorBuilder: (_, __, ___) => fallback);
    }
    return Image.network(url, fit: fit, errorBuilder: (_, __, ___) => fallback);
  }
}
