import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:museum_mpupurwa_app/app.dart';
import 'package:museum_mpupurwa_app/core/router/app_routes.dart';
import 'package:museum_mpupurwa_app/core/state/auth_controller.dart';
import 'package:museum_mpupurwa_app/core/state/visit_status_controller.dart';
import 'package:museum_mpupurwa_app/core/storage/session_storage.dart';
import 'package:museum_mpupurwa_app/core/theme/app_theme.dart';
import 'package:museum_mpupurwa_app/features/booking/booking_controller.dart';
import 'package:museum_mpupurwa_app/features/booking/booking_model.dart';
import 'package:museum_mpupurwa_app/features/booking/status_booking_page.dart';
import 'package:museum_mpupurwa_app/features/booking/tanggal_format.dart';
import 'package:museum_mpupurwa_app/features/home/beranda_page.dart';
import 'package:museum_mpupurwa_app/features/visit/kunjungan_tercatat_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tes fitur Teman 2: Scan QR, Kunjungan Tercatat, Booking Rombongan, dan
/// Status Booking.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  void usePhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Future<AuthController> loggedInAuth() async {
    final auth = AuthController(await SessionStorage.create());
    await auth.login();
    return auth;
  }

  Future<void> pumpApp(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(MuseumApp(authController: await loggedInAuth()));
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.pumpAndSettle();
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  /// Urutan field di form: instansi, penanggung jawab, tanggal, peserta, HP, catatan.
  Finder field(int index) => find.byType(TextFormField).at(index);

  BookingRequest sampleRequest({String institution = 'SMA Negeri 1 Malang', String notes = ''}) {
    return BookingRequest(
      institution: institution,
      contactName: 'Budi Santoso',
      visitDate: DateTime(2026, 11, 2),
      participants: 30,
      phone: '081234567890',
      notes: notes,
      submittedAt: DateTime(2026, 10, 14),
    );
  }

  group('format tanggal', () {
    test('lengkap memakai nama hari dan bulan Indonesia', () {
      expect(formatTanggalLengkap(DateTime(2026, 10, 14)), 'Rabu, 14 Oktober 2026');
      expect(formatTanggalLengkap(DateTime(2026, 10, 18)), 'Minggu, 18 Oktober 2026');
      expect(formatTanggalLengkap(DateTime(2027, 1, 1)), 'Jumat, 1 Januari 2027');
    });

    test('singkat memakai tiga huruf bulan', () {
      expect(formatTanggalSingkat(DateTime(2026, 10, 14)), '14 Okt 2026');
      expect(formatTanggalSingkat(DateTime(2026, 5, 3)), '3 Mei 2026');
    });
  });

  group('BookingController', () {
    test('kosong di awal', () {
      final controller = BookingController();
      expect(controller.requests, isEmpty);
      expect(controller.latest, isNull);
    });

    test('pengajuan terbaru ada di urutan pertama dan pendengar diberi tahu', () {
      final controller = BookingController();
      var notified = 0;
      controller.addListener(() => notified++);

      controller.submit(sampleRequest(institution: 'Pertama'));
      controller.submit(sampleRequest(institution: 'Kedua'));

      expect(notified, 2);
      expect(controller.requests.map((r) => r.institution), ['Kedua', 'Pertama']);
      expect(controller.latest!.institution, 'Kedua');
      expect(controller.latest!.status, BookingStatus.menungguKonfirmasi);
    });
  });

  group('Scan QR', () {
    testWidgets('menampilkan kerangka kamera dan menjelaskan kamera belum berfungsi', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.text('Scan'));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Kunjungan'), findsOneWidget);
      expect(find.text('Scan QR Sekarang'), findsOneWidget);
      expect(find.text('Kamera belum aktif'), findsOneWidget);
    });

    testWidgets('tombol Scan membuka penjelasan, Tutup tidak mencatat kunjungan', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Scan'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Scan QR Sekarang'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scan QR Sekarang'));
      await tester.pumpAndSettle();
      expect(find.text('Kamera belum berfungsi'), findsOneWidget);

      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();

      expect(find.text('Kamera belum berfungsi'), findsNothing);
      expect(find.text('Konfirmasi Kunjungan'), findsOneWidget);
      final visit = tester.element(find.text('Konfirmasi Kunjungan')).read<VisitStatusController>();
      expect(visit.visitRecordedToday, isFalse);
    });

    testWidgets(
      'simulasi mencatat kunjungan, membuka Kunjungan Tercatat, dan mengubah banner Beranda',
      (tester) async {
        await pumpApp(tester);
        await tester.tap(find.text('Scan'));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Scan QR Sekarang'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Scan QR Sekarang'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Simulasikan Scan (Demo)'));
        await tester.pumpAndSettle();

        expect(find.text('Kunjungan Tercatat!'), findsOneWidget);
        expect(find.text('Mulai Jelajahi Koleksi'), findsOneWidget);
        final visit = tester
            .element(find.text('Kunjungan Tercatat!'))
            .read<VisitStatusController>();
        expect(visit.visitRecordedToday, isTrue);

        await tester.tap(find.text('Beranda'));
        await tester.pumpAndSettle();
        expect(find.byType(BerandaPage), findsOneWidget);
        expect(find.textContaining('Kunjungan hari ini tercatat.'), findsOneWidget);
      },
    );
  });

  group('Kunjungan Tercatat', () {
    Future<void> pumpPage(WidgetTester tester, AuthController auth) async {
      usePhoneScreen(tester);
      final router = GoRouter(
        initialLocation: AppRoutes.kunjunganTercatat,
        routes: [
          GoRoute(
            path: AppRoutes.kunjunganTercatat,
            builder: (context, state) => KunjunganTercatatPage(visitDate: DateTime(2026, 10, 14)),
          ),
          GoRoute(
            path: AppRoutes.katalog,
            builder: (context, state) => const Text('halaman katalog'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthController>.value(
          value: auth,
          child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('menampilkan centang, tanggal kunjungan, dan nama pengunjung', (tester) async {
      await pumpPage(tester, await loggedInAuth());

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.text('Kunjungan Tercatat!'), findsOneWidget);
      expect(find.text('Rabu, 14 Oktober 2026'), findsOneWidget);
      expect(find.text('Amanda Putri'), findsOneWidget);
      expect(find.text('Tercatat'), findsOneWidget);
    });

    testWidgets('tanpa profil, baris pengunjung disembunyikan tetapi tanggal tetap tampil', (
      tester,
    ) async {
      await pumpPage(tester, AuthController(await SessionStorage.create()));

      expect(find.text('Pengunjung'), findsNothing);
      expect(find.text('Rabu, 14 Oktober 2026'), findsOneWidget);
    });

    testWidgets('tombol "Mulai Jelajahi Koleksi" membuka Katalog', (tester) async {
      await pumpPage(tester, await loggedInAuth());

      await tester.tap(find.text('Mulai Jelajahi Koleksi'));
      await tester.pumpAndSettle();

      expect(find.text('halaman katalog'), findsOneWidget);
    });
  });

  group('Booking Rombongan', () {
    Future<void> openBooking(WidgetTester tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Booking').last);
      await tester.pumpAndSettle();
    }

    /// Hari buka pertama mulai besok, sama dengan tanggal awal date picker.
    DateTime firstBookableDay() {
      var day = DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 1));
      while (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
        day = day.add(const Duration(days: 1));
      }
      return day;
    }

    Future<void> pickDefaultDate(WidgetTester tester) async {
      await tester.ensureVisible(field(2));
      await tester.pumpAndSettle();
      await tester.tap(field(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pilih'));
      await tester.pumpAndSettle();
    }

    testWidgets('menampilkan semua field dan tombol kirim', (tester) async {
      await openBooking(tester);

      expect(find.text('Booking Rombongan'), findsOneWidget);
      for (final label in [
        'Nama Instansi',
        'Nama Penanggung Jawab',
        'Tanggal Kunjungan',
        'Jumlah Peserta',
        'Nomor HP',
        'Catatan Tambahan (opsional)',
        'Kirim Pengajuan',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('field wajib kosong menampilkan pesan error dan tidak mengirim', (tester) async {
      await openBooking(tester);

      await tapText(tester, 'Kirim Pengajuan');

      expect(find.text('Nama instansi wajib diisi.'), findsOneWidget);
      expect(find.text('Nama penanggung jawab wajib diisi.'), findsOneWidget);
      expect(find.text('Tanggal kunjungan wajib dipilih.'), findsOneWidget);
      expect(find.text('Jumlah peserta wajib diisi.'), findsOneWidget);
      expect(find.text('Nomor HP wajib diisi.'), findsOneWidget);
      // Catatan opsional, tidak boleh ikut error.
      expect(find.text('Catatan wajib diisi.'), findsNothing);
      expect(tester.element(field(0)).read<BookingController>().requests, isEmpty);
      expect(find.text('Kirim Pengajuan'), findsOneWidget);
    });

    testWidgets('jumlah peserta dan nomor HP yang tidak masuk akal ditolak', (tester) async {
      await openBooking(tester);

      await tester.enterText(field(3), '1');
      await tester.enterText(field(4), '12345');
      await tapText(tester, 'Kirim Pengajuan');
      expect(find.text('Minimal 2 peserta untuk kunjungan rombongan.'), findsOneWidget);
      expect(find.text('Nomor HP tidak valid. Contoh: 0812-3456-7890.'), findsOneWidget);

      await tester.enterText(field(3), '501');
      await tester.pumpAndSettle();
      expect(find.text('Maksimal 500 peserta per pengajuan.'), findsOneWidget);

      // Huruf disaring dari kolom jumlah peserta.
      await tester.enterText(field(3), '3a0');
      await tester.pumpAndSettle();
      expect(tester.widget<TextFormField>(field(3)).controller!.text, '30');
      expect(find.text('Maksimal 500 peserta per pengajuan.'), findsNothing);
    });

    testWidgets('pengajuan valid tersimpan lalu membuka Status Booking', (tester) async {
      await openBooking(tester);

      await tester.enterText(field(0), '  SMA Negeri 1 Malang  ');
      await tester.enterText(field(1), 'Budi Santoso');
      await pickDefaultDate(tester);
      expect(
        tester.widget<TextFormField>(field(2)).controller!.text,
        formatTanggalLengkap(firstBookableDay()),
      );
      await tester.enterText(field(3), '35');
      await tester.enterText(field(4), '+62 812-3456-7890');
      await tester.enterText(field(5), 'Butuh pemandu');
      await tapText(tester, 'Kirim Pengajuan');

      expect(find.text('Status Booking'), findsOneWidget);
      // Label status muncul di kartu status dan di riwayat.
      expect(find.text('Menunggu Konfirmasi'), findsNWidgets(2));
      expect(find.text('Informasi Pengajuan'), findsOneWidget);
      expect(find.text('Riwayat Pengajuan'), findsOneWidget);
      expect(find.text('Butuh pemandu'), findsOneWidget);
      expect(find.text('35 peserta'), findsOneWidget);

      final saved = tester.element(find.text('Status Booking')).read<BookingController>().latest!;
      expect(saved.institution, 'SMA Negeri 1 Malang');
      expect(saved.participants, 35);
      expect(saved.visitDate, firstBookableDay());
      expect(saved.status, BookingStatus.menungguKonfirmasi);
    });
  });

  group('Status Booking', () {
    Future<void> openStatusFromBooking(WidgetTester tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Booking').last);
      await tester.pumpAndSettle();
      await tapText(tester, 'Lihat Status Pengajuan');
    }

    testWidgets('kosong: menampilkan empty state dengan jalan menuju form', (tester) async {
      await openStatusFromBooking(tester);

      expect(find.text('Status Booking'), findsOneWidget);
      expect(find.text('Belum ada pengajuan booking'), findsOneWidget);
      expect(find.text('Menunggu Konfirmasi'), findsNothing);

      await tester.tap(find.text('Ajukan Booking Rombongan'));
      await tester.pumpAndSettle();
      expect(find.text('Kirim Pengajuan'), findsOneWidget);
    });

    testWidgets('empty state berganti jadi kartu status begitu ada pengajuan', (tester) async {
      await openStatusFromBooking(tester);
      expect(find.text('Belum ada pengajuan booking'), findsOneWidget);

      tester
          .element(find.byType(StatusBookingPage))
          .read<BookingController>()
          .submit(sampleRequest(institution: 'Universitas Brawijaya'));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada pengajuan booking'), findsNothing);
      expect(find.text('Universitas Brawijaya'), findsWidgets);
      expect(find.text('Menunggu Konfirmasi'), findsNWidgets(2));
      expect(find.text('Senin, 2 November 2026'), findsWidgets);
      // Tanpa catatan, barisnya diisi tanda hubung.
      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('riwayat menampilkan semua pengajuan, kartu status memakai yang terbaru', (
      tester,
    ) async {
      await openStatusFromBooking(tester);
      final controller = tester.element(find.byType(StatusBookingPage)).read<BookingController>();

      controller.submit(sampleRequest(institution: 'SMP Lama'));
      controller.submit(sampleRequest(institution: 'SMA Baru'));
      await tester.pumpAndSettle();

      // Terbaru muncul di kartu status, di tabel info, dan di riwayat; yang lama hanya di riwayat.
      expect(find.text('SMA Baru'), findsNWidgets(3));
      expect(find.text('SMP Lama'), findsOneWidget);
      // Kartu status + dua baris riwayat.
      expect(find.text('Menunggu Konfirmasi'), findsNWidgets(3));
    });

    testWidgets('nama instansi panjang tidak membuat tampilan overflow', (tester) async {
      await openStatusFromBooking(tester);

      tester
          .element(find.byType(StatusBookingPage))
          .read<BookingController>()
          .submit(
            sampleRequest(
              institution: 'Sekolah Menengah Atas Negeri Unggulan Terpadu Kota Malang Raya',
              notes: 'Mohon disediakan pemandu berbahasa Inggris dan akses kursi roda untuk dua peserta.',
            ),
          );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
