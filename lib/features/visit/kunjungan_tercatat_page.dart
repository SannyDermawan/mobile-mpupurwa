import 'package:flutter/material.dart';

/// Layar "Kunjungan Tercatat" (rute /kunjungan-tercatat).
// TODO(Teman 2): implementasi layar ini
class KunjunganTercatatPage extends StatelessWidget {
  const KunjunganTercatatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kunjungan Tercatat')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text('Kunjungan Tercatat'), Text('Placeholder, belum diimplementasi.')],
        ),
      ),
    );
  }
}
