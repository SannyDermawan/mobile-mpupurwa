/// Status sebuah pengajuan booking rombongan.
///
/// Pengajuan baru selalu berstatus [menungguKonfirmasi]. Dua status lainnya
/// disediakan untuk jawaban dari pihak museum nanti.
// TODO(backend): status diisi dari server setelah admin memproses pengajuan.
enum BookingStatus {
  menungguKonfirmasi('Menunggu Konfirmasi'),
  dikonfirmasi('Dikonfirmasi'),
  ditolak('Ditolak');

  const BookingStatus(this.label);

  final String label;
}

/// Satu pengajuan kunjungan rombongan, sesuai isian form Booking Rombongan.
class BookingRequest {
  const BookingRequest({
    required this.institution,
    required this.contactName,
    required this.visitDate,
    required this.participants,
    required this.phone,
    required this.submittedAt,
    this.notes = '',
    this.status = BookingStatus.menungguKonfirmasi,
  });

  /// Nama sekolah, kampus, atau komunitas.
  final String institution;

  /// Nama penanggung jawab rombongan.
  final String contactName;
  final DateTime visitDate;
  final int participants;
  final String phone;

  /// Catatan tambahan, kosong kalau tidak diisi.
  final String notes;

  /// Waktu pengajuan dikirim.
  final DateTime submittedAt;
  final BookingStatus status;
}

/// Batas isian jumlah peserta. Angkanya sementara, sesuaikan dengan kebijakan
/// museum kalau sudah ada.
abstract final class BookingLimits {
  static const int minParticipants = 2;
  static const int maxParticipants = 500;
}
