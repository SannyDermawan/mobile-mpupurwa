import 'package:flutter_test/flutter_test.dart';
import 'package:museum_mpupurwa_app/core/services/link_launcher.dart';
import 'package:museum_mpupurwa_app/features/auth/model/visitor_profile.dart';
import 'package:museum_mpupurwa_app/features/auth/repository/auth_repository.dart';
import 'package:museum_mpupurwa_app/features/auth/viewmodel/auth_view_model.dart';
import 'package:museum_mpupurwa_app/features/auth/viewmodel/otp_view_model.dart';
import 'package:museum_mpupurwa_app/features/auth/viewmodel/register_view_model.dart';
import 'package:museum_mpupurwa_app/features/booking/viewmodel/booking_view_model.dart';
import 'package:museum_mpupurwa_app/features/collections/model/koleksi_model.dart';
import 'package:museum_mpupurwa_app/features/collections/repository/koleksi_repository.dart';
import 'package:museum_mpupurwa_app/features/collections/viewmodel/katalog_view_model.dart';
import 'package:museum_mpupurwa_app/features/collections/viewmodel/koleksi_detail_view_model.dart';
import 'package:museum_mpupurwa_app/features/home/model/home_models.dart';
import 'package:museum_mpupurwa_app/features/home/repository/home_repository.dart';
import 'package:museum_mpupurwa_app/features/home/viewmodel/home_view_model.dart';
import 'package:museum_mpupurwa_app/features/info/viewmodel/info_view_model.dart';

/// Test ViewModel tanpa widget dan tanpa Flutter engine: repository dan service
/// diganti objek palsu. Inilah keuntungan utama MVVM, logika layar bisa diuji
/// terpisah dari tampilan.

class _FakeAuthRepository implements AuthRepository {
  bool signedOut = false;
  VisitorProfile? saved;

  @override
  Future<AuthSession> restoreSession() async =>
      const AuthSession(isLoggedIn: true, profile: VisitorProfile.dummy);

  @override
  Future<VisitorProfile> signIn() async => VisitorProfile.dummy;

  @override
  Future<void> saveProfile(VisitorProfile profile) async => saved = profile;

  @override
  Future<void> signOut() async => signedOut = true;
}

class _FakeKoleksiRepository implements KoleksiRepository {
  _FakeKoleksiRepository({this.fail = false});

  final bool fail;

  @override
  Future<List<Koleksi>> fetchAll() async {
    if (fail) throw Exception('gagal');
    return [
      _koleksi('1', 'Arca Ganesya Tikus', 'SINGOSARI'),
      _koleksi('2', 'Arca Brahma', 'KANJURUHAN'),
      _koleksi('3', 'Siwa Catur Muka', 'TUMAPEL'),
    ];
  }
}

Koleksi _koleksi(String id, String nama, String era, {String? video, String? pdf}) => Koleksi(
  id: id,
  nama: nama,
  era: era,
  asal: '',
  periode: '',
  material: '',
  sejarah: '',
  fotoUrl: '',
  videoUrl: video,
  pdfUrl: pdf,
);

class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository({this.fail = false});

  final bool fail;

  @override
  Future<HomeContent> loadContent() async {
    if (fail) throw Exception('gagal');
    return const HomeContent(featured: [], eras: []);
  }
}

class _FakeLauncher implements LinkLauncher {
  final List<String> opened = [];
  bool result = true;

  @override
  Future<bool> open(String url) async {
    opened.add(url);
    return result;
  }
}

