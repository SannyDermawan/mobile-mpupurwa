import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

/// Satu kartu di grid "Akses Cepat".
class QuickAccessItem {
  const QuickAccessItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

/// Grid 2 kolom "Akses Cepat" (`.quickgrid`). Item disusun dua per baris
/// dengan tinggi yang sama dalam satu baris.
class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key, required this.items});

  final List<QuickAccessItem> items;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      final second = i + 1 < items.length ? items[i + 1] : null;
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 12));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _QuickCard(item: items[i])),
              const SizedBox(width: 12),
              Expanded(child: second == null ? const SizedBox.shrink() : _QuickCard(item: second)),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.gutter),
      child: Column(children: rows),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.item});

  final QuickAccessItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.offwhite,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.stoneLine),
      ),
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, size: 22, color: AppColors.amber),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: AppTextStyles.serif(14, weight: FontWeight.w400, height: 1.2),
              ),
              const SizedBox(height: 3),
              Text(item.subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}
