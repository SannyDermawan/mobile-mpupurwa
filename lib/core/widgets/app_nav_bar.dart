import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Tab di navbar bawah. Tombol Scan di tengah bukan tab: ia membuka layar
/// Scan QR.
enum AppTab {
  beranda('Beranda', Icons.home_outlined),
  katalog('Katalog', Icons.grid_view_outlined),
  booking('Booking', Icons.calendar_today_outlined),
  info('Info', Icons.museum_outlined);

  const AppTab(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Navbar bawah (`.navbar`): Beranda, Katalog, [Scan], Booking, Info.
///
/// [activeTab] `null` berarti tidak ada tab yang menyala (seperti HTML saat
/// membuka Detail, Profil, Scan QR, dan sebagainya).
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    required this.onScan,
  });

  final AppTab? activeTab;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback onScan;

  /// Tombol Scan menonjol 17 dp di atas bar. Ruang ini ikut di dalam
  /// widget supaya area ketuk tombolnya tetap terjangkau.
  static const double _overshoot = 17;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    Widget tab(AppTab t) => Expanded(
      child: _NavItem(tab: t, active: t == activeTab, onTap: () => onTabSelected(t)),
    );

    return Stack(
      children: [
        const Positioned.fill(
          top: _overshoot,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.offwhite,
              border: Border(top: BorderSide(color: AppColors.stoneLine)),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8, _overshoot + 10, 8, 14 + bottomInset),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              tab(AppTab.beranda),
              tab(AppTab.katalog),
              const Expanded(child: SizedBox.shrink()), // ruang tombol Scan
              tab(AppTab.booking),
              tab(AppTab.info),
            ],
          ),
        ),
        Positioned(
          top: 0.5,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: _ScanButton(onTap: onScan),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.active, required this.onTap});

  final AppTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.amber : AppColors.inkSoft;
    return Semantics(
      button: true,
      selected: active,
      label: tab.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(tab.label, style: AppTextStyles.navLabel.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Scan QR',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.greenDeep,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.offwhite, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.amber.withValues(alpha: 0.35),
                    offset: const Offset(0, 8),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(Icons.qr_code, size: 22, color: AppColors.cream),
            ),
            const SizedBox(height: 5),
            Text('Scan', style: AppTextStyles.navLabel),
          ],
        ),
      ),
    );
  }
}
