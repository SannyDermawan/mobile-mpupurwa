/// Data statis Museum Mpu Purwa untuk layar Info: alamat, kontak, dan tautan.
///
/// Jam buka tidak ada di sini; satu-satunya sumbernya adalah `MuseumHours`.
class MuseumInfo {
  const MuseumInfo({
    required this.address,
    required this.phoneLabel,
    required this.phoneUrl,
    required this.instagramLabel,
    required this.instagramUrl,
    required this.youtubeLabel,
    required this.youtubeUrl,
    required this.mapsUrl,
  });

  final String address;
  final String phoneLabel;
  final String phoneUrl;
  final String instagramLabel;
  final String instagramUrl;
  final String youtubeLabel;
  final String youtubeUrl;
  final String mapsUrl;

  static const MuseumInfo data = MuseumInfo(
    address:
        'Perumahan Griya Santa, Jl. Soekarno Hatta No.210 Blok B, Mojolangu, '
        'Lowokwaru, Malang City, Jawa Timur 65141',
    phoneLabel: '(0341) 000-000',
    phoneUrl: 'tel:0341000000',
    instagramLabel: '@mumpupurwamalang',
    instagramUrl: 'https://instagram.com',
    youtubeLabel: '@museummpupurwa',
    youtubeUrl: 'https://youtube.com',
    mapsUrl: 'https://maps.google.com/?q=Museum+Mpu+Purwa+Malang',
  );
}
