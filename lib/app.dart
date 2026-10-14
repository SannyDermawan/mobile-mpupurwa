import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/state/auth_controller.dart';
import 'core/state/visit_status_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/home/data/home_repository.dart';

/// Akar aplikasi: menyediakan state dan repository bersama, lalu memasang router.
///
/// Repository dummy disediakan lewat `Provider<HomeRepository>`; ganti dengan
/// implementasi API di sini nanti tanpa mengubah layar.
class MuseumApp extends StatefulWidget {
  const MuseumApp({super.key, required this.authController, this.homeRepository});

  final AuthController authController;

  /// Diisi di test untuk mengganti data Beranda; default memakai data dummy.
  final HomeRepository? homeRepository;

  @override
  State<MuseumApp> createState() => _MuseumAppState();
}

class _MuseumAppState extends State<MuseumApp> {
  late final GoRouter _router = createAppRouter(widget.authController);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: widget.authController),
        ChangeNotifierProvider<VisitStatusController>(create: (_) => VisitStatusController()),
        Provider<HomeRepository>.value(value: widget.homeRepository ?? const DummyHomeRepository()),
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
