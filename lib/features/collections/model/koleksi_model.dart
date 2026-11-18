class Koleksi {
  final String id;
  final String nama;
  final String era;
  final String asal;
  final String periode;
  final String material;
  final String sejarah;
  final String fotoUrl;
  final String? videoUrl;
  final String? pdfUrl;

  Koleksi({
    required this.id,
    required this.nama,
    required this.era,
    required this.asal,
    required this.periode,
    required this.material,
    required this.sejarah,
    required this.fotoUrl,
    this.videoUrl,
    this.pdfUrl,
  });

  factory Koleksi.fromJson(Map<String, dynamic> json) {
    return Koleksi(
      id: json['id'] ?? '',
      nama: json['nama'] ?? json['name'] ?? '',
      era: json['era'] ?? '',
      asal: json['asal'] ?? '',
      periode: json['periode'] ?? '',
      material: json['material'] ?? '',
      sejarah: json['sejarah'] ?? json['description'] ?? '',
      fotoUrl: json['fotoUrl'] ?? json['imageUrl'] ?? '',
      videoUrl: json['videoUrl'],
      pdfUrl: json['pdfUrl'],
    );
  }
}