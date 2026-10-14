import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

/// Kartu hero gelap di Beranda (`.hero`).
class HomeHero extends StatelessWidget {
  const HomeHero({super.key, required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.gutter),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.34, -0.94), // 160deg
              end: Alignment(0.34, 0.94),
              colors: [AppColors.charcoal, AppColors.heroEnd],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.onDarkLine.withValues(alpha: 0.14)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Katalog Digital Museum'.toUpperCase(),
                        style: AppTextStyles.sans(
                          11,
                          weight: FontWeight.w700,
                          color: AppColors.amber,
                          letterSpacing: 0.66,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 230),
                        child: Text(
                          'Telusuri jejak Kanjuruhan hingga Singosari',
                          style: AppTextStyles.serif(23, color: AppColors.offwhite),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: Text(
                          '129 koleksi arca & prasasti, lengkap dengan sejarah, video, dan dokumen pendukung.',
                          style: AppTextStyles.sans(13, color: AppColors.onDarkMuted, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 18),
                      AppPillButton(label: 'Jelajahi Koleksi', onPressed: onExplore),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
