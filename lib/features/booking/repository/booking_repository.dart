import '../model/booking_model.dart';

/// Sumber data pengajuan booking rombongan.
///
/// [BookingViewModel] hanya bergantung pada antarmuka ini. Implementasi
/// sekarang ([InMemoryBookingRepository]) menyimpan di memori; nanti bisa
/// diganti implementasi API tanpa mengubah ViewModel maupun layar.
abstract class BookingRepository {
  /// Semua pengajuan milik pengguna, yang terbaru di urutan pertama.
  Future<List<BookingRequest>> fetchAll();

  /// Menyimpan (mengirim) satu pengajuan baru.
  // TODO(backend): kirim pengajuan ke server dan tunggu respons.
  Future<void> save(BookingRequest request);
}

/// Menyimpan pengajuan di memori. Hilang saat aplikasi ditutup, dan
/// **belum dikirim ke museum** karena backend untuk aplikasi mobile belum ada.
class InMemoryBookingRepository implements BookingRepository {
  final List<BookingRequest> _requests = [];

  @override
  Future<List<BookingRequest>> fetchAll() async => List.unmodifiable(_requests);

  @override
  Future<void> save(BookingRequest request) async => _requests.insert(0, request);
}
