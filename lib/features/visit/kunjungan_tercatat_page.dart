import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/state/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_top_bar.dart';
import '../booking/detail_row.dart';
import '../booking/tanggal_format.dart';

/// Layar "Kunjungan Tercatat" (rute /kunjungan-tercatat): konfirmasi bahwa
/// kunjungan hari ini sudah tercatat. Dibuka dari layar Scan QR.
class KunjunganTercatatPage extends StatelessWidget {
  const KunjunganTercatatPage({super.key, this.visitDate});

  /// Tanggal kunjungan yang ditampilkan. Kosong berarti hari ini.
  final DateTime? visitDate;

  @override
  Widget build(BuildContext context) {
    final date = visitDate ?? DateTime.now();
    final profile = context.watch<AuthController>().profile;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTopBar(
                title: 'Kunjungan Tercatat',
                titleSize: 17,
                fallbackRoute: AppRoutes.beranda,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppDimens.gutter, 16, AppDimens.gutter, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _CheckBadge(),
                    const SizedBox(height: 22),
                    Text(
                      'Kunjungan Tercatat!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.serif(24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Terima kasih sudah berkunjung ke Museum Mpu Purwa. '
                      'Kunjunganmu hari ini sudah tersimpan.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySoft,
                    ),
                    const SizedBox(height: 26),
                    AppCard(
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const CardHeader(
                            icon: Icons.event_available_outlined,
                            title: 'Detail Kunjungan',
                          ),
                          DetailRow(label: 'Tanggal', value: formatTanggalLengkap(date)),
                          if (profile != null) DetailRow(label: 'Pengunjung', value: profile.name),
                          const DetailRow(label: 'Status', value: 'Tercatat', isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Mulai Jelajahi Koleksi',
                      icon: Icons.grid_view_outlined,
                      onPressed: () => context.go(AppRoutes.katalog),
                    ),
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

/// Lingkaran dengan tanda centang. Membesar sebentar saat muncul.
class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'Centang, kunjungan tercatat',
        image: true,
        excludeSemantics: true,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Container(
            width: 120,
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sandLight,
              border: Border.all(color: AppColors.sandLightBorder),
            ),
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.amber.withValues(alpha: 0.4),
                    offset: const Offset(0, 8),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, size: 48, color: AppColors.charcoal),
            ),
          ),
        ),
      ),
    );
  }
}
