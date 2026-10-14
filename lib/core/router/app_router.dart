import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_gate_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/otp_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/booking/booking_page.dart';
import '../../features/booking/status_booking_page.dart';
import '../../features/collections/katalog_page.dart';
import '../../features/collections/koleksi_detail_page.dart';
import '../../features/collections/koleksi_model.dart';
import '../../features/home/beranda_page.dart';
import '../../features/info/info_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/visit/kunjungan_tercatat_page.dart';
import '../../features/visit/scan_qr_page.dart';
import '../state/auth_controller.dart';
import 'app_routes.dart';
import 'main_shell.dart';

/// Membuat router aplikasi.
///
/// **Guard login.** Belum login: hanya boleh ke `authgate`, `login`, `register`,
/// `otp`. Sudah login: layar auth dilewati dan langsung ke `beranda`.
/// Router memantau [auth], jadi login/logout langsung memindahkan layar.
///
/// **Menambah halaman.** Layar milik tab bernavbar didaftarkan sebagai
/// `GoRoute` di salah satu `StatefulShellBranch` di bawah. Path dibuat
/// absolut (diawali `/`) dan dipakai lewat [AppRoutes].
GoRouter createAppRouter(AuthController auth) {
  return GoRouter(
    initialLocation: AppRoutes.authgate,
    refreshListenable: auth,
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == '/') {
        return auth.isLoggedIn ? AppRoutes.beranda : AppRoutes.authgate;
      }
      final inAuthFlow = AppRoutes.authFlow.contains(path);
      if (!auth.isLoggedIn && !inAuthFlow) return AppRoutes.authgate;
      if (auth.isLoggedIn && inAuthFlow) return AppRoutes.beranda;
      return null;
    },
    errorBuilder: (context, state) => _NotFoundPage(auth: auth),
    routes: [
      // --- Alur auth (tanpa navbar) ---
      GoRoute(
        path: AppRoutes.authgate,
        name: AppRoutes.authgateName,
        builder: (context, state) => const AuthGatePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.registerName,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: AppRoutes.otpName,
        builder: (context, state) => const OtpPage(),
      ),

      // --- Layar utama (dengan navbar) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell, currentPath: state.uri.path),
        // Urutan cabang harus sama dengan `AppBranch`.
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.beranda,
                name: AppRoutes.berandaName,
                builder: (context, state) => const BerandaPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.katalog,
                name: AppRoutes.katalogName,
                builder: (context, state) => const KatalogScreen(),
              ),
              GoRoute(
                path: AppRoutes.koleksi,
                name: AppRoutes.koleksiName,
                builder: (context, state) {
                  final koleksi = state.extra as Koleksi?;
                  if (koleksi == null) {
                    return const KatalogScreen();
                  }
                  return KoleksiDetailPage(koleksi: koleksi);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.booking,
                name: AppRoutes.bookingName,
                builder: (context, state) => const BookingPage(),
              ),
              GoRoute(
                path: AppRoutes.statusBooking,
                name: AppRoutes.statusBookingName,
                builder: (context, state) => const StatusBookingPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.info,
                name: AppRoutes.infoName,
                builder: (context, state) => const InfoPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.scanQr,
                name: AppRoutes.scanQrName,
                builder: (context, state) => const ScanQrPage(),
              ),
              GoRoute(
                path: AppRoutes.kunjunganTercatat,
                name: AppRoutes.kunjunganTercatatName,
                builder: (context, state) => const KunjunganTercatatPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profil,
                name: AppRoutes.profilName,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({required this.auth});

  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Halaman tidak ditemukan.'),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(auth.isLoggedIn ? AppRoutes.beranda : AppRoutes.authgate),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
