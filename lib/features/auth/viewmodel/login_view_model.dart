/// ViewModel layar Login: aturan validasi isian, tanpa state yang berubah.
class LoginViewModel {
  const LoginViewModel();

  /// Pesan error untuk isian No. HP / Gmail, `null` kalau valid.
  String? validateIdentifier(String? value) => (value == null || value.trim().isEmpty)
      ? 'Isi No. HP atau Gmail terlebih dahulu.'
      : null;
}
