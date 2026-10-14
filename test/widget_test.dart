import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:museum_mpupurwa_app/app.dart';
import 'package:museum_mpupurwa_app/core/state/auth_controller.dart';
import 'package:museum_mpupurwa_app/core/storage/session_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Font Google tidak diunduh saat test; teks memakai font bawaan.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('aplikasi terbuka di Auth Gate dan tombol Masuk membuka Login', (tester) async {
    final auth = AuthController(await SessionStorage.create());
    await tester.pumpWidget(MuseumApp(authController: auth));
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang di Museum Mpu Purwa'), findsOneWidget);
    expect(find.text('Buat Akun Baru'), findsOneWidget);

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Kirim Kode Verifikasi'), findsOneWidget);
    expect(find.text('Halo, wisatawan!'), findsOneWidget);
  });
}
