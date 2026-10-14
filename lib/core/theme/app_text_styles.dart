import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Gaya teks. Heading memakai Fraunces (serif), teks isi memakai Karla,
/// sama seperti `<link>` Google Fonts di HTML.
///
/// Dua fungsi dasar, [serif] dan [sans], bisa dipakai langsung kalau butuh
/// gaya yang belum punya nama. Ukuran dalam dp sama dengan px di CSS.
abstract final class AppTextStyles {
  /// Fraunces. Di HTML `h1`/`h2`/`h3` berbobot 600; elemen `div` yang
  /// memakai Fraunces (mis. `.feat-title`) berbobot normal (400).
  static TextStyle serif(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.stoneDark,
    double height = 1.15,
    double? letterSpacing,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Karla, font isi di HTML.
  static TextStyle sans(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.karla(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // --- Judul ---
  static TextStyle get brandName => serif(17);
  static TextStyle get sectionTitle => serif(18);
  static TextStyle get authTitle => serif(21);
  static TextStyle get screenTitle => serif(18);

  /// `.eyebrow`: teks kecil emas di atas judul.
  static TextStyle get eyebrow =>
      sans(11.5, weight: FontWeight.w700, color: AppColors.amber, letterSpacing: 0.23);

  // --- Teks isi ---
  static TextStyle get body => sans(13);
  static TextStyle get bodySoft => sans(12.5, color: AppColors.inkSoft, height: 1.5);
  static TextStyle get caption => sans(11, color: AppColors.inkSoft, height: 1.4);

  /// `.section-head .link` ("Lihat semua").
  static TextStyle get link => sans(12, weight: FontWeight.w700, color: AppColors.amber);

  // --- Form ---
  static TextStyle get formLabel => sans(12, weight: FontWeight.w700, color: AppColors.stoneDark);
  static TextStyle get formInput => sans(13, color: AppColors.ink);
  static TextStyle get formHint => sans(13, color: AppColors.stoneMid);
  static TextStyle get formError => sans(11.5, color: AppColors.error, height: 1.4);

  // --- Tombol ---
  static TextStyle get button => sans(13, weight: FontWeight.w700, color: AppColors.charcoal);
  static TextStyle get buttonAuth =>
      sans(13.5, weight: FontWeight.w700, color: AppColors.stoneDark);

  // --- Badge era (`.feat-badge`, `.col-era`) ---
  static TextStyle badge(double size, {double letterSpacingEm = 0.03}) => sans(
    size,
    weight: FontWeight.w700,
    color: AppColors.amber,
    letterSpacing: size * letterSpacingEm,
  );

  // --- Navbar ---
  static TextStyle get navLabel =>
      sans(10.5, weight: FontWeight.w600, color: AppColors.inkSoft, letterSpacing: 0.105);
}
