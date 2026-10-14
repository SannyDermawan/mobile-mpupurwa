import 'package:flutter/painting.dart';

/// Warna aplikasi. Nilainya diambil dari variabel `:root` dan warna yang
/// ditulis langsung di CSS `Museum_Mpu_Purwa_App.html`.
abstract final class AppColors {
  // --- Variabel :root di HTML ---
  static const Color stoneDark = Color(0xFF1F1F1F);
  static const Color stoneMid = Color(0xFF8A8A85);
  static const Color stoneLine = Color(0xFFE4E1D8);
  static const Color cream = Color(0xFFFFFFFF);
  static const Color offwhite = Color(0xFFFAFAF8);
  static const Color greenDeep = Color(0xFF1F1F1F);
  static const Color greenSoft = Color(0xFF3A3A38);
  static const Color ink = Color(0xFF1F1F1F);
  static const Color inkSoft = Color(0xFF6E6E68);
  static const Color amber = Color(0xFFD4AF37);
  static const Color goldDeep = Color(0xFFB8952E);
  static const Color charcoal = Color(0xFF1F1F1F);
  static const Color charcoalSoft = Color(0xFF2B2B29);

  // --- Warna yang ditulis langsung di CSS ---
  /// Latar `.infobar` dan `.status-card`.
  static const Color sand = Color(0xFFEFE3C7);

  /// Latar banner "kunjungan tercatat".
  static const Color sandLight = Color(0xFFFBF3DC);
  static const Color sandLightBorder = Color(0xFFE9D9A8);

  /// Ujung gelap gradien hero (`#0E0E0D`).
  static const Color heroEnd = Color(0xFF0E0E0D);

  /// Teks paragraf di atas latar gelap (hero, auth gate).
  static const Color onDarkMuted = Color(0xFFC9C9C4);

  /// Deskripsi di kartu detail linimasa.
  static const Color onDarkSoft = Color(0xFFDCD8CE);

  /// Gradien latar placeholder gambar (`.feat-art`, `.col-art`).
  static const Color artStart = Color(0xFF2E2E2B);
  static const Color artEnd = Color(0xFF141412);

  /// Garis tipis di atas latar gelap: `rgba(241,233,216,…)`.
  static const Color onDarkLine = Color(0xFFF1E9D8);

  /// Pesan validasi. Tidak ada di HTML, dipakai untuk error form.
  static const Color error = Color(0xFFB3261E);
}
