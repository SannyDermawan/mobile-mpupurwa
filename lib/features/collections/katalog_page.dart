import 'package:flutter/material.dart';

/// Layar "Katalog Koleksi" (rute /katalog).
// TODO(Teman 1): implementasi layar ini
class KatalogPage extends StatelessWidget {
  const KatalogPage({super.key, this.era});

  /// Filter era dari query `?era=` (mis. dari tombol "Lihat Koleksi Era Ini"
  /// di Beranda). `null` berarti "Semua".
  final String? era;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Koleksi')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Katalog Koleksi'),
            const Text('Placeholder, belum diimplementasi.'),
            Text('era: ${era ?? '-'}'),
          ],
        ),
      ),
    );
  }
}
