import 'package:flutter/material.dart';

/// Layar "Detail Koleksi" (rute /koleksi/:id).
// TODO(Teman 1): implementasi layar ini
class KoleksiDetailPage extends StatelessWidget {
  const KoleksiDetailPage({super.key, required this.id});

  /// Id koleksi dari path, mis. `ganesya`, `brahma`, `catur`.
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Koleksi')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Detail Koleksi'),
            const Text('Placeholder, belum diimplementasi.'),
            Text('id: $id'),
          ],
        ),
      ),
    );
  }
}
