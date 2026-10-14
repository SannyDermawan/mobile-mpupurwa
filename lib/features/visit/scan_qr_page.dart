import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/state/visit_status_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_top_bar.dart';

/// Layar "Konfirmasi Kunjungan" (rute /scan-qr): pengunjung memindai QR di
/// museum untuk mencatat kunjungan hari ini.
///
/// **Kamera belum berfungsi.** Aplikasi belum memakai paket kamera/pemindai QR
/// dan izin kamera belum ada di `AndroidManifest`, jadi area di bawah hanya
/// kerangka tampilan. Tombol "Scan QR Sekarang" menjelaskan hal itu dan
/// menawarkan simulasi supaya alur sesudahnya (Kunjungan Tercatat, banner
/// Beranda) tetap bisa dicoba.
// TODO(backend): ganti simulasi dengan pemindai QR sungguhan dan kirim
// hasilnya ke server sebelum memanggil markVisitRecorded().
class ScanQrPage extends StatelessWidget {
  const ScanQrPage({super.key});

  Future<void> _onScanPressed(BuildContext context) async {
    final simulate = await showDialog<bool>(
      context: context,
      builder: (_) => const _CameraUnavailableDialog(),
    );
    if (simulate != true || !context.mounted) return;
    context.read<VisitStatusController>().markVisitRecorded();
    context.go(AppRoutes.kunjunganTercatat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTopBar(
                title: 'Konfirmasi Kunjungan',
                titleSize: 17,
                fallbackRoute: AppRoutes.beranda,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppDimens.gutter, 8, AppDimens.gutter, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'CATAT KUNJUNGAN',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.eyebrow,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Scan QR di pintu masuk',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.authTitle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Arahkan kamera ke kode QR di museum untuk mencatat kunjunganmu hari ini.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySoft,
                    ),
                    const SizedBox(height: 24),
                    const _Viewfinder(),
                    const SizedBox(height: 18),
                    InfoBar(
                      icon: Icons.info_outline,
                      margin: EdgeInsets.zero,
                      message: TextSpan(
                        children: [
                          TextSpan(text: 'Kamera belum berfungsi.', style: InfoBar.boldStyle),
                          const TextSpan(
                            text:
                                ' Tampilan ini masih berupa kerangka, pemindai QR akan '
                                'diaktifkan pada pembaruan berikutnya.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppButton(
                      label: 'Scan QR Sekarang',
                      icon: Icons.qr_code_scanner,
                      onPressed: () => _onScanPressed(context),
                    ),
                    const SizedBox(height: 24),
                    const _HowToCard(),
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

/// Kerangka area kamera: kotak gelap dengan sudut emas dan garis pindai.
/// Tidak ada kamera di dalamnya, jadi diberi label "Kamera belum aktif".
class _Viewfinder extends StatelessWidget {
  const _Viewfinder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: AspectRatio(
          aspectRatio: 1,
          child: Semantics(
            container: true,
            excludeSemantics: true,
            label: 'Area pemindaian QR. Kamera belum aktif.',
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.onDarkLine.withValues(alpha: 0.15)),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.artStart, AppColors.artEnd],
                ),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(child: CustomPaint(painter: _CornerBracketsPainter())),
                  Center(
                    child: Icon(
                      Icons.qr_code_2,
                      size: 112,
                      color: AppColors.onDarkLine.withValues(alpha: 0.10),
                    ),
                  ),
                  const Align(
                    alignment: Alignment(0, -0.1),
                    child: FractionallySizedBox(widthFactor: 0.72, child: _ScanLine()),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.videocam_off_outlined,
                                size: 14,
                                color: AppColors.onDarkMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Kamera belum aktif',
                                style: AppTextStyles.sans(11.5, color: AppColors.onDarkMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Garis pindai emas yang memudar di kedua ujung. Diam, tanpa animasi.
class _ScanLine extends StatelessWidget {
  const _ScanLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.amber.withValues(alpha: 0),
            AppColors.amber,
            AppColors.amber.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

/// Empat sudut berbentuk siku di sekeliling area pindai.
class _CornerBracketsPainter extends CustomPainter {
  const _CornerBracketsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 26.0;
    const arm = 30.0;
    const r = 10.0;
    final paint = Paint()
      ..color = AppColors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final l = inset;
    final t = inset;
    final rt = size.width - inset;
    final b = size.height - inset;

    final path = Path()
      // kiri atas
      ..moveTo(l, t + arm)
      ..lineTo(l, t + r)
      ..quadraticBezierTo(l, t, l + r, t)
      ..lineTo(l + arm, t)
      // kanan atas
      ..moveTo(rt - arm, t)
      ..lineTo(rt - r, t)
      ..quadraticBezierTo(rt, t, rt, t + r)
      ..lineTo(rt, t + arm)
      // kanan bawah
      ..moveTo(rt, b - arm)
      ..lineTo(rt, b - r)
      ..quadraticBezierTo(rt, b, rt - r, b)
      ..lineTo(rt - arm, b)
      // kiri bawah
      ..moveTo(l + arm, b)
      ..lineTo(l + r, b)
      ..quadraticBezierTo(l, b, l, b - r)
      ..lineTo(l, b - arm);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Kartu langkah-langkah mencatat kunjungan.
class _HowToCard extends StatelessWidget {
  const _HowToCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(icon: Icons.route_outlined, title: 'Cara Mencatat Kunjungan'),
          _Step(number: 1, text: 'Cari kode QR di pintu masuk museum.'),
          _Step(number: 2, text: 'Tekan "Scan QR Sekarang", lalu arahkan kamera ke kode QR.'),
          _Step(number: 3, text: 'Kunjunganmu hari ini otomatis tercatat.', isLast: true),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text, this.isLast = false});

  final int number;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.amber.withValues(alpha: 0.18),
            ),
            child: Text(
              '$number',
              style: AppTextStyles.sans(11.5, weight: FontWeight.w700, color: AppColors.goldDeep),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text, style: AppTextStyles.bodySoft),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog penjelasan bahwa kamera belum berfungsi. Mengembalikan `true` kalau
/// pengunjung memilih simulasi, `false` atau `null` kalau menutup.
class _CameraUnavailableDialog extends StatelessWidget {
  const _CameraUnavailableDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.offwhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        side: const BorderSide(color: AppColors.stoneLine),
      ),
      icon: const Icon(Icons.videocam_off_outlined, color: AppColors.amber, size: 28),
      title: Text(
        'Kamera belum berfungsi',
        textAlign: TextAlign.center,
        style: AppTextStyles.serif(17),
      ),
      content: Text(
        'Pemindai QR belum terpasang di aplikasi ini, jadi kunjungan belum bisa dicatat lewat '
        'kamera.\n\nUntuk mencoba alur berikutnya, kamu bisa memakai simulasi: kunjungan '
        'ditandai tercatat tanpa memindai kode.',
        style: AppTextStyles.bodySoft,
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Tutup')),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Simulasikan Scan (Demo)'),
        ),
      ],
    );
  }
}
