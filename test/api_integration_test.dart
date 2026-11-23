import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:museum_mpupurwa_app/core/network/api_client.dart';
import 'package:museum_mpupurwa_app/core/storage/session_storage.dart';
import 'package:museum_mpupurwa_app/features/auth/model/visitor_profile.dart';
import 'package:museum_mpupurwa_app/features/booking/model/booking_model.dart';
import 'package:museum_mpupurwa_app/features/booking/repository/api_booking_repository.dart';
import 'package:museum_mpupurwa_app/features/booking/viewmodel/booking_view_model.dart';
import 'package:museum_mpupurwa_app/features/collections/model/koleksi_model.dart';
import 'package:museum_mpupurwa_app/features/collections/repository/api_koleksi_repository.dart';
import 'package:museum_mpupurwa_app/features/collections/repository/koleksi_repository.dart';
import 'package:museum_mpupurwa_app/features/collections/viewmodel/katalog_view_model.dart';
import 'package:museum_mpupurwa_app/features/home/repository/home_repository.dart';
import 'package:museum_mpupurwa_app/features/visit/repository/api_visit_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test integrasi dengan Web Admin tanpa jaringan: respons server ditiru
/// memakai MockClient, bentuknya sama dengan `/api/public/...` di backend.

/// Balasan palsu bentuk `{ success, data | message }`, sama dengan `/api/public/...`.
class _Resp {
  _Resp(Object data, {this.status = 200})
    : body = {'success': status < 400, if (status < 400) 'data': data else 'message': data};
  final int status;
  final Map<String, Object?> body;
}

class _Request {
  _Request(this.url, this.body);
  final Uri url;
  final String body;
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);
  final Future<Object> Function(_Request) handler; // _Resp, atau string mentah

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final data = options.data == null ? '' : jsonEncode(options.data);
    final hasil = await handler(_Request(options.uri, data));
    final headers = {
      Headers.contentTypeHeader: ['application/json; charset=utf-8'],
    };
    if (hasil is _Resp)
      return ResponseBody.fromString(jsonEncode(hasil.body), hasil.status, headers: headers);
    return ResponseBody.fromString(hasil as String, 502, headers: headers);
  }

  @override
  void close({bool force = false}) {}
}

Koleksi _lokal(
  String id,
  String nama, {
  String foto = 'assets/images/x.jpg',
  String era = 'SINGOSARI',
}) => Koleksi(
  id: id,
  nama: nama,
  era: era,
  asal: '',
  periode: '',
  material: '',
  sejarah: '',
  fotoUrl: foto,
);

class _Bawaan implements KoleksiRepository {
  _Bawaan(this.data);
  final List<Koleksi> data;
  @override
  Future<List<Koleksi>> fetchAll() async => data;
}

ApiClient _client(Future<Object> Function(_Request) handler) {
  final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
    ..httpClientAdapter = _FakeAdapter(handler);
  return ApiClient(dio: dio);
}

class SocketLikeError implements Exception {
  const SocketLikeError();
}

