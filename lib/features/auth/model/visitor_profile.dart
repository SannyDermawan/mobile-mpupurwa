/// Data diri pengunjung. Dipakai bersama: Beranda (sapaan) dan halaman
/// Profil Saya (Teman 1). Field-nya mengikuti halaman Profil di HTML.
class VisitorProfile {
  const VisitorProfile({
    required this.name,
    required this.educationLevel,
    required this.domicile,
    required this.institution,
    required this.phone,
    required this.email,
  });

  /// Nama lengkap, mis. "Amanda Putri".
  final String name;

  /// Tingkat pendidikan, mis. "Mahasiswa".
  final String educationLevel;

  /// Domisili, mis. "Surabaya".
  final String domicile;

  /// Asal sekolah / institusi, mis. "Univ. Airlangga".
  final String institution;

  final String phone;
  final String email;

  /// Data dummy dari HTML. Dipakai sampai backend untuk aplikasi mobile ada.
  static const VisitorProfile dummy = VisitorProfile(
    name: 'Amanda Putri',
    educationLevel: 'Mahasiswa',
    domicile: 'Surabaya',
    institution: 'Univ. Airlangga',
    phone: '0812-xxxx-3421',
    email: 'amanda@gmail.com',
  );

  VisitorProfile copyWith({
    String? name,
    String? educationLevel,
    String? domicile,
    String? institution,
    String? phone,
    String? email,
  }) {
    return VisitorProfile(
      name: name ?? this.name,
      educationLevel: educationLevel ?? this.educationLevel,
      domicile: domicile ?? this.domicile,
      institution: institution ?? this.institution,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  Map<String, String> toJson() => {
    'name': name,
    'educationLevel': educationLevel,
    'domicile': domicile,
    'institution': institution,
    'phone': phone,
    'email': email,
  };

  factory VisitorProfile.fromJson(Map<String, dynamic> json) {
    String read(String key, String fallback) {
      final value = json[key];
      return value is String && value.isNotEmpty ? value : fallback;
    }

    return VisitorProfile(
      name: read('name', dummy.name),
      educationLevel: read('educationLevel', dummy.educationLevel),
      domicile: read('domicile', dummy.domicile),
      institution: read('institution', dummy.institution),
      phone: read('phone', dummy.phone),
      email: read('email', dummy.email),
    );
  }
}
