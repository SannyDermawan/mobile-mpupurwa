import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Kepala form auth: eyebrow emas, judul, dan deskripsi (`.authform-head`).
class AuthFormHead extends StatelessWidget {
  const AuthFormHead({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.centered = false,
  });

  final String eyebrow;
  final String title;
  final String description;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(eyebrow, textAlign: align, style: AppTextStyles.eyebrow),
          const SizedBox(height: 6),
          Text(title, textAlign: align, style: AppTextStyles.authTitle),
          const SizedBox(height: 6),
          Text(description, textAlign: align, style: AppTextStyles.bodySoft),
        ],
      ),
    );
  }
}

/// Tautan di bawah form, mis. "Belum punya akun? Daftar di sini" (`.authlink`).
class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({
    super.key,
    required this.prefix,
    required this.linkText,
    required this.onTap,
  });

  final String prefix;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(prefix, style: AppTextStyles.sans(12.5, color: AppColors.inkSoft)),
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                linkText,
                style: AppTextStyles.sans(12.5, weight: FontWeight.w700, color: AppColors.amber),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
