import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Bar atas halaman: tombol kembali di kiri, judul di tengah, ruang di kanan
/// (`.topbar`). Mengikuti pola di HTML:
///
/// - Layar dengan panah kembali: `AppTopBar(title: '...', fallbackRoute: AppRoutes.beranda)`
/// - Layar tab (mis. Katalog, Info) yang panah kembalinya tersembunyi:
///   `AppTopBar(title: '...', showBack: false, titleSize: 18)`
///
/// Tombol kembali memanggil [onBack] kalau diisi. Kalau tidak, ia kembali
/// ke halaman sebelumnya (`pop`) atau, bila tidak ada, pindah ke
/// [fallbackRoute].
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.titleSize = 16,
    this.showBack = true,
    this.onBack,
    this.fallbackRoute,
    this.trailing,
  });

  final String? title;
  final double titleSize;

  /// `false` menyembunyikan panah tetapi tetap menyisakan ruangnya
  /// (`visibility:hidden` di HTML), sehingga judul tetap di tengah.
  final bool showBack;
  final VoidCallback? onBack;
  final String? fallbackRoute;

  /// Widget di kanan (mis. tombol bagikan). Lebar slot-nya 40.
  final Widget? trailing;

  static const double _slot = 40;

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else if (context.canPop()) {
      context.pop();
    } else if (fallbackRoute != null) {
      context.go(fallbackRoute!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 14),
      child: Row(
        children: [
          SizedBox(
            width: _slot,
            height: _slot,
            child: showBack
                ? IconButton(
                    onPressed: () => _handleBack(context),
                    tooltip: 'Kembali',
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.chevron_left, size: 24, color: AppColors.stoneDark),
                  )
                : null,
          ),
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Text(
                    title!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.serif(titleSize),
                  ),
          ),
          SizedBox(width: _slot, height: _slot, child: trailing),
        ],
      ),
    );
  }
}

/// Tombol ikon bulat 36 (`.iconbtn`), mis. ikon cari dan profil di Beranda.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;

  /// Label untuk pembaca layar dan tooltip.
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.offwhite,
        shape: const CircleBorder(side: BorderSide(color: AppColors.stoneLine)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(width: 36, height: 36, child: Icon(icon, size: 17, color: AppColors.ink)),
        ),
      ),
    );
  }
}
