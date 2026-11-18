import 'package:flutter/material.dart';

import 'app.dart';
import 'core/storage/session_storage.dart';
import 'features/auth/repository/local_auth_repository.dart';
import 'features/auth/viewmodel/auth_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pulihkan sesi login sebelum UI muncul, supaya pengguna yang sudah masuk
  // tidak sempat melihat layar Auth Gate.
  final storage = await SessionStorage.create();
  final authViewModel = AuthViewModel(LocalAuthRepository(storage));
  await authViewModel.restore();

  runApp(MuseumApp(authViewModel: authViewModel));
}
