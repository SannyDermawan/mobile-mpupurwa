import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Kartu putih gading dengan garis tipis (`.card`).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.fromLTRB(AppDimens.gutter, 0, AppDimens.gutter, 16),
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimens.radiusCard);
    return Padding(
      padding: margin,
      child: Material(
        color: AppColors.offwhite,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppColors.stoneLine),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Kepala kartu: ikon emas + judul (`.card-head`).
class CardHeader extends StatelessWidget {
  const CardHeader({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.amber),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: AppTextStyles.serif(14.5))),
        ],
      ),
    );
  }
}

/// Baris jam operasional: label di kiri, nilai tebal di kanan, garis putus-putus
/// di bawahnya (`.hours-row`). Set [isLast] pada baris terakhir untuk
/// menghilangkan garisnya.
///
/// Isi baris diambil dari `MuseumHours.rows`, jangan tulis jamnya langsung.
class HoursRow extends StatelessWidget {
  const HoursRow({super.key, required this.label, required this.value, this.isLast = false});

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: isLast ? null : const _DashedBottomLine(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.sans(12.5, color: AppColors.inkSoft)),
            Text(
              value,
              style: AppTextStyles.sans(12.5, weight: FontWeight.w600, color: AppColors.stoneDark),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBottomLine extends CustomPainter {
  const _DashedBottomLine();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.stoneLine
      ..strokeWidth = 1;
    const dash = 3.0;
    const gap = 3.0;
    final y = size.height - 0.5;
    for (double x = 0; x < size.width; x += dash + gap) {
      canvas.drawLine(Offset(x, y), Offset((x + dash).clamp(0, size.width), y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Kotak info berlatar krem dengan ikon di kiri (`.infobar`). Isinya [message],
/// biasanya `Text.rich` dengan bagian tebal.
///
/// [margin] default sama dengan CSS (`0 22 26`); isi `EdgeInsets.zero`
/// kalau dipasang di dalam padding lain.
class InfoBar extends StatelessWidget {
  const InfoBar({
    super.key,
    required this.icon,
    required this.message,
    this.onTap,
    this.margin = const EdgeInsets.fromLTRB(AppDimens.gutter, 0, AppDimens.gutter, 26),
    this.backgroundColor = AppColors.sand,
    this.borderColor = AppColors.stoneLine,
    this.iconColor = AppColors.amber,
  });

  final IconData icon;
  final InlineSpan message;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  /// Gaya teks `<b>` di dalam infobar, untuk dipakai pada `TextSpan` tebal.
  static TextStyle get boldStyle =>
      AppTextStyles.sans(12, weight: FontWeight.w700, color: AppColors.stoneDark, height: 1.5);

  /// Gaya teks biasa di dalam infobar.
  static TextStyle get textStyle => AppTextStyles.sans(12, color: AppColors.inkSoft, height: 1.5);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text.rich(message, style: textStyle)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
