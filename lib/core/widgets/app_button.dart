import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Varian tombol di HTML:
/// - [primary]: `.btn-primary` (emas, teks gelap)
/// - [secondary]: `.btn-secondary` (putih gading, garis tipis)
/// - [cream]: `.btn-cream` (tombol terang di layar auth yang gelap)
/// - [outlineCream]: `.btn-outline-cream` (tombol garis di layar auth)
enum AppButtonVariant { primary, secondary, cream, outlineCream }

/// Tombol standar aplikasi. Lebarnya penuh secara default; set
/// [expanded] ke `false` kalau butuh lebar sesuai isi.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expanded = true,
    this.verticalPadding,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    this.verticalPadding,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    this.verticalPadding,
  }) : variant = AppButtonVariant.secondary;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  /// Ikon di kiri label (ukuran 15, jarak 7, seperti di HTML).
  final IconData? icon;
  final bool expanded;

  /// Padding atas-bawah. Default 13 (primary/secondary) atau 14 (cream/outline),
  /// sama dengan CSS. Layar auth memakai 14 untuk tombol primary.
  final double? verticalPadding;

  bool get _isCreamFamily =>
      variant == AppButtonVariant.cream || variant == AppButtonVariant.outlineCream;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.symmetric(
      vertical: verticalPadding ?? (_isCreamFamily ? 14 : 13),
      horizontal: 13,
    );
    final radius = BorderRadius.circular(
      _isCreamFamily ? AppDimens.radiusButtonAuth : AppDimens.radiusMd,
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 15), const SizedBox(width: 7)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding,
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: content,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: padding,
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: content,
      ),
      AppButtonVariant.cream => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.offwhite,
          foregroundColor: AppColors.stoneDark,
          padding: padding,
          minimumSize: Size.zero,
          textStyle: AppTextStyles.buttonAuth,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: content,
      ),
      AppButtonVariant.outlineCream => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.offwhite,
          padding: padding,
          minimumSize: Size.zero,
          textStyle: AppTextStyles.buttonAuth,
          side: BorderSide(color: AppColors.onDarkLine.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: content,
      ),
    };

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Tombol pil emas dengan panah di kanan, mis. "Jelajahi Koleksi" di hero
/// (`.hero-cta`) dan "Lihat Koleksi Era Ini" di linimasa
/// (`.timeline-detail-cta`).
class AppPillButton extends StatelessWidget {
  const AppPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fontSize = 13,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.iconSize = 13,
    this.trailingIcon = Icons.arrow_forward,
  });

  final String label;
  final VoidCallback? onPressed;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: AppTextStyles.sans(fontSize, weight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusPill)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (trailingIcon != null) ...[
            const SizedBox(width: 6),
            Icon(trailingIcon, size: iconSize),
          ],
        ],
      ),
    );
  }
}
