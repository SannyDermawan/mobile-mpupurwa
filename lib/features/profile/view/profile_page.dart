import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/viewmodel/auth_view_model.dart';
import '../../visit/repository/visit_repository.dart';
import '../../visit/viewmodel/visit_status_view_model.dart';
import '../viewmodel/profile_view_model.dart';

/// Layar Profil Saya. Data diri, riwayat, dan aksi keluar akun diatur
/// [ProfileViewModel]; View hanya menyusun widget.
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static const Color primaryGold = Color(0xFFD4A017);
  static const Color goldLight = Color(0xFFE8C86A);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFFFAF9F5);
  static const Color borderGrey = Color(0xFFE8E5DF);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (context) => ProfileViewModel(
        context.read<AuthViewModel>(),
        context.read<VisitRepository>(),
        context.read<VisitStatusViewModel>(),
      )..load(),
      child: Builder(builder: _buildScaffold),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final profile = vm.profile;
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
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vm.subtitle,
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
                  _buildDataRow("Nama", profile.name),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: borderGrey, height: 1),
                  ),
                  _buildDataRow("Domisili", profile.domicile),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: borderGrey, height: 1),
                  ),
                  _buildDataRow("Asal Sekolah", profile.institution),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: borderGrey, height: 1),
                  ),
                  _buildDataRow("Tingkat Pendidikan", profile.educationLevel),
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
                      Expanded(
                        child: Text(
                          "Riwayat Kunjungan",
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < vm.history.length; i++) ...[
                    if (i > 0)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(color: borderGrey, height: 1),
                      ),
                    _buildDataRow(vm.history[i].dateLabel, vm.history[i].status),
                  ],
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
                      Expanded(
                        child: Text(
                          "Data Akun",
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDataRow("No. HP", profile.phone),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: borderGrey, height: 1),
                  ),
                  _buildDataRow("Gmail", profile.email),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Tombol Keluar Akun
            GestureDetector(
              // Router otomatis mengarahkan ke Auth Gate setelah sesi dihapus.
              onTap: vm.logout,
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
          ),
        ),
      ],
    );
  }
}
