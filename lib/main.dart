import 'package:flutter/material.dart';

import 'app.dart';
import 'core/storage/session_storage.dart';
import 'features/auth/repository/local_auth_repository.dart';
import 'features/auth/viewmodel/auth_view_model.dart';
import 'features/collections/repository/json_koleksi_repository.dart';
import 'features/collections/repository/serupa_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pulihkan sesi login sebelum UI muncul, supaya pengguna yang sudah masuk
  // tidak sempat melihat layar Auth Gate.
  final storage = await SessionStorage.create();
  final authViewModel = AuthViewModel(LocalAuthRepository(storage));
  await authViewModel.restore();

  // Data koleksi dan rekomendasi "Koleksi serupa" dibaca dari assets/data/.
  runApp(
    MuseumApp(
      authViewModel: authViewModel,
      koleksiRepository: JsonKoleksiRepository(),
      serupaRepository: AssetSerupaRepository(),
    ),
  );
}
