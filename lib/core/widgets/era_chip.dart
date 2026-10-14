import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Chip filter era (`.chip`), mis. "Semua", "Kanjuruhan", "Prasasti".
/// Chip aktif berlatar emas.
class EraChip extends StatelessWidget {
  const EraChip({super.key, required this.label, required this.onTap, this.active = false});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.amber : AppColors.offwhite,
      shape: StadiumBorder(side: BorderSide(color: active ? AppColors.amber : AppColors.stoneLine)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            maxLines: 1,
            style: AppTextStyles.sans(
              12,
              weight: FontWeight.w600,
              color: active ? AppColors.charcoal : AppColors.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}

/// Teks kecil kapital emas penanda era di kartu koleksi
/// (`.feat-badge` ukuran 9.5, `.col-era` ukuran 9).
class EraBadge extends StatelessWidget {
  const EraBadge(this.text, {super.key, this.fontSize = 9.5});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppTextStyles.badge(fontSize));
  }
}

/// Lencana era berlatar gelap di atas foto (`.detail-badge`).
class EraOverlayBadge extends StatelessWidget {
  const EraOverlayBadge(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD1141413),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(text.toUpperCase(), style: AppTextStyles.badge(10)),
      ),
    );
  }
}
