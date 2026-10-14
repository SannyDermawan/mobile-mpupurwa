import 'package:flutter/material.dart';

/// Layar "Konfirmasi Kunjungan" (rute /scan-qr).
// TODO(Teman 2): implementasi layar ini
class ScanQrPage extends StatelessWidget {
  const ScanQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Kunjungan')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text('Konfirmasi Kunjungan'), Text('Placeholder, belum diimplementasi.')],
        ),
      ),
    );
  }
}
