import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'koleksi_model.dart';

class KoleksiDetailPage extends StatelessWidget {
  final Koleksi koleksi;

  const KoleksiDetailPage({
    Key? key,
    required this.koleksi,
  }) : super(key: key);

  static const Color primaryGold = Color(0xFFD4A017);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFFFAF9F5);
  static const Color borderGrey = Color(0xFFE8E5DF);

  Future<void> _launchURL(String urlString, BuildContext context) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat membuka link: $urlString')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = koleksi.fotoUrl.isNotEmpty;

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
                    child: hasImage
                        ? Image.network(
                            koleksi.fotoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF1F1F1F),
                              child: const Icon(
                                Icons.all_inclusive_outlined,
                                size: 80,
                                color: primaryGold,
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFF1F1F1F),
                            child: const Icon(
                              Icons.all_inclusive_outlined,
                              size: 80,
                              color: primaryGold,
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
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 28,
                      ),
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
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                // Badge Era di Pojok Kiri Bawah Gambar
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      koleksi.era.toUpperCase(),
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
                    "Koleksi paling istimewa Museum Mpu Purwa — satu-satunya ${koleksi.nama.toLowerCase()} berkendaraan tikus yang tercatat di Indonesia.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
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
                              child: _buildSpecCell(
                                label: "ASAL",
                                value: koleksi.asal.isNotEmpty ? koleksi.asal : "Malang Raya",
                              ),
                            ),
                            Container(width: 1, height: 60, color: borderGrey),
                            Expanded(
                              child: _buildSpecCell(
                                label: "PERIODE",
                                value: koleksi.periode.isNotEmpty ? koleksi.periode : "Abad 13",
                              ),
                            ),
                          ],
                        ),
                        Container(height: 1, color: borderGrey),
                        // Baris 2: Kerajaan & Material
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecCell(
                                label: "KERAJAAN",
                                value: koleksi.era.isNotEmpty ? koleksi.era : "Singosari",
                              ),
                            ),
                            Container(width: 1, height: 60, color: borderGrey),
                            Expanded(
                              child: _buildSpecCell(
                                label: "MATERIAL",
                                value: koleksi.material.isNotEmpty ? koleksi.material : "Batu Andesit",
                              ),
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
                    koleksi.sejarah.isNotEmpty
                        ? koleksi.sejarah
                        : "Ganesya digambarkan duduk di atas tikus, wahana yang melambangkan kemampuan menembus rintangan sekecil apa pun. Arca ini dipuja sebagai penghalau rintangan dan pelindung ilmu pengetahuan pada masa Kerajaan Singosari.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Tombol Aksi Opsional (Tonton Video / Baca PDF jika tersedia)
                  if ((koleksi.videoUrl != null && koleksi.videoUrl!.isNotEmpty) ||
                      (koleksi.pdfUrl != null && koleksi.pdfUrl!.isNotEmpty))
                    Row(
                      children: [
                        if (koleksi.videoUrl != null && koleksi.videoUrl!.isNotEmpty)
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
                              onPressed: () => _launchURL(koleksi.videoUrl!, context),
                            ),
                          ),
                        if (koleksi.videoUrl != null &&
                            koleksi.videoUrl!.isNotEmpty &&
                            koleksi.pdfUrl != null &&
                            koleksi.pdfUrl!.isNotEmpty)
                          const SizedBox(width: 12),
                        if (koleksi.pdfUrl != null && koleksi.pdfUrl!.isNotEmpty)
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
                              onPressed: () => _launchURL(koleksi.pdfUrl!, context),
                            ),
                          ),
                      ],
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