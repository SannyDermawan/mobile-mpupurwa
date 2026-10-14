import 'package:flutter/foundation.dart';

import 'booking_model.dart';

/// Daftar pengajuan booking rombongan milik pengguna.
///
/// Form Booking Rombongan memanggil [submit], lalu Status Booking membaca
/// [requests]:
///
/// ```dart
/// context.read<BookingController>().submit(request);
/// final requests = context.watch<BookingController>().requests;
/// ```
///
/// Data hanya disimpan di memori, jadi hilang saat aplikasi ditutup. Pengajuan
/// **belum dikirim ke museum** karena backend untuk aplikasi mobile belum ada.
// TODO(backend): kirim pengajuan lewat ApiClient dan muat riwayat dari server.
class BookingController extends ChangeNotifier {
  final List<BookingRequest> _requests = [];

  /// Semua pengajuan, yang terbaru di urutan pertama.
  List<BookingRequest> get requests => List.unmodifiable(_requests);

  /// Pengajuan terbaru, atau `null` kalau belum pernah mengajukan.
  BookingRequest? get latest => _requests.isEmpty ? null : _requests.first;

  void submit(BookingRequest request) {
    _requests.insert(0, request);
    notifyListeners();
  }
}
