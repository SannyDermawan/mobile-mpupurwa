import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_images.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

/// Layar pembuka untuk pengguna yang belum masuk (`screen-authgate`).
class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.charcoal,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppImages.authGateBg,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.7), // center 15%
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x8C0A0A09), Color(0xB80A0A09), Color(0xF00A0A09)],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 32),
                child: Column(
                  children: [
                    const Expanded(child: _AuthGateIntro()),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Column(
                        children: [
                          AppButton(
                            label: 'Masuk',
                            variant: AppButtonVariant.cream,
                            onPressed: () => context.push(AppRoutes.login),
                          ),
                          const SizedBox(height: 11),
                          AppButton(
                            label: 'Buat Akun Baru',
                            variant: AppButtonVariant.outlineCream,
                            onPressed: () => context.push(AppRoutes.register),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthGateIntro extends StatelessWidget {
  const _AuthGateIntro();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.onDarkLine.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.onDarkLine.withValues(alpha: 0.25)),
              ),
              child: const Icon(Icons.account_balance_outlined, size: 32, color: AppColors.cream),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                'Selamat datang di Museum Mpu Purwa',
                textAlign: TextAlign.center,
                style: AppTextStyles.serif(25, color: AppColors.offwhite, height: 1.25),
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 230),
              child: Text(
                'Masuk untuk konfirmasi kunjungan dan menjelajahi katalog koleksi arca & prasasti.',
                textAlign: TextAlign.center,
                style: AppTextStyles.sans(12.5, color: AppColors.onDarkMuted, height: 1.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
