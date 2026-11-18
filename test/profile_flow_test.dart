import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:museum_mpupurwa_app/app.dart';
import 'package:museum_mpupurwa_app/core/storage/session_storage.dart';
import 'package:museum_mpupurwa_app/features/auth/repository/local_auth_repository.dart';
import 'package:museum_mpupurwa_app/features/auth/viewmodel/auth_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Profil menampilkan data dari AuthViewModel dan keluar akun kembali ke Auth Gate', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final auth = AuthViewModel(LocalAuthRepository(await SessionStorage.create()));
    await auth.login();
    await tester.pumpWidget(MuseumApp(authViewModel: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Info').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Profil & Riwayat Kunjungan'));
    await tester.tap(find.text('Profil & Riwayat Kunjungan'));
    await tester.pumpAndSettle();

    expect(find.text('Profil Saya'), findsOneWidget);
    expect(find.text('Amanda Putri'), findsWidgets);
    expect(find.text('Mahasiswa · Surabaya'), findsOneWidget);
    expect(find.text('22 Sep 2026'), findsOneWidget);

    await tester.ensureVisible(find.text('Bukan saya, keluar akun'));
    await tester.tap(find.text('Bukan saya, keluar akun'));
    await tester.pumpAndSettle();

    expect(auth.isLoggedIn, isFalse);
    expect(find.text('Profil Saya'), findsNothing);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
