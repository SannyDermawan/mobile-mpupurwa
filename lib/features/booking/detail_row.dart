import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Baris label dan nilai di kartu detail: label di kiri, nilai tebal rata
/// kanan, dengan garis tipis di bawahnya.
///
/// Mirip `HoursRow`, tetapi nilainya fleksibel dan boleh membungkus ke baris
/// berikutnya. Itu perlu untuk isian bebas seperti nama instansi dan catatan.
/// Set [isLast] pada baris terakhir untuk menghilangkan garisnya.
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value, this.isLast = false});

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.stoneLine)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 8, bottom: isLast ? 0 : 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.sans(12.5, color: AppColors.inkSoft)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: AppTextStyles.sans(
                  12.5,
                  weight: FontWeight.w600,
                  color: AppColors.stoneDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
