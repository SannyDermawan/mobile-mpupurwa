import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:museum_mpupurwa_app/core/services/link_launcher.dart';
import 'package:museum_mpupurwa_app/features/collections/model/koleksi_model.dart';
import 'package:museum_mpupurwa_app/features/collections/model/koleksi_serupa.dart';
import 'package:museum_mpupurwa_app/features/collections/repository/koleksi_repository.dart';
import 'package:museum_mpupurwa_app/features/collections/repository/serupa_repository.dart';
import 'package:museum_mpupurwa_app/features/collections/view/koleksi_detail_page.dart';
import 'package:provider/provider.dart';

Koleksi _k(String id, String nama) => Koleksi(
  id: id,
  nama: nama,
  era: 'SINGOSARI',
  asal: 'Malang',
  periode: 'Abad 13',
  material: 'Batu',
  sejarah: 'Penjelasan $nama.',
  fotoUrl: '',
);

class _Koleksi implements KoleksiRepository {
  @override
  Future<List<Koleksi>> fetchAll() async => [_k('1', 'Arca Satu'), _k('2', 'Arca Dua')];
}

class _Serupa implements SerupaRepository {
  @override
  Future<List<KoleksiSerupa>> ambil(String koleksiId) async =>
      koleksiId == '1' ? const [KoleksiSerupa(id: '2', skor: 0.61)] : const [];
}

class _Launcher implements LinkLauncher {
  @override
  Future<bool> open(String url) async => true;
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpDetail(WidgetTester tester, Koleksi k) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<LinkLauncher>.value(value: _Launcher()),
          Provider<KoleksiRepository>.value(value: _Koleksi()),
          Provider<SerupaRepository>.value(value: _Serupa()),
        ],
        child: MaterialApp(home: KoleksiDetailPage(koleksi: k)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Detail menampilkan koleksi serupa dan membukanya saat diketuk', (tester) async {
    await pumpDetail(tester, _k('1', 'Arca Satu'));

    expect(find.text('Koleksi serupa'), findsOneWidget);
    expect(find.text('61% mirip'), findsOneWidget);
    expect(find.text('Arca Dua'), findsOneWidget);

    await tester.ensureVisible(find.text('Arca Dua'));
    await tester.tap(find.text('Arca Dua'));
    await tester.pumpAndSettle();

    // Detail arca kedua terbuka; arca itu belum punya rekomendasi.
    expect(find.text('Penjelasan Arca Dua.'), findsOneWidget);
    expect(find.text('Koleksi serupa'), findsNothing);
  });

  testWidgets('Detail tanpa rekomendasi tidak menampilkan bagian serupa', (tester) async {
    await pumpDetail(tester, _k('2', 'Arca Dua'));
    expect(find.text('Koleksi serupa'), findsNothing);
  });
}
