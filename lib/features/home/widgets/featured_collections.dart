import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/era_chip.dart';
import '../data/home_models.dart';

/// Daftar kartu "Koleksi Unggulan" yang bisa digeser ke samping (`.hscroll`).
/// Tap kartu memanggil [onOpen] dengan id koleksi.
class FeaturedCollections extends StatelessWidget {
  const FeaturedCollections({super.key, required this.items, required this.onOpen});

  final List<FeaturedCollection> items;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(AppDimens.gutter, 2, AppDimens.gutter, 6),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              _FeaturedCard(item: items[i], onTap: () => onOpen(items[i].id)),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.item, required this.onTap});

  final FeaturedCollection item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: Material(
        color: AppColors.offwhite,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          side: const BorderSide(color: AppColors.stoneLine),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 110, child: _FeaturedArt(item: item)),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EraBadge(item.eraLabel),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: AppTextStyles.serif(14.5, weight: FontWeight.w400, height: 1.2),
                    ),
                    const SizedBox(height: 3),
                    Text(item.subtitle, style: AppTextStyles.sans(11.5, color: AppColors.inkSoft)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedArt extends StatelessWidget {
  const _FeaturedArt({required this.item});

  final FeaturedCollection item;

  @override
  Widget build(BuildContext context) {
    final asset = item.imageAsset;
    if (asset != null) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        alignment: Alignment(0, item.imageFocusY * 2 - 1),
        cacheWidth: 504, // 3x lebar kartu, cukup tajam dan hemat memori
        semanticLabel: item.title,
      );
    }
    // Tanpa foto: ikon emas di atas gradien gelap, seperti di HTML.
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.5, -0.87), // 150deg
          end: Alignment(0.5, 0.87),
          colors: [AppColors.artStart, AppColors.artEnd],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.85,
          child: Icon(Icons.article_outlined, size: 44, color: AppColors.amber),
        ),
      ),
    );
  }
}
