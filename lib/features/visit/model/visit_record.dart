/// Satu baris riwayat kunjungan pengunjung, mis. `22 Sep 2026` → `Tercatat`.
class VisitRecord {
  const VisitRecord({required this.dateLabel, this.status = 'Tercatat'});

  final String dateLabel;
  final String status;
}
