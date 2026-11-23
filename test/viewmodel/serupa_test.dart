import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:museum_mpupurwa_app/features/collections/model/koleksi_model.dart';
import 'package:museum_mpupurwa_app/features/collections/model/koleksi_serupa.dart';
import 'package:museum_mpupurwa_app/features/collections/repository/json_koleksi_repository.dart';
import 'package:museum_mpupurwa_app/features/collections/repository/koleksi_repository.dart';
import 'package:museum_mpupurwa_app/features/collections/repository/serupa_repository.dart';
import 'package:museum_mpupurwa_app/features/collections/viewmodel/koleksi_serupa_view_model.dart';

Koleksi _k(String id, String nama) => Koleksi(
  id: id,
  nama: nama,
  era: 'X',
  asal: '',
  periode: '',
  material: '',
  sejarah: '',
  fotoUrl: '',
);

class _FakeKoleksi implements KoleksiRepository {
  _FakeKoleksi({this.fail = false});
  final bool fail;

  @override
  Future<List<Koleksi>> fetchAll() async {
    if (fail) throw Exception('gagal');
    return [_k('1', 'Ganesya'), _k('2', 'Brahma'), _k('3', 'Siwa')];
  }
}

class _FakeSerupa implements SerupaRepository {
  _FakeSerupa(this.data);
  final Map<String, List<KoleksiSerupa>> data;

  @override
  Future<List<KoleksiSerupa>> ambil(String koleksiId) async => data[koleksiId] ?? const [];
}

void main() {
  dataAsetTest();

  group('JsonKoleksiRepository.parse', () {
    test('membaca daftar koleksi dan mengabaikan elemen yang bukan objek', () {
      final hasil = JsonKoleksiRepository.parse(
        '[{"id":"1","nama":"Arca A","era":"SINGOSARI","fotoUrl":"assets/images/a.jpg","pdfUrl":"https://x/p.pdf"}, 5]',
      );
      expect(hasil, hasLength(1));
      expect(hasil.first.nama, 'Arca A');
      expect(hasil.first.pdfUrl, 'https://x/p.pdf');
    });

    test('isi bukan daftar ditolak', () {
      expect(() => JsonKoleksiRepository.parse('{"a":1}'), throwsFormatException);
    });
  });

  group('AssetSerupaRepository.parse', () {
    test('membaca id dan skor per arca', () {
      final peta = AssetSerupaRepository.parse(
        '{"model":"tfidf","serupa":{"1":[{"id":"2","skor":0.5},{"id":"3","skor":0.25}]}}',
      );
      expect(peta['1']!.map((e) => e.id), ['2', '3']);
      expect(peta['1']!.first.skor, 0.5);
    });

    test('tanpa kunci serupa ditolak', () {
      expect(() => AssetSerupaRepository.parse('{"model":"x"}'), throwsFormatException);
    });
  });

  group('KoleksiSerupaViewModel', () {
    test('menggabungkan rekomendasi dengan data arca dan menyusun label persen', () async {
      final vm = KoleksiSerupaViewModel(
        _FakeKoleksi(),
        _FakeSerupa({
          '1': [const KoleksiSerupa(id: '2', skor: 0.424), const KoleksiSerupa(id: '3', skor: 0.1)],
        }),
        koleksiId: '1',
      );
      await vm.load();

      expect(vm.items.map((e) => e.koleksi.nama), ['Brahma', 'Siwa']);
      expect(vm.items.first.label, '42% mirip');
      expect(vm.isLoading, isFalse);
    });

    test('id yang tidak ada di koleksi dan arca itu sendiri dilewati', () async {
      final vm = KoleksiSerupaViewModel(
        _FakeKoleksi(),
        _FakeSerupa({
          '1': [
            const KoleksiSerupa(id: '1', skor: 1),
            const KoleksiSerupa(id: '99', skor: 0.9),
            const KoleksiSerupa(id: '2', skor: 0.3),
          ],
        }),
        koleksiId: '1',
      );
      await vm.load();
      expect(vm.items.map((e) => e.koleksi.id), ['2']);
    });

    test('gagal memuat membuat daftar kosong, bukan error', () async {
      final vm = KoleksiSerupaViewModel(_FakeKoleksi(fail: true), _FakeSerupa({}), koleksiId: '1');
      await vm.load();
      expect(vm.items, isEmpty);
    });
  });
}

/// Menjaga berkas data di assets/data/ tetap konsisten, terutama setelah
/// menambah arca atau menjalankan ulang `ml/build_serupa.py`.
void dataAsetTest() {
  group('berkas data di assets/data/', () {
    final koleksi = JsonKoleksiRepository.parse(
      File('assets/data/koleksi.json').readAsStringSync(),
    );
    final serupa = AssetSerupaRepository.parse(
      File('assets/data/koleksi_serupa.json').readAsStringSync(),
    );

    test('id koleksi unik dan foto lokal benar-benar ada', () {
      final ids = koleksi.map((k) => k.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final k in koleksi.where((k) => k.fotoUrl.startsWith('assets/'))) {
        expect(File(k.fotoUrl).existsSync(), isTrue, reason: 'foto ${k.fotoUrl} tidak ditemukan');
      }
    });

    test('setiap arca punya rekomendasi dan semua id rujukan ada di koleksi', () {
      final ids = koleksi.map((k) => k.id).toSet();
      for (final id in ids) {
        expect(
          serupa[id],
          isNotNull,
          reason: 'arca $id belum punya rekomendasi, jalankan ml/build_serupa.py',
        );
        for (final r in serupa[id]!) {
          expect(ids.contains(r.id), isTrue, reason: 'id ${r.id} tidak ada di koleksi.json');
          expect(r.id, isNot(id));
          expect(r.skor, inInclusiveRange(0, 1));
        }
      }
    });
  });
}
