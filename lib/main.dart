import 'package:flutter/material.dart';

import 'app.dart';
import 'core/state/auth_controller.dart';
import 'core/storage/session_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pulihkan sesi login sebelum UI muncul, supaya pengguna yang sudah masuk
  // tidak sempat melihat layar Auth Gate.
  final storage = await SessionStorage.create();
  final authController = AuthController(storage);
  await authController.restore();

  runApp(MuseumApp(authController: authController));
}
