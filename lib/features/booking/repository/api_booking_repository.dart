import '../../../core/network/api_client.dart';
import '../../../core/storage/session_storage.dart';
import '../model/booking_model.dart';
import 'booking_repository.dart';

/// Mengirim pengajuan booking ke Web Admin (`POST /api/public/bookings`) dan
/// membaca statusnya (`GET /api/public/bookings?ids=`).
///
/// Server memberi tiap pengajuan id acak. Id itu disimpan di perangkat
/// ([SessionStorage]); hanya pemegang id yang bisa melihat statusnya. Admin
/// mengubah status dari dashboard, dan aplikasi menampilkannya saat memuat ulang.
class ApiBookingRepository implements BookingRepository {
  ApiBookingRepository(this._client, this._storage);

  final ApiClient _client;
  final SessionStorage _storage;

  @override
  Future<List<BookingRequest>> fetchAll() async {
    final ids = _storage.bookingIds;
    if (ids.isEmpty) return const [];
    final data = await _client.getJson('/api/public/bookings', query: {'ids': ids.join(',')});
    return parse(data);
  }

  @override
  Future<void> save(BookingRequest request) async {
    final data = await _client.postJson('/api/public/bookings', {
      'institution': request.institution,
      'contactName': request.contactName,
      'phone': request.phone,
      'participants': request.participants,
      'visitDate': _isoDate(request.visitDate),
      'notes': request.notes,
    });
    final id = data is Map<String, dynamic> ? data['id'] : null;
    if (id is String) await _storage.addBookingId(id);
  }

  /// Mengubah balasan API menjadi [BookingRequest], terbaru dulu.
  static List<BookingRequest> parse(Object? data) {
    if (data is! List) throw const ApiException('Daftar booking dari server tidak valid.');
    final hasil = <BookingRequest>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final visit = DateTime.tryParse('${raw['visitDate']}');
      final submitted = DateTime.tryParse('${raw['submittedAt']}');
      if (visit == null || submitted == null) continue;
      hasil.add(
        BookingRequest(
          institution: '${raw['institution']}',
          contactName: '${raw['contactName']}',
          phone: '${raw['phone']}',
          participants: (raw['participants'] as num?)?.toInt() ?? 0,
          notes: '${raw['notes'] ?? ''}',
          visitDate: visit,
          submittedAt: submitted.toLocal(),
          status: _status('${raw['status']}'),
        ),
      );
    }
    hasil.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return hasil;
  }

  static BookingStatus _status(String s) => switch (s) {
    'confirmed' || 'completed' => BookingStatus.dikonfirmasi,
    'rejected' => BookingStatus.ditolak,
    _ => BookingStatus.menungguKonfirmasi,
  };

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