void main() {
  group('AuthViewModel', () {
    test('login mengisi profil dan menandai sudah masuk', () async {
      final vm = AuthViewModel(_FakeAuthRepository());
      expect(vm.isLoggedIn, isFalse);

      var notified = 0;
      vm.addListener(() => notified++);
      await vm.login();

      expect(vm.isLoggedIn, isTrue);
      expect(vm.profile, VisitorProfile.dummy);
      expect(notified, 1);
    });

    test('restore memulihkan sesi dari repository', () async {
      final vm = AuthViewModel(_FakeAuthRepository());
      await vm.restore();
      expect(vm.isLoggedIn, isTrue);
      expect(vm.profile?.name, 'Amanda Putri');
    });

    test('logout menghapus sesi lewat repository', () async {
      final repo = _FakeAuthRepository();
      final vm = AuthViewModel(repo);
      await vm.login();
      await vm.logout();

      expect(vm.isLoggedIn, isFalse);
      expect(vm.profile, isNull);
      expect(repo.signedOut, isTrue);
    });

    test('updateProfile menyimpan profil baru', () async {
      final repo = _FakeAuthRepository();
      final vm = AuthViewModel(repo);
      final changed = VisitorProfile.dummy.copyWith(name: 'Budi');
      await vm.updateProfile(changed);

      expect(vm.profile?.name, 'Budi');
      expect(repo.saved?.name, 'Budi');
    });
  });

  group('OtpViewModel', () {
    test('kode kurang dari 4 digit ditolak dengan pesan', () async {
      final vm = OtpViewModel(AuthViewModel(_FakeAuthRepository()));
      addTearDown(vm.dispose);

      expect(await vm.verify('42'), isFalse);
      expect(vm.error, 'Masukkan 4 digit kode verifikasi.');
    });

    test('kode lengkap berhasil masuk dan menghapus error', () async {
      final auth = AuthViewModel(_FakeAuthRepository());
      final vm = OtpViewModel(auth);
      addTearDown(vm.dispose);

      await vm.verify('42');
      vm.onCodeChanged('4209');
      expect(vm.error, isNull);

      expect(await vm.verify('4209'), isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(vm.submitting, isFalse);
    });

    test('teks hitung mundur dimulai dari 00:28', () {
      final vm = OtpViewModel(AuthViewModel(_FakeAuthRepository()));
      addTearDown(vm.dispose);

      expect(vm.countdownText, '00:28');
      expect(vm.canResend, isFalse);
    });
  });

  group('RegisterViewModel', () {
    test('isian wajib kosong menghasilkan pesan', () {
      final vm = RegisterViewModel();
      expect(vm.validateRequired('  ', 'Nama lengkap'), 'Nama lengkap wajib diisi.');
      expect(vm.validateRequired('Amanda', 'Nama lengkap'), isNull);
    });

    test('tanpa persetujuan pendaftaran ditolak dan error muncul', () {
      final vm = RegisterViewModel()..setAgreed(false);

      expect(vm.submit(formValid: true), isFalse);
      expect(vm.consentError, isTrue);

      vm.setAgreed(true);
      expect(vm.consentError, isFalse);
      expect(vm.submit(formValid: true), isTrue);
    });
  });

  group('HomeViewModel', () {
    test('load berhasil mengisi content', () async {
      final vm = HomeViewModel(_FakeHomeRepository());
      expect(vm.content, isNull);

      await vm.load();
      expect(vm.content, isNotNull);
      expect(vm.isLoading, isFalse);
      expect(vm.hasError, isFalse);
    });

    test('load gagal menandai error', () async {
      final vm = HomeViewModel(_FakeHomeRepository(fail: true));
      await vm.load();
      expect(vm.hasError, isTrue);
      expect(vm.content, isNull);
    });
  });

  group('KatalogViewModel', () {
    test('memuat semua koleksi lalu memfilter berdasarkan era', () async {
      final vm = KatalogViewModel(_FakeKoleksiRepository());
      await vm.load();
      expect(vm.filtered, hasLength(3));

      vm.selectEra('Tumapel');
      expect(vm.filtered.map((k) => k.nama), ['Siwa Catur Muka']);
    });

    test('pencarian tidak peka huruf besar-kecil dan digabung dengan era', () async {
      final vm = KatalogViewModel(_FakeKoleksiRepository());
      await vm.load();

      vm.search('arca');
      expect(vm.filtered, hasLength(2));

      vm.selectEra('Kanjuruhan');
      expect(vm.filtered.map((k) => k.nama), ['Arca Brahma']);

      vm.search('zzz');
      expect(vm.filtered, isEmpty);
    });

    test('initialEra dari query dipakai, nilai tak dikenal diabaikan', () async {
      expect(
        KatalogViewModel(_FakeKoleksiRepository(), initialEra: 'tumapel').selectedEra,
        'Tumapel',
      );
      expect(
        KatalogViewModel(_FakeKoleksiRepository(), initialEra: 'Mataram').selectedEra,
        KatalogViewModel.semua,
      );
    });

    test('repository gagal menandai error', () async {
      final vm = KatalogViewModel(_FakeKoleksiRepository(fail: true));
      await vm.load();
      expect(vm.hasError, isTrue);
      expect(vm.filtered, isEmpty);
    });
  });

  group('KoleksiDetailViewModel', () {
    test('data kosong memakai nilai cadangan', () {
      final vm = KoleksiDetailViewModel(_koleksi('9', 'Arca', 'tumapel'), _FakeLauncher());
      expect(vm.asal, 'Malang Raya');
      expect(vm.material, 'Batu Andesit');
      expect(vm.era, 'TUMAPEL');
      expect(vm.hasActions, isFalse);
    });

    test('openVideo dan openPdf memakai LinkLauncher', () async {
      final launcher = _FakeLauncher();
      final vm = KoleksiDetailViewModel(
        _koleksi('9', 'Arca', 'tumapel', video: 'https://v', pdf: 'https://p'),
        launcher,
      );

      expect(vm.hasVideo && vm.hasPdf, isTrue);
      expect(await vm.openVideo(), isTrue);
      expect(await vm.openPdf(), isTrue);
      expect(launcher.opened, ['https://v', 'https://p']);
    });
  });

  group('BookingViewModel', () {
    test('validasi jumlah peserta dan nomor HP', () {
      final vm = BookingViewModel();
      expect(vm.validateParticipants(''), 'Jumlah peserta wajib diisi.');
      expect(vm.validateParticipants('1'), contains('Minimal'));
      expect(vm.validateParticipants('9999'), contains('Maksimal'));
      expect(vm.validateParticipants('30'), isNull);

      expect(vm.validatePhone(''), 'Nomor HP wajib diisi.');
      expect(vm.validatePhone('12345'), contains('tidak valid'));
      expect(vm.validatePhone('0812-3456-7890'), isNull);
      expect(vm.validatePhone('+6281234567890'), isNull);
    });

    test('tanggal kunjungan paling cepat besok dan hanya hari buka', () {
      final vm = BookingViewModel();
      final now = DateTime(2026, 10, 14, 15); // Rabu

      expect(vm.firstVisitDate(now), DateTime(2026, 10, 15));
      expect(vm.isSelectableDay(DateTime(2026, 10, 17)), isFalse); // Sabtu
      // Jumat 16 Okt dipilih, lalu Sabtu/Minggu dilewati ke Senin.
      expect(vm.initialPickerDate(current: DateTime(2026, 10, 17)), DateTime(2026, 10, 19));
    });

    test('submitForm merapikan isian dan menaruh pengajuan terbaru di depan', () async {
      final vm = BookingViewModel();
      await vm.submitForm(
        institution: '  SMA 1 Malang ',
        contactName: ' Budi ',
        visitDate: DateTime(2026, 10, 20),
        participants: ' 30 ',
        phone: '0812-3456-7890',
        notes: '',
      );
      await vm.submitForm(
        institution: 'SMP 2',
        contactName: 'Sari',
        visitDate: DateTime(2026, 10, 21),
        participants: '20',
        phone: '0812-3456-7890',
        notes: '',
      );

      expect(vm.requests.map((r) => r.institution), ['SMP 2', 'SMA 1 Malang']);
      expect(vm.requests.last.participants, 30);
      expect(vm.requests.last.contactName, 'Budi');
    });
  });

  group('InfoViewModel', () {
    test('jam operasional mengikuti MuseumHours dan tautan lewat LinkLauncher', () async {
      final launcher = _FakeLauncher();
      final vm = InfoViewModel(launcher);

      expect(vm.hours.first.label, 'Senin – Jumat');
      expect(vm.hours.first.value, '08.00 – 16.00');
      expect(vm.hours.last.value, 'Tutup');

      await vm.openMaps();
      await vm.callMuseum();
      expect(launcher.opened, [vm.info.mapsUrl, vm.info.phoneUrl]);
    });

    test('mengembalikan false kalau tautan gagal dibuka', () async {
      final launcher = _FakeLauncher()..result = false;
      expect(await InfoViewModel(launcher).openInstagram(), isFalse);
    });
  });
}
