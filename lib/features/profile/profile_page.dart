import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static const Color primaryGold = Color(0xFFD4A017);
  static const Color goldLight = Color(0xFFE8C86A);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFFFAF9F5);
  static const Color borderGrey = Color(0xFFE8E5DF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: textDark, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: [
            // 1. Kartu Header Profil Utama (Avatar & Nama)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderGrey),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: goldLight,
                    child: const Icon(Icons.person_outline, color: textDark, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Amanda Putri",
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Mahasiswa · Surabaya",
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Kartu Data Diri (Lengkap dengan Tombol Edit)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderGrey),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.person_outline, color: primaryGold, size: 22),
                          SizedBox(width: 10),
                          Text(
                            "Data Diri",
                            style: TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                      // Tombol Edit Pensil
                      GestureDetector(
                        onTap: () {
                          // TODO: Tambahkan aksi edit profil
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: borderGrey),
                          ),
                          child: const Icon(Icons.edit_outlined, color: primaryGold, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDataRow("Nama", "Amanda Putri"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: borderGrey, height: 1),
                  ),
                  _buildDataRow("Domisili", "Surabaya"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: borderGrey, height: 1),
                  ),
                  _buildDataRow("Asal Sekolah", "Univ. Airlangga"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: borderGrey, height: 1),
                  ),
                  _buildDataRow("Tingkat Pendidikan", "Mahasiswa"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Kartu Riwayat Kunjungan
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
                        "Riwayat Kunjungan",
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
                  _buildDataRow("22 Sep 2026", "Tercatat"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: borderGrey, height: 1),
                  ),
                  _buildDataRow("03 Agu 2026", "Tercatat"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: borderGrey, height: 1),
                  ),
                  _buildDataRow("17 Mei 2026", "Tercatat"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Kartu Data Akun
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
                      Icon(Icons.credit_card_outlined, color: primaryGold, size: 22),
                      SizedBox(width: 10),
                      Text(
                        "Data Akun",
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
                  _buildDataRow("No. HP", "0812-xxxx-3421"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: borderGrey, height: 1),
                  ),
                  _buildDataRow("Gmail", "amanda@gmail.com"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Tombol Keluar Akun
            GestureDetector(
              onTap: () {
                // Navigasi kembali ke Auth Gate / Login
                context.go(AppRoutes.authgate);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderGrey),
                ),
                child: const Center(
                  child: Text(
                    "Bukan saya, keluar akun",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget Baris Pasangan Label dan Nilai
  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
        ),
      ],
    );
  }
}
