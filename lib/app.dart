import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/services/link_launcher.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/viewmodel/auth_view_model.dart';
import 'features/booking/repository/booking_repository.dart';
import 'features/booking/viewmodel/booking_view_model.dart';
import 'features/collections/repository/dummy_koleksi_repository.dart';
import 'features/collections/repository/koleksi_repository.dart';
import 'features/collections/repository/serupa_repository.dart';
import 'features/home/repository/home_repository.dart';
import 'features/visit/repository/visit_repository.dart';
import 'features/visit/viewmodel/visit_status_view_model.dart';

/// Akar aplikasi (composition root): satu-satunya tempat yang merakit
/// dependensi, lalu memasang router.
///
/// Alur dependensi MVVM:
///
/// ```text
/// View ──► ViewModel ──► Repository (antarmuka) ──► Service / data
/// ```
///
/// - Repository dan service disediakan lewat `Provider`. Mengganti data dummy
///   dengan API cukup dilakukan di sini, tanpa menyentuh ViewModel atau View.
/// - ViewModel yang dipakai banyak layar (`AuthViewModel`, `BookingViewModel`,
///   `VisitStatusViewModel`) disediakan di sini. ViewModel milik satu layar
///   dibuat oleh layarnya sendiri.
/// - Semua parameter repository bersifat opsional supaya test bisa
///   menggantinya dengan data palsu.
class MuseumApp extends StatefulWidget {
  const MuseumApp({
    super.key,
    required this.authViewModel,
    this.homeRepository,
    this.koleksiRepository,
    this.serupaRepository,
    this.visitRepository,
    this.bookingRepository,
    this.linkLauncher,
  });

  final AuthViewModel authViewModel;

  final HomeRepository? homeRepository;
  final KoleksiRepository? koleksiRepository;
  final SerupaRepository? serupaRepository;
  final VisitRepository? visitRepository;
  final BookingRepository? bookingRepository;
  final LinkLauncher? linkLauncher;

  @override
  State<MuseumApp> createState() => _MuseumAppState();
}

class _MuseumAppState extends State<MuseumApp> {
  late final GoRouter _router = createAppRouter(widget.authViewModel);
  late final KoleksiRepository _koleksiRepository =
      widget.koleksiRepository ?? const DummyKoleksiRepository();
  late final SerupaRepository _serupaRepository =
      widget.serupaRepository ?? AssetSerupaRepository();
  late final VisitRepository _visitRepository = widget.visitRepository ?? InMemoryVisitRepository();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- Service & Repository (lapisan data) ---
        Provider<HomeRepository>.value(value: widget.homeRepository ?? const DummyHomeRepository()),
        Provider<KoleksiRepository>.value(value: _koleksiRepository),
        Provider<SerupaRepository>.value(value: _serupaRepository),
        Provider<VisitRepository>.value(value: _visitRepository),
        Provider<LinkLauncher>.value(value: widget.linkLauncher ?? const UrlLauncherService()),

        // --- ViewModel bersama (lapisan UI) ---
        ChangeNotifierProvider<AuthViewModel>.value(value: widget.authViewModel),
        ChangeNotifierProvider<VisitStatusViewModel>(
          create: (_) => VisitStatusViewModel(repository: _visitRepository),
        ),
        ChangeNotifierProvider<BookingViewModel>(
          create: (_) => BookingViewModel(repository: widget.bookingRepository)..load(),
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
        child: MaterialApp.router(
          title: 'Museum Mpu Purwa',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}
