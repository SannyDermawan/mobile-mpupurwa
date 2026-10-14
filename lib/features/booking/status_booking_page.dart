import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_top_bar.dart';
import 'booking_controller.dart';
import 'booking_model.dart';
import 'detail_row.dart';
import 'tanggal_format.dart';

/// Layar "Status Booking" (rute /status-booking): status, rincian, dan riwayat
/// pengajuan booking rombongan. Kosong sampai pengguna mengirim pengajuan dari
/// layar Booking Rombongan.
// TODO(backend): muat daftar pengajuan dan statusnya dari server.
class StatusBookingPage extends StatelessWidget {
  const StatusBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<BookingController>().requests;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTopBar(
                title: 'Status Booking',
                titleSize: 17,
                fallbackRoute: AppRoutes.booking,
              ),
              if (requests.isEmpty) const _EmptyState() else _BookingContent(requests: requests),
            ],
          ),
        ),
      ),
    );
  }
}

/// Isi layar saat sudah ada pengajuan. [requests] urut dari yang terbaru.
class _BookingContent extends StatelessWidget {
  const _BookingContent({required this.requests});

  final List<BookingRequest> requests;

  @override
  Widget build(BuildContext context) {
    final latest = requests.first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.gutter, 4, AppDimens.gutter, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusCard(request: latest),
          const SizedBox(height: 16),
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader(icon: Icons.assignment_outlined, title: 'Informasi Pengajuan'),
                DetailRow(label: 'Instansi', value: latest.institution),
                DetailRow(label: 'Penanggung Jawab', value: latest.contactName),
                DetailRow(
                  label: 'Tanggal Kunjungan',
                  value: formatTanggalLengkap(latest.visitDate),
                ),
                DetailRow(label: 'Jumlah Peserta', value: '${latest.participants} peserta'),
                DetailRow(label: 'Nomor HP', value: latest.phone),
                DetailRow(
                  label: 'Catatan',
                  value: latest.notes.isEmpty ? '-' : latest.notes,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader(icon: Icons.history, title: 'Riwayat Pengajuan'),
                for (var i = 0; i < requests.length; i++)
                  _HistoryItem(request: requests[i], isLast: i == requests.length - 1),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InfoBar(
            icon: Icons.info_outline,
            margin: EdgeInsets.zero,
            message: TextSpan(
              children: [
                TextSpan(text: 'Mode demo.', style: InfoBar.boldStyle),
                const TextSpan(
                  text:
                      ' Pengajuan hanya tersimpan sementara di aplikasi ini dan belum dikirim '
                      'ke museum.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton.secondary(
            label: 'Ajukan Booking Lagi',
            icon: Icons.add,
            onPressed: () => context.go(AppRoutes.booking),
          ),
        ],
      ),
    );
  }
}

/// Kartu status pengajuan terbaru (`.status-card`).
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.request});

  final BookingRequest request;

  String get _message => switch (request.status) {
    BookingStatus.menungguKonfirmasi => 'Pengajuanmu sedang menunggu konfirmasi dari pihak museum.',
    BookingStatus.dikonfirmasi => 'Pengajuanmu sudah dikonfirmasi oleh pihak museum.',
    BookingStatus.ditolak => 'Pengajuanmu belum dapat diterima. Silakan hubungi pihak museum.',
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.stoneLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STATUS PENGAJUAN',
              style: AppTextStyles.eyebrow.copyWith(color: AppColors.goldDeep),
            ),
            const SizedBox(height: 10),
            _StatusBadge(status: request.status),
            const SizedBox(height: 14),
            Text(request.institution, style: AppTextStyles.serif(19, height: 1.25)),
            const SizedBox(height: 4),
            Text(
              '${formatTanggalLengkap(request.visitDate)} · ${request.participants} peserta',
              style: AppTextStyles.sans(12.5, color: AppColors.stoneDark),
            ),
            const SizedBox(height: 12),
            Text(_message, style: AppTextStyles.bodySoft),
            const SizedBox(height: 6),
            Text(
              'Diajukan pada ${formatTanggalLengkap(request.submittedAt)}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

/// Label status berbentuk pil, mis. "Menunggu Konfirmasi".
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, this.compact = false});

  final BookingStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color background, Color foreground, Color iconColor) = switch (status) {
      BookingStatus.menungguKonfirmasi => (
        Icons.hourglass_top_rounded,
        AppColors.amber.withValues(alpha: 0.25),
        AppColors.stoneDark,
        AppColors.goldDeep,
      ),
      BookingStatus.dikonfirmasi => (
        Icons.check_circle_outline,
        AppColors.charcoal,
        AppColors.cream,
        AppColors.amber,
      ),
      BookingStatus.ditolak => (
        Icons.cancel_outlined,
        AppColors.error.withValues(alpha: 0.10),
        AppColors.error,
        AppColors.error,
      ),
    };

    final fontSize = compact ? 10.5 : 12.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 9 : 12, vertical: compact ? 4 : 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 12 : 15, color: iconColor),
            SizedBox(width: compact ? 4 : 6),
            Text(
              status.label,
              style: AppTextStyles.sans(fontSize, weight: FontWeight.w700, color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu baris di Riwayat Pengajuan.
class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.request, required this.isLast});

  final BookingRequest request;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.stoneLine)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: isLast ? 0 : 10),
        // Lencana di bawah teks, bukan di sampingnya, supaya nama instansi dan
        // tanggal tidak terjepit di layar sempit.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.institution,
              style: AppTextStyles.sans(13, weight: FontWeight.w600, color: AppColors.stoneDark),
            ),
            const SizedBox(height: 2),
            Text(
              'Kunjungan ${formatTanggalSingkat(request.visitDate)} · '
              '${request.participants} peserta',
              style: AppTextStyles.caption,
            ),
            Text(
              'Diajukan ${formatTanggalSingkat(request.submittedAt)}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 8),
            _StatusBadge(status: request.status, compact: true),
          ],
        ),
      ),
    );
  }
}

/// Tampilan saat belum ada pengajuan sama sekali.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.gutter, 36, AppDimens.gutter, 24),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sandLight,
              border: Border.all(color: AppColors.sandLightBorder),
            ),
            child: const Icon(Icons.event_note_outlined, size: 42, color: AppColors.amber),
          ),
          const SizedBox(height: 22),
          Text(
            'Belum ada pengajuan booking',
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 8),
          Text(
            'Pengajuan kunjungan rombonganmu akan muncul di sini beserta statusnya.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySoft,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Ajukan Booking Rombongan',
            icon: Icons.add,
            onPressed: () => context.go(AppRoutes.booking),
          ),
        ],
      ),
    );
  }
}
