import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../model/koleksi_model.dart';
import '../repository/koleksi_repository.dart';
import 'katalog_page.dart';
import 'koleksi_detail_page.dart';

/// Membuka Detail Koleksi hanya dari id di alamat rute (`/koleksi/<id>`),
/// mis. dari kartu "Koleksi Unggulan" di Beranda yang tidak membawa objek
/// koleksinya. Id tidak ditemukan: kembali ke Katalog.
class KoleksiDetailLoader extends StatefulWidget {
  const KoleksiDetailLoader({super.key, required this.id});

  final String id;

  @override
  State<KoleksiDetailLoader> createState() => _KoleksiDetailLoaderState();
}

class _KoleksiDetailLoaderState extends State<KoleksiDetailLoader> {
  late final Future<Koleksi?> _future = _cari();

  Future<Koleksi?> _cari() async {
    try {
      final semua = await context.read<KoleksiRepository>().fetchAll();
      for (final k in semua) {
        if (k.id == widget.id) return k;
      }
    } on Object {
      // Gagal memuat sama saja dengan tidak ditemukan.
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Koleksi?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.amber)),
          );
        }
        final koleksi = snapshot.data;
        return koleksi == null ? const KatalogScreen() : KoleksiDetailPage(koleksi: koleksi);
      },
    );
  }
}
