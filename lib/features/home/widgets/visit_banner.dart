import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/state/visit_status_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';

/// Banner status kunjungan di Beranda. Ada dua keadaan, mengikuti
/// [VisitStatusController.visitRecordedToday]:
///
/// - belum tercatat: "Sedang di museum?", bisa di-tap menuju Scan QR
/// - sudah tercatat: "Kunjungan hari ini tercatat."
class VisitBanner extends StatelessWidget {
  const VisitBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final recorded = context.watch<VisitStatusController>().visitRecordedToday;

    if (recorded) {
      return InfoBar(
        icon: Icons.check,
        iconColor: AppColors.charcoal,
        backgroundColor: AppColors.sandLight,
        borderColor: AppColors.sandLightBorder,
        margin: EdgeInsets.zero,
        message: TextSpan(
          children: [
            TextSpan(
              text: 'Kunjungan hari ini tercatat.',
              style: AppTextStyles.sans(
                12,
                weight: FontWeight.w700,
                color: AppColors.charcoal,
                height: 1.5,
              ),
            ),
            const TextSpan(text: ' Selamat menjelajah koleksi Museum Mpu Purwa!'),
          ],
        ),
      );
    }

    return InfoBar(
      icon: Icons.qr_code,
      margin: EdgeInsets.zero,
      onTap: () => context.go(AppRoutes.scanQr),
      message: TextSpan(
        children: [
          TextSpan(text: 'Sedang di museum?', style: InfoBar.boldStyle),
          const TextSpan(text: ' Tap di sini dan scan QR untuk mencatat kunjunganmu hari ini.'),
        ],
      ),
    );
  }
}
