import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Baris tautan: ikon emas, label, dan panah di kanan (`.link-row`).
/// Dipakai di kartu kontak dan menu profil.
class LinkRow extends StatelessWidget {
  const LinkRow({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.verticalPadding = 8,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: Row(
          children: [
            Icon(icon, size: 17, color: AppColors.amber),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.sans(13, weight: FontWeight.w600, color: AppColors.stoneDark),
              ),
            ),
            const Icon(Icons.chevron_right, size: 15, color: AppColors.inkSoft),
          ],
        ),
      ),
    );
  }
}
