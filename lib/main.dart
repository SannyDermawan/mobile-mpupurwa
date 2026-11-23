import 'package:flutter/material.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/network/api_config.dart';
import 'core/storage/session_storage.dart';
import 'features/auth/repository/local_auth_repository.dart';
import 'features/auth/viewmodel/auth_view_model.dart';
import 'features/booking/repository/api_booking_repository.dart';
import 'features/collections/repository/api_koleksi_repository.dart';
import 'features/collections/repository/json_koleksi_repository.dart';
import 'features/collections/repository/koleksi_repository.dart';
import 'features/collections/repository/serupa_repository.dart';
import 'features/home/repository/home_repository.dart';
import 'features/visit/repository/api_visit_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pulihkan sesi login sebelum UI muncul, supaya pengguna yang sudah masuk
  // tidak sempat melihat layar Auth Gate.
  final storage = await SessionStorage.create();
  final authViewModel = AuthViewModel(LocalAuthRepository(storage));
  await authViewModel.restore();

  // Data koleksi dan rekomendasi "Koleksi serupa" dibaca dari assets/data/.
  // Kalau API_BASE_URL diisi (lihat ApiConfig), koleksi, booking, dan check-in
  // terhubung ke Web Admin; data bawaan menjadi cadangan saat server tak terjangkau.
  final JsonKoleksiRepository bundled = JsonKoleksiRepository();
  final client = ApiConfig.enabled ? ApiClient() : null;
  final KoleksiRepository koleksi = client == null
      ? bundled
      : ApiKoleksiRepository(client, fallback: bundled);

  runApp(
    MuseumApp(
      authViewModel: authViewModel,
      koleksiRepository: koleksi,
      homeRepository: KoleksiHomeRepository(koleksi),
      serupaRepository: AssetSerupaRepository(),
      bookingRepository: client == null ? null : ApiBookingRepository(client, storage),
      visitRepository: client == null
          ? null
          : ApiVisitRepository(client, profile: () => authViewModel.profile),
    ),
  );
}
