import 'package:flutter/material.dart';

/// Foto koleksi. Alamat yang diawali `assets/` dibaca dari aset aplikasi,
/// selain itu dianggap tautan internet (mis. Vercel Blob dari Web Admin).
/// Kalau kosong atau gagal dimuat, ditampilkan [fallback].
class KoleksiImage extends StatelessWidget {
  const KoleksiImage({
    super.key,
    required this.url,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.cacheWidth,
    this.semanticLabel,
  });

  final String url;
  final Widget fallback;
  final BoxFit fit;
  final Alignment alignment;

  /// Lebar decode gambar (piksel), untuk menghemat memori pada kartu kecil.
  final int? cacheWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return fallback;
    Widget error(BuildContext _, Object __, StackTrace? ___) => fallback;
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: fit,
        alignment: alignment,
        cacheWidth: cacheWidth,
        semanticLabel: semanticLabel,
        errorBuilder: error,
      );
    }
    return Image.network(
      url,
      fit: fit,
      alignment: alignment,
      cacheWidth: cacheWidth,
      semanticLabel: semanticLabel,
      errorBuilder: error,
    );
  }
}
