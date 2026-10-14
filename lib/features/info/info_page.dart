import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/router/app_routes.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  static const Color primaryGold = Color(0xFFD4A017);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFFFAF9F5);
  static const Color borderGrey = Color(0xFFE8E5DF);

  Future<void> _launchURL(String urlString, BuildContext context) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka link: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              const Center(
                child: Text(
                  "Kunjungan & Lokasi",
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 1. Kartu Jam Operasional
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderGrey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.access_time_outlined, color: primaryGold, size: 22),
                        SizedBox(width: 10),
                        Text(
                          "Jam Operasional",
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTimeRow("Selasa – Jumat", "08.00 – 15.00"),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: borderGrey, height: 1),
                    ),
                    _buildTimeRow("Sabtu – Minggu", "08.00 – 15.00"),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: borderGrey, height: 1),
                    ),
                    _buildTimeRow("Senin", "Tutup", isBoldRight: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Kartu Lokasi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderGrey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined, color: primaryGold, size: 22),
                        SizedBox(width: 10),
                        Text(
                          "Lokasi",
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Perumahan Griya Santa, Jl. Soekarno Hatta No.210 Blok B, Mojolangu, Lowokwaru, Malang City, Jawa Timur 65141",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Visual Peta Placeholder
                    GestureDetector(
                      onTap: () => _launchURL(
                        'https://maps.google.com/?q=Museum+Mpu+Purwa+Malang',
                        context,
                      ),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEADFC9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            // Motif Grid Peta
                            CustomPaint(
                              size: const Size(double.infinity, 150),
                              painter: _GridPainter(),
                            ),
                            const Center(
                              child: Icon(
                                Icons.location_on,
                                color: primaryGold,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Kartu Kontak & Media Sosial
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderGrey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.phone_outlined, color: primaryGold, size: 22),
                        SizedBox(width: 10),
                        Text(
                          "Kontak & Media Sosial",
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(
                      icon: Icons.phone_outlined,
                      title: "(0341) 000-000",
                      onTap: () => _launchURL('tel:0341000000', context),
                    ),
                    _buildContactItem(
                      icon: Icons.camera_alt_outlined,
                      title: "@mumpupurwamalang",
                      onTap: () => _launchURL('https://instagram.com', context),
                    ),
                    _buildContactItem(
                      icon: Icons.play_circle_outline,
                      title: "@museummpupurwa",
                      onTap: () => _launchURL('https://youtube.com', context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Tombol Navigasi Profil & Riwayat Kunjungan
              GestureDetector(
                onTap: () => context.push('/profil'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderGrey),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.person_outline, color: primaryGold, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Profil & Riwayat Kunjungan",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textDark,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow(String day, String time, {bool isBoldRight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBoldRight ? FontWeight.bold : FontWeight.w600,
            color: textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Icon(icon, color: primaryGold, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// Class Gambar Grid Peta Sesuai UI Figma
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDCD1B9)
      ..strokeWidth = 1.0;

    const double step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}