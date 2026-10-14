import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/section_head.dart';
import 'data/home_models.dart';
import 'data/home_repository.dart';
import 'widgets/era_timeline.dart';
import 'widgets/featured_collections.dart';
import 'widgets/home_hero.dart';
import 'widgets/hours_info_bar.dart';
import 'widgets/quick_access_grid.dart';
import 'widgets/visit_banner.dart';

/// Layar Beranda (`screen-beranda`).
class BerandaPage extends StatefulWidget {
  /// [clock] dipisah supaya info jam buka bisa diuji untuk hari buka dan tutup.
  const BerandaPage({super.key, this.clock = DateTime.now});

  final DateTime Function() clock;

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  late Future<HomeContent> _content;

  @override
  void initState() {
    super.initState();
    _content = context.read<HomeRepository>().loadContent();
  }

  void _reload() {
    setState(() => _content = context.read<HomeRepository>().loadContent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<HomeContent>(
          future: _content,
          builder: (context, snapshot) {
            if (snapshot.hasError) return _ErrorView(onRetry: _reload);
            final content = snapshot.data;
            if (content == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.amber));
            }
            return _BerandaContent(content: content, now: widget.clock());
          },
        ),
      ),
    );
  }
}

class _BerandaContent extends StatelessWidget {
  const _BerandaContent({required this.content, required this.now});

  final HomeContent content;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BerandaTopBar(),
          const Padding(
            padding: EdgeInsets.fromLTRB(AppDimens.gutter, 0, AppDimens.gutter, 14),
            child: VisitBanner(),
          ),
          HomeHero(onExplore: () => context.go(AppRoutes.katalog)),
          const SizedBox(height: 24),
          SectionHead(
            title: 'Koleksi Unggulan',
            actionLabel: 'Lihat semua',
            bottomSpacing: 26,
            onAction: () => context.go(AppRoutes.katalog),
          ),
          FeaturedCollections(
            items: content.featured,
            onOpen: (id) => context.go(AppRoutes.koleksiDetail(id)),
          ),
          const SizedBox(height: 4),
          const SectionHead(title: 'Linimasa Sejarah Nusantara', bottomSpacing: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppDimens.gutter, 0, AppDimens.gutter, 2),
            child: Text(
              'Ketuk masa kerajaan untuk melihat konteks sejarahnya.',
              style: AppTextStyles.sans(12, color: AppColors.inkSoft, height: 1.5),
            ),
          ),
          EraTimeline(
            eras: content.eras,
            onOpenCollection: (era) => context.go(AppRoutes.katalogDenganEra(era)),
          ),
          const SectionHead(title: 'Akses Cepat'),
          QuickAccessGrid(
            items: [
              QuickAccessItem(
                icon: Icons.museum_outlined,
                title: 'Info Kunjungan',
                subtitle: 'Jam buka, lokasi & kontak',
                onTap: () => context.go(AppRoutes.info),
              ),
              QuickAccessItem(
                icon: Icons.calendar_today_outlined,
                title: 'Booking Rombongan',
                subtitle: 'Kunjungan kelompok/sekolah',
                onTap: () => context.go(AppRoutes.booking),
              ),
              QuickAccessItem(
                icon: Icons.person_outline,
                title: 'Riwayat Kunjungan',
                subtitle: 'Lihat catatan kunjunganmu',
                onTap: () => context.go(AppRoutes.profil),
              ),
              QuickAccessItem(
                icon: Icons.grid_view_outlined,
                title: 'Katalog Koleksi',
                subtitle: '129 arca & prasasti',
                onTap: () => context.go(AppRoutes.katalog),
              ),
            ],
          ),
          const SizedBox(height: 26),
          HoursInfoBar(now: now),
        ],
      ),
    );
  }
}

/// Bar atas Beranda: merek "Mpu Purwa" di kiri, ikon cari dan profil di kanan.
class _BerandaTopBar extends StatelessWidget {
  const _BerandaTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.gutter, 20, AppDimens.gutter, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
                  size: 16,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(width: 9),
              Text('Mpu Purwa', style: AppTextStyles.brandName),
            ],
          ),
          Row(
            children: [
              CircleIconButton(
                icon: Icons.search,
                tooltip: 'Cari koleksi',
                onPressed: () => context.go(AppRoutes.katalog),
              ),
              const SizedBox(width: 8),
              CircleIconButton(
                icon: Icons.person_outline,
                tooltip: 'Profil',
                onPressed: () => context.go(AppRoutes.profil),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.gutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Beranda gagal dimuat.', style: AppTextStyles.bodySoft),
            const SizedBox(height: 12),
            AppButton.secondary(label: 'Coba lagi', expanded: false, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
