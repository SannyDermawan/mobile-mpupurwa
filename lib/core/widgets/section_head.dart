import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Judul bagian dengan tautan di kanan, mis. "Koleksi Unggulan" dan
/// "Lihat semua" (`.section-head`). Tanpa [actionLabel], hanya judul.
class SectionHead extends StatelessWidget {
  const SectionHead({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.bottomSpacing = 12,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppDimens.gutter, 0, AppDimens.gutter, bottomSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(title, style: AppTextStyles.sectionTitle)),
          if (actionLabel != null)
            InkWell(
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(actionLabel!, style: AppTextStyles.link),
              ),
            ),
        ],
      ),
    );
  }
}
