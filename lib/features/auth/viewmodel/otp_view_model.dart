import 'dart:async';

import 'package:flutter/foundation.dart';

import 'auth_view_model.dart';

/// ViewModel layar kode verifikasi: hitung mundur kirim ulang, validasi panjang
/// kode, dan proses verifikasi.
class OtpViewModel extends ChangeNotifier {
  OtpViewModel(this._auth, {this.codeLength = 4, this.resendSeconds = 28}) {
    _startCountdown();
  }

  final AuthViewModel _auth;
  final int codeLength;
  final int resendSeconds;

  Timer? _timer;
  late int _secondsLeft = resendSeconds;
  String? _error;
  bool _submitting = false;
  bool _disposed = false;

  int get secondsLeft => _secondsLeft;
  String? get error => _error;
  bool get submitting => _submitting;

  /// Tombol "Kirim ulang" aktif setelah hitung mundur habis.
  bool get canResend => _secondsLeft <= 0;

  /// Teks hitung mundur, mis. `00:28`.
  String get countdownText => '00:${_secondsLeft.toString().padLeft(2, '0')}';

  /// Dipanggil View setiap isi kode berubah. Pesan error hilang begitu kode lengkap.
  void onCodeChanged(String code) {
    if (code.length == codeLength && _error != null) {
      _error = null;
      notifyListeners();
    }
  }

  /// Meminta kode baru dan mengulang hitung mundur.
  void resend() {
    // TODO(backend): minta kode verifikasi baru ke server.
    _error = null;
    _startCountdown();
    notifyListeners();
  }

  /// Memverifikasi [code]. Mengembalikan `true` kalau pengguna berhasil masuk.
  Future<bool> verify(String code) async {
    if (_submitting) return false;
    if (code.length < codeLength) {
      _error = 'Masukkan $codeLength digit kode verifikasi.';
      notifyListeners();
      return false;
    }
    _submitting = true;
    notifyListeners();
    // TODO(backend): mode demo, kode 4 digit apa pun diterima. Ganti dengan
    // verifikasi OTP ke server setelah endpoint untuk aplikasi mobile ada.
    await _auth.login();
    // Router bisa saja sudah memindahkan layar dan membuang ViewModel ini.
    if (_disposed) return true;
    _submitting = false;
    notifyListeners();
    return true;
  }

  void _startCountdown() {
    _timer?.cancel();
    _secondsLeft = resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsLeft--;
      if (_secondsLeft <= 0) timer.cancel();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
