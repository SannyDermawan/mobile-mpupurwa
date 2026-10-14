import 'package:flutter/material.dart';

/// Layar "Kunjungan & Lokasi" (rute /info).
// TODO(Teman 1): implementasi layar ini
class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kunjungan & Lokasi')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text('Kunjungan & Lokasi'), Text('Placeholder, belum diimplementasi.')],
        ),
      ),
    );
  }
}
