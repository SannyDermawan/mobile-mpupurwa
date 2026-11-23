import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/link_launcher.dart';
import '../model/koleksi_model.dart';
import '../viewmodel/koleksi_detail_view_model.dart';
import '../../../core/widgets/koleksi_image.dart';
import 'widgets/koleksi_serupa_section.dart';

/// Layar Detail Koleksi. Teks tampilan dan pembukaan tautan diatur
/// [KoleksiDetailViewModel]; View hanya menyusun widget.
class KoleksiDetailPage extends StatelessWidget {
  final Koleksi koleksi;

  const KoleksiDetailPage({Key? key, required this.koleksi}) : super(key: key);

  static const Color primaryGold = Color(0xFFD4A017);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFFFAF9F5);
  static const Color borderGrey = Color(0xFFE8E5DF);

  Future<void> _open(BuildContext context, Future<bool> Function() action, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!await action()) {
      messenger.showSnackBar(SnackBar(content: Text('Tidak dapat membuka link: $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = KoleksiDetailViewModel(koleksi, context.read<LinkLauncher>());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Image / Gambar dengan Overlay Button & Badge
            Stack(
              children: [
                Hero(
                  tag: 'koleksi-${koleksi.id}',
                  child: Container(
                    width: double.infinity,
                    height: 380,
                    color: Colors.black12,
                    child: KoleksiImage(
                      url: koleksi.fotoUrl,
                      fallback: Container(
                        color: const Color(0xFF1F1F1F),
                        child: const Icon(
                          Icons.all_inclusive_outlined,
                          size: 80,
                          color: primaryGold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Tombol Back (Kembali) di Pojok Kiri Atas
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                    ),
                  ),
                ),

                // Tombol Share di Pojok Kanan Atas
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 16,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                    child: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                  ),
                ),

                // Badge Era di Pojok Kiri Bawah Gambar
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vm.era,
                      style: const TextStyle(
                        color: primaryGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Konten Informasi Detail
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Koleksi
                  Text(
                    koleksi.nama,
                    style: const TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Teks Ringkasan / Deskripsi Singkat
                  Text(
                    vm.ringkasan,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // 3. Tabel Spesifikasi 2x2 (Grid ber-border)
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderGrey),
                    ),
                    child: Column(
                      children: [
                        // Baris 1: Asal & Periode
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecCell(label: "ASAL", value: vm.asal),
                            ),
                            Container(width: 1, height: 60, color: borderGrey),
                            Expanded(
                              child: _buildSpecCell(label: "PERIODE", value: vm.periode),
                            ),
                          ],
                        ),
                        Container(height: 1, color: borderGrey),
                        // Baris 2: Kerajaan & Material
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecCell(label: "KERAJAAN", value: vm.kerajaan),
                            ),
                            Container(width: 1, height: 60, color: borderGrey),
                            Expanded(
                              child: _buildSpecCell(label: "MATERIAL", value: vm.material),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 4. Bagian Sejarah & Makna
                  const Text(
                    "Sejarah & Makna",
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    vm.sejarah,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.6),
                  ),
                  const SizedBox(height: 24),

                  // 5. Tombol Aksi Opsional (Tonton Video / Baca PDF jika tersedia)
                  if (vm.hasActions)
                    Row(
                      children: [
                        if (vm.hasVideo)
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.play_circle_fill),
                              label: const Text("Tonton Video"),
                              onPressed: () => _open(context, vm.openVideo, koleksi.videoUrl!),
                            ),
                          ),
                        if (vm.hasVideo && vm.hasPdf) const SizedBox(width: 12),
                        if (vm.hasPdf)
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textDark,
                                side: const BorderSide(color: textDark),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text("Baca PDF"),
                              onPressed: () => _open(context, vm.openPdf, koleksi.pdfUrl!),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 28),

                  // 6. Koleksi serupa (hasil analisis teks / ML)
                  KoleksiSerupaSection(
                    koleksiId: koleksi.id,
                    onOpen: (item) => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => KoleksiDetailPage(koleksi: item)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Sel Spesifikasi
  Widget _buildSpecCell({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Serif',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
