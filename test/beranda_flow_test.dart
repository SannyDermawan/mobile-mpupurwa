import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:museum_mpupurwa_app/app.dart';
import 'package:museum_mpupurwa_app/core/state/auth_controller.dart';
import 'package:museum_mpupurwa_app/core/state/visit_status_controller.dart';
import 'package:museum_mpupurwa_app/core/storage/session_storage.dart';
import 'package:museum_mpupurwa_app/features/home/beranda_page.dart';
import 'package:museum_mpupurwa_app/features/home/widgets/hours_info_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Layar setinggi ponsel supaya sedikit yang perlu digulir.
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

  testWidgets('alur Login → OTP → Beranda', (tester) async {
    usePhoneScreen(tester);
    final auth = AuthController(await SessionStorage.create());
    await tester.pumpWidget(MuseumApp(authController: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    // Kosong ditolak.
    await tester.tap(find.text('Kirim Kode Verifikasi'));
    await tester.pumpAndSettle();
    expect(find.text('Isi No. HP atau Gmail terlebih dahulu.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'amanda@gmail.com');
    await tester.tap(find.text('Kirim Kode Verifikasi'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan Kode'), findsOneWidget);
    expect(find.text('Kirim ulang (00:28)'), findsOneWidget);

    // Kode kurang dari 4 digit ditolak.
    await tester.enterText(find.byType(TextField), '42');
    await tester.tap(find.text('Verifikasi & Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan 4 digit kode verifikasi.'), findsOneWidget);

    // Hitung mundur berjalan, dan setelah habis berubah jadi tombol.
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Kirim ulang (00:23)'), findsOneWidget);
    await tester.pump(const Duration(seconds: 23));
    expect(find.widgetWithText(TextButton, 'Kirim ulang'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '4209');
    await tester.tap(find.text('Verifikasi & Masuk'));
    await tester.pumpAndSettle();

    expect(auth.isLoggedIn, isTrue);
    expect(find.text('Koleksi Unggulan'), findsOneWidget);
  });

  testWidgets('sesi yang tersimpan langsung membuka Beranda', (tester) async {
    usePhoneScreen(tester);
    final auth = await loggedInAuth();
    // Aplikasi dibuka ulang dengan penyimpanan yang sama.
    final reopened = AuthController(await SessionStorage.create());
    await reopened.restore();
    expect(auth.isLoggedIn, isTrue);

    await tester.pumpWidget(MuseumApp(authController: reopened));
    await tester.pumpAndSettle();

    expect(find.text('Koleksi Unggulan'), findsOneWidget);
    expect(find.text('Selamat datang di Museum Mpu Purwa'), findsNothing);
  });

  testWidgets('Beranda: kartu unggulan membuka koleksi/:id', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(MuseumApp(authController: await loggedInAuth()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Arca Brahma'));
    await tester.tap(find.text('Arca Brahma'));
    await tester.pumpAndSettle();

    expect(find.text('id: brahma'), findsOneWidget);
  });

  testWidgets('Beranda: linimasa mengganti era dan membuka katalog?era=', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(MuseumApp(authController: await loggedInAuth()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Tumapel'));
    await tester.tap(find.text('Tumapel'));
    await tester.pumpAndSettle();
    expect(find.text('Cikal Bakal Singosari'), findsOneWidget);

    await tester.tap(find.text('Lihat Koleksi Era Ini'));
    await tester.pumpAndSettle();
    expect(find.text('era: Tumapel'), findsOneWidget);
  });

  testWidgets('Beranda: era Majapahit tidak punya tombol koleksi', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(MuseumApp(authController: await loggedInAuth()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Majapahit'));
    await tester.tap(find.text('Majapahit'));
    await tester.pumpAndSettle();

    expect(find.text('Kerajaan Nusantara Terbesar'), findsOneWidget);
    expect(find.text('Lihat Koleksi Era Ini'), findsNothing);
  });

  testWidgets('Beranda: banner kunjungan berganti saat kunjungan tercatat', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(MuseumApp(authController: await loggedInAuth()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Sedang di museum?'), findsOneWidget);
    expect(find.textContaining('Kunjungan hari ini tercatat.'), findsNothing);

    tester.element(find.byType(BerandaPage)).read<VisitStatusController>().markVisitRecorded();
    await tester.pumpAndSettle();

    expect(find.textContaining('Kunjungan hari ini tercatat.'), findsOneWidget);
    expect(find.textContaining('Sedang di museum?'), findsNothing);
  });

  testWidgets('Beranda: banner "Sedang di museum?" membuka Scan QR', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(MuseumApp(authController: await loggedInAuth()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.textContaining('Sedang di museum?'));
    await tester.tap(find.textContaining('Sedang di museum?'));
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Kunjungan'), findsWidgets);
  });

  testWidgets('navbar: ketuk tab pindah layar, ketuk Scan membuka Scan QR', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(MuseumApp(authController: await loggedInAuth()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Booking').last);
    await tester.pumpAndSettle();
    expect(find.text('Booking Rombongan'), findsWidgets);

    await tester.tap(find.text('Info').last);
    await tester.pumpAndSettle();
    expect(find.text('Kunjungan & Lokasi'), findsWidgets);

    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();
    expect(find.text('Konfirmasi Kunjungan'), findsWidgets);

    await tester.tap(find.text('Beranda'));
    await tester.pumpAndSettle();
    expect(find.text('Koleksi Unggulan'), findsOneWidget);
  });

  group('info jam buka', () {
    Future<void> pumpBar(WidgetTester tester, DateTime now) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HoursInfoBar(now: now)),
        ),
      );
    }

    String plainText(WidgetTester tester) {
      // Ikon juga berupa RichText, jadi ambil yang berisi kalimat jam buka.
      final rich = tester.widget<RichText>(
        find.descendant(
          of: find.byType(HoursInfoBar),
          matching: find.byWidgetPredicate(
            (w) => w is RichText && w.text.toPlainText().contains('hari ini'),
          ),
        ),
      );
      return rich.text.toPlainText();
    }

    testWidgets('hari kerja: buka hari ini', (tester) async {
      await pumpBar(tester, DateTime(2026, 10, 14)); // Rabu
      expect(
        plainText(tester),
        'Buka hari ini pukul 08.00–16.00. Jam dapat berubah sewaktu-waktu, cek info kunjungan sebelum datang.',
      );
    });

    testWidgets('Sabtu dan Minggu: tutup hari ini', (tester) async {
      for (final day in [17, 18]) {
        await pumpBar(tester, DateTime(2026, 10, day));
        expect(
          plainText(tester),
          'Tutup hari ini. Museum buka Senin–Jumat pukul 08.00–16.00. Jam dapat berubah sewaktu-waktu, cek info kunjungan sebelum datang.',
        );
      }
    });
  });
}
