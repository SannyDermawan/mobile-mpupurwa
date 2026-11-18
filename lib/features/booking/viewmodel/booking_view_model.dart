import 'package:flutter/foundation.dart';

import '../../../core/constants/museum_hours.dart';
import '../model/booking_model.dart';
import '../repository/booking_repository.dart';

/// ViewModel Booking Rombongan dan Status Booking.
///
/// - Menyimpan daftar pengajuan ([requests]) yang dibaca layar Status Booking.
/// - Memegang aturan validasi dan aturan tanggal kunjungan untuk form Booking.
/// - Menerima pengajuan dari View lalu meneruskannya ke [BookingRepository].
///
/// ```dart
/// context.read<BookingViewModel>().submitRequest(...);
/// final requests = context.watch<BookingViewModel>().requests;
/// ```
class BookingViewModel extends ChangeNotifier {
  BookingViewModel({BookingRepository? repository})
    : _repository = repository ?? InMemoryBookingRepository();

  final BookingRepository _repository;

  /// Nomor seluler Indonesia: 08xx, 628xx, atau +628xx, total 10–13 digit.
  static final _phonePattern = RegExp(r'^(\+62|62|0)8\d{8,11}$');

  final List<BookingRequest> _requests = [];

  /// Semua pengajuan, yang terbaru di urutan pertama.
  List<BookingRequest> get requests => List.unmodifiable(_requests);

  /// Pengajuan terbaru, atau `null` kalau belum pernah mengajukan.
  BookingRequest? get latest => _requests.isEmpty ? null : _requests.first;

  /// Memuat riwayat pengajuan dari repository.
  Future<void> load() async {
    final saved = await _repository.fetchAll();
    _requests
      ..clear()
      ..addAll(saved);
    notifyListeners();
  }

  /// Menambah [request] ke daftar (langsung tampil) lalu menyimpannya.
  Future<void> submit(BookingRequest request) async {
    _requests.insert(0, request);
    notifyListeners();
    await _repository.save(request);
  }

  /// Membuat [BookingRequest] dari isian form (teks mentah dari View), lalu
  /// mengirimkannya. Dipanggil setelah semua validator lolos.
  Future<void> submitForm({
    required String institution,
    required String contactName,
    required DateTime visitDate,
    required String participants,
    required String phone,
    required String notes,
    DateTime? now,
  }) {
    return submit(
      BookingRequest(
        institution: institution.trim(),
        contactName: contactName.trim(),
        visitDate: visitDate,
        participants: int.parse(participants.trim()),
        phone: phone.trim(),
        notes: notes.trim(),
        submittedAt: now ?? DateTime.now(),
      ),
    );
  }

  // --- Aturan validasi ---

  String? validateRequired(String? value, String fieldName) =>
      (value == null || value.trim().isEmpty) ? '$fieldName wajib diisi.' : null;

  String? validateParticipants(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Jumlah peserta wajib diisi.';
    final count = int.tryParse(text);
    if (count == null || count < BookingLimits.minParticipants) {
      return 'Minimal ${BookingLimits.minParticipants} peserta untuk kunjungan rombongan.';
    }
    if (count > BookingLimits.maxParticipants) {
      return 'Maksimal ${BookingLimits.maxParticipants} peserta per pengajuan.';
    }
    return null;
  }

  String? validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nomor HP wajib diisi.';
    final digits = text.replaceAll(RegExp(r'[\s-]'), '');
    if (!_phonePattern.hasMatch(digits)) {
      return 'Nomor HP tidak valid. Contoh: 0812-3456-7890.';
    }
    return null;
  }

  // --- Aturan tanggal kunjungan ---

  /// Pengajuan perlu dikonfirmasi dulu, jadi paling cepat besok.
  DateTime firstVisitDate([DateTime? now]) =>
      _dateOnly(now ?? DateTime.now()).add(const Duration(days: 1));

  /// Batas akhir pemilihan tanggal: setahun dari hari ini.
  DateTime lastVisitDate([DateTime? now]) =>
      _dateOnly(now ?? DateTime.now()).add(const Duration(days: 365));

  /// Hanya hari buka yang boleh dipilih.
  bool isSelectableDay(DateTime day) => MuseumHours.isOpenToday(day);

  /// Tanggal awal pemilih tanggal: [current] kalau ada, kalau tidak hari
  /// pertama yang boleh dipilih, dimajukan sampai jatuh di hari buka.
  DateTime initialPickerDate({DateTime? current, DateTime? now}) {
    var initial = current ?? firstVisitDate(now);
    while (!isSelectableDay(initial)) {
      initial = initial.add(const Duration(days: 1));
    }
    return initial;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
