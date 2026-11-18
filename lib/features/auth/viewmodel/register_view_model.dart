import 'package:flutter/foundation.dart';

/// ViewModel layar Daftar: aturan validasi dan state kotak persetujuan.
class RegisterViewModel extends ChangeNotifier {
  // Di HTML kotak persetujuan sudah tercentang sejak awal (`checked`).
  bool _agreed = true;
  bool _consentError = false;

  bool get agreed => _agreed;

  /// `true` setelah pengguna mencoba mendaftar tanpa mencentang persetujuan.
  bool get consentError => _consentError;

  /// Pesan error untuk isian wajib, `null` kalau terisi.
  String? validateRequired(String? value, String fieldName) =>
      (value == null || value.trim().isEmpty) ? '$fieldName wajib diisi.' : null;

  void setAgreed(bool value) {
    _agreed = value;
    if (value) _consentError = false;
    notifyListeners();
  }

  /// Dipanggil saat tombol Daftar ditekan. [formValid] adalah hasil validasi
  /// form oleh View. Mengembalikan `true` kalau boleh lanjut ke verifikasi.
  bool submit({required bool formValid}) {
    _consentError = !_agreed;
    notifyListeners();
    return formValid && _agreed;
  }
}