void main() {
  group('ApiClient', () {
    test('membuka amplop success dan mengembalikan data', () async {
      final c = _client((_) async => _Resp([1, 2]));
      expect(await c.getJson('/api/public/collections'), [1, 2]);
    });

    test('pesan server dilempar sebagai ApiException', () async {
      final c = _client((_) async => _Resp('Nomor HP tidak valid.', status: 400));
      expect(
        () => c.postJson('/api/public/bookings', {}),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Nomor HP tidak valid.')),
      );
    });

    test('tanpa koneksi dan balasan bukan JSON menjadi ApiException', () async {
      final mati = _client((_) async => throw const SocketLikeError());
      expect(() => mati.getJson('/x'), throwsA(isA<ApiException>()));
      final rusak = _client((_) async => '<html>');
      expect(() => rusak.getJson('/x'), throwsA(isA<ApiException>()));
    });
  });

  group('ApiKoleksiRepository', () {
    final bawaan = [_lokal('brahma', 'Arca Brahma', foto: 'assets/images/arca_brahma.jpg')];

    test('memakai id dan foto bawaan bila nama cocok dan admin belum unggah foto', () {
      final hasil = ApiKoleksiRepository.parse([
        {
          'id': 41,
          'name': 'Arca Brahma',
          'era': 'Singosari',
          'period': '±820 tahun',
          'photoUrl': null,
          'videoUrl': '',
          'pdfUrl': 'https://x/p.pdf',
        },
        {'id': 42, 'name': 'Arca Baru', 'era': 'Tumapel', 'photoUrl': 'https://blob/foto.png'},
      ], bawaan);
      expect(hasil[0].id, 'brahma'); // kunci rekomendasi "Koleksi serupa"
      expect(hasil[0].fotoUrl, 'assets/images/arca_brahma.jpg');
      expect(hasil[0].videoUrl, isNull);
      expect(hasil[0].pdfUrl, 'https://x/p.pdf');
      expect(hasil[1].id, '42');
      expect(hasil[1].fotoUrl, 'https://blob/foto.png');
    });

    test('server mati: memakai data bawaan', () async {
      final repo = ApiKoleksiRepository(
        _client((_) async => throw Exception('mati')),
        fallback: _Bawaan(bawaan),
      );
      expect((await repo.fetchAll()).single.id, 'brahma');
    });

    test('server kosong: memakai data bawaan; server berisi: memakai server', () async {
      final kosong = ApiKoleksiRepository(
        _client((_) async => _Resp([])),
        fallback: _Bawaan(bawaan),
      );
      expect((await kosong.fetchAll()).single.id, 'brahma');
      final isi = ApiKoleksiRepository(
        _client(
          (_) async => _Resp([
            {'id': 7, 'name': 'Arca X', 'era': 'Singosari'},
          ]),
        ),
        fallback: _Bawaan(bawaan),
      );
      expect((await isi.fetchAll()).single.nama, 'Arca X');
    });
  });

  group('ApiBookingRepository', () {
    late SessionStorage storage;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = SessionStorage(await SharedPreferences.getInstance());
    });

    final request = BookingRequest(
      institution: 'SMAN 1',
      contactName: 'Ibu Sari',
      visitDate: DateTime(2030, 1, 10),
      participants: 30,
      phone: '081234567890',
      submittedAt: DateTime(2026, 11, 23),
      notes: 'tes',
    );

    test('save mengirim isian lalu menyimpan id dari server', () async {
      late Map<String, dynamic> terkirim;
      final repo = ApiBookingRepository(
        _client((r) async {
          terkirim = jsonDecode(r.body) as Map<String, dynamic>;
          return _Resp({'id': 'bk-aaaaaaaaaaaa'}, status: 201);
        }),
        storage,
      );
      await repo.save(request);
      expect(terkirim['visitDate'], '2030-01-10');
      expect(terkirim['participants'], 30);
      expect(storage.bookingIds, ['bk-aaaaaaaaaaaa']);
    });

    test('fetchAll membaca status dari server dan memetakannya', () async {
      await storage.addBookingId('bk-aaaaaaaaaaaa');
      late Uri diminta;
      final repo = ApiBookingRepository(
        _client((r) async {
          diminta = r.url;
          return _Resp([
            {
              'id': 'bk-aaaaaaaaaaaa',
              'institution': 'SMAN 1',
              'contactName': 'Ibu',
              'phone': '08',
              'visitDate': '2030-01-10',
              'participants': 30,
              'notes': '',
              'status': 'confirmed',
              'submittedAt': '2026-11-23T10:00:00.000Z',
            },
          ]);
        }),
        storage,
      );
      final hasil = await repo.fetchAll();
      expect(diminta.queryParameters['ids'], 'bk-aaaaaaaaaaaa');
      expect(hasil.single.status, BookingStatus.dikonfirmasi);
    });

    test('tanpa id tersimpan tidak memanggil server', () async {
      final repo = ApiBookingRepository(
        _client((_) async => throw StateError('tidak boleh dipanggil')),
        storage,
      );
      expect(await repo.fetchAll(), isEmpty);
    });

    test(
      'pengiriman gagal: pengajuan dikeluarkan lagi dari daftar dan kesalahan dilempar',
      () async {
        final repo = ApiBookingRepository(
          _client((_) async => _Resp('Nomor HP tidak valid.', status: 400)),
          storage,
        );
        final vm = BookingViewModel(repository: repo);
        await expectLater(vm.submit(request), throwsA(isA<ApiException>()));
        expect(vm.requests, isEmpty);
        expect(storage.bookingIds, isEmpty);
      },
    );
  });

  group('ApiVisitRepository', () {
    const profil = VisitorProfile(
      name: 'Amanda',
      educationLevel: 'Dosen',
      domicile: 'Malang',
      institution: '',
      phone: '',
      email: '',
    );

    test('mengirim identitas profil; jenjang tak dikenal menjadi Umum', () async {
      Map<String, dynamic>? terkirim;
      final repo = ApiVisitRepository(
        _client((r) async {
          terkirim = jsonDecode(r.body) as Map<String, dynamic>;
          return _Resp({'id': 'VIS-1', 'alreadyRecorded': false}, status: 201);
        }),
        profile: () => profil,
      );
      await repo.recordToday();
      expect(repo.recordedToday, isTrue);
      expect(terkirim, {
        'name': 'Amanda',
        'domicile': 'Malang',
        'institution': '',
        'educationLevel': 'Umum',
      });
    });

    test('gagal terkirim tetap tercatat lokal; tanpa login tidak mengirim', () async {
      final gagal = ApiVisitRepository(
        _client((_) async => throw Exception('mati')),
        profile: () => profil,
      );
      await gagal.recordToday();
      expect(gagal.recordedToday, isTrue);

      final anonim = ApiVisitRepository(
        _client((_) async => throw StateError('tidak boleh')),
        profile: () => null,
      );
      await anonim.recordToday();
      expect(anonim.recordedToday, isTrue);
    });
  });

  group('KoleksiHomeRepository', () {
    test('unggulan berfoto dan berbeda era; jumlah koleksi dari data', () async {
      final repo = KoleksiHomeRepository(
        _Bawaan([
          _lokal('a', 'A', era: 'SINGOSARI'),
          _lokal('b', 'B', era: 'SINGOSARI'),
          _lokal('c', 'C', era: 'TUMAPEL'),
          _lokal('d', 'D', foto: '', era: 'KANJURUHAN'),
          _lokal('e', 'E', era: 'KANJURUHAN'),
        ]),
      );
      final isi = await repo.loadContent();
      expect(isi.totalKoleksi, 5);
      expect(isi.featured.map((f) => f.id), ['a', 'c', 'e']);
      expect(isi.featured.first.eraLabel, 'Singosari');
      expect(isi.eras, isNotEmpty); // linimasa tetap dari data dasar
    });
  });

  test('Katalog: chip era hanya untuk era yang punya koleksi', () async {
    final vm = KatalogViewModel(
      _Bawaan([_lokal('a', 'A', era: 'SINGOSARI'), _lokal('c', 'C', era: 'TUMAPEL')]),
    );
    expect(vm.eraOptions, contains('Majapahit')); // sebelum dimuat: semua era
    await vm.load();
    expect(vm.eraOptions, ['Semua', 'Tumapel', 'Singosari']);
  });
}
