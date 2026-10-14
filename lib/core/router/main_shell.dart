import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_nav_bar.dart';
import 'app_routes.dart';

/// Urutan cabang (branch) di `StatefulShellRoute`. Tab navbar dan tombol Scan
/// memetakan ke indeks ini.
abstract final class AppBranch {
  static const int beranda = 0;
  static const int katalog = 1;
  static const int booking = 2;
  static const int info = 3;
  static const int scan = 4;
  static const int profil = 5;
}

/// Kerangka layar setelah login: isi halaman di atas, navbar bawah di bawahnya.
///
/// Seperti di HTML, navbar tampil di semua layar kecuali layar auth (yang
/// berada di luar shell ini). Tab menyala hanya saat layar yang terbuka
/// adalah salah satu dari Beranda, Katalog, Booking, atau Info; pada
/// layar lain (Detail Koleksi, Profil, Scan QR, ...) tidak ada tab yang menyala.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell, required this.currentPath});

  final StatefulNavigationShell navigationShell;

  /// Path layar yang sedang terbuka, dipakai untuk menentukan tab aktif.
  final String currentPath;

  static const _tabBranch = {
    AppTab.beranda: AppBranch.beranda,
    AppTab.katalog: AppBranch.katalog,
    AppTab.booking: AppBranch.booking,
    AppTab.info: AppBranch.info,
  };

  AppTab? get _activeTab {
    if (!AppRoutes.tabRoots.contains(currentPath)) return null;
    final index = navigationShell.currentIndex;
    for (final entry in _tabBranch.entries) {
      if (entry.value == index) return entry.key;
    }
    return null;
  }

  /// Membuka akar sebuah cabang. `initialLocation: true` membuat ketukan tab
  /// selalu kembali ke layar utama tab itu (seperti `showScreen` di HTML).
  void _goBranch(int index) => navigationShell.goBranch(index, initialLocation: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppNavBar(
        activeTab: _activeTab,
        onTabSelected: (tab) => _goBranch(_tabBranch[tab]!),
        onScan: () => _goBranch(AppBranch.scan),
      ),
    );
  }
}
