/// Format tanggal berbahasa Indonesia, dipakai layar Booking, Status Booking,
/// dan Kunjungan Tercatat. Ditulis manual supaya tidak perlu paket `intl`.
const _namaHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

const _namaBulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// "Rabu, 14 Oktober 2026".
String formatTanggalLengkap(DateTime date) =>
    '${_namaHari[date.weekday - 1]}, ${date.day} ${_namaBulan[date.month - 1]} ${date.year}';

/// "14 Okt 2026", untuk daftar yang ringkas.
String formatTanggalSingkat(DateTime date) =>
    '${date.day} ${_namaBulan[date.month - 1].substring(0, 3)} ${date.year}';
