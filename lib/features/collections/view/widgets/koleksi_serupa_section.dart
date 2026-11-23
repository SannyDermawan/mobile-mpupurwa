import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/koleksi_model.dart';
import '../../model/koleksi_serupa.dart';
import '../../repository/koleksi_repository.dart';
import '../../repository/serupa_repository.dart';
import '../../viewmodel/koleksi_serupa_view_model.dart';
import 'koleksi_image.dart';

/// Bagian "Koleksi serupa" di bawah Detail Koleksi. Daftar arca dan skornya
/// berasal dari model analisis teks (lihat `ml/build_serupa.py`).
///
/// Tidak menampilkan apa pun kalau arca ini belum punya rekomendasi.
class KoleksiSerupaSection extends StatelessWidget {
  const KoleksiSerupaSection({super.key, required this.koleksiId, required this.onOpen});

  final String koleksiId;

  /// Dipanggil saat salah satu kartu diketuk.
  final ValueChanged<Koleksi> onOpen;

  static const Color _gold = Color(0xFFD4A017);
  static const Color _dark = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<KoleksiSerupaViewModel>(
      key: ValueKey(koleksiId),
      create: (context) => KoleksiSerupaViewModel(
        context.read<KoleksiRepository>(),
        context.read<SerupaRepository>(),
        koleksiId: koleksiId,
      )..load(),
      child: Consumer<KoleksiSerupaViewModel>(
        builder: (context, vm, _) {
          if (vm.items.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Koleksi serupa',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dipilih otomatis dari kemiripan isi penjelasannya.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) =>
                      _Kartu(item: vm.items[i], onTap: () => onOpen(vm.items[i].koleksi)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Kartu extends StatelessWidget {
  const _Kartu({required this.item, required this.onTap});

  final KoleksiTerkait item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final koleksi = item.koleksi;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E5DF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: SizedBox(
                  width: double.infinity,
                  child: KoleksiImage(
                    url: koleksi.fotoUrl,
                    fallback: const ColoredBox(
                      color: Color(0xFF1F1F1F),
                      child: Icon(
                        Icons.all_inclusive_outlined,
                        size: 34,
                        color: KoleksiSerupaSection._gold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      color: KoleksiSerupaSection._gold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    koleksi.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: KoleksiSerupaSection._dark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
