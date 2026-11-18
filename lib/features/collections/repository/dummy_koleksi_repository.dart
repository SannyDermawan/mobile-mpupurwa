import '../model/koleksi_model.dart';
import 'koleksi_repository.dart';

/// Data koleksi tiruan yang sama dengan desain, dipakai sampai backend
/// aplikasi mobile tersedia.
// TODO(backend): ganti dengan implementasi yang memakai ApiClient.
class DummyKoleksiRepository implements KoleksiRepository {
  const DummyKoleksiRepository();

  @override
  Future<List<Koleksi>> fetchAll() async => [
    Koleksi(
      id: '1',
      nama: 'Arca Ganesya Tikus',
      era: 'SINGOSARI',
      asal: 'Malang',
      periode: 'Abad 13',
      material: 'Batu Andesit',
      sejarah: 'Arca Ganesha dengan hiasan motif tikus.',
      fotoUrl: 'https://images.unsplash.com/photo-1590059300620-e298533e4b37?q=80&w=400',
    ),
    Koleksi(
      id: '2',
      nama: 'Arca Brahma',
      era: 'KANJURUHAN',
      asal: 'Malang',
      periode: 'Abad 8',
      material: 'Batu Andesit',
      sejarah: 'Arca Dewa Brahma berkepala empat.',
      fotoUrl: 'https://images.unsplash.com/photo-1565008447742-97f6f38c985c?q=80&w=400',
    ),
    Koleksi(
      id: '3',
      nama: 'Siwa Catur Muka',
      era: 'TUMAPEL',
      asal: 'Kediri',
      periode: 'Abad 12',
      material: 'Batu Andesit',
      sejarah: 'Arca Siwa dengan empat wajah.',
      fotoUrl: '', // Kosong: kartu menampilkan ikon placeholder.
    ),
    Koleksi(
      id: '4',
      nama: 'Makara Gapura',
      era: 'SINGOSARI',
      asal: 'Singosari',
      periode: 'Abad 13',
      material: 'Batu Andesit',
      sejarah: 'Hiasan gapura berbentuk hewan mitologi Makara.',
      fotoUrl: '',
    ),
    Koleksi(
      id: '5',
      nama: 'Prasasti Kanuruhan',
      era: 'PRASASTI',
      asal: 'Malang',
      periode: 'Abad 10',
      material: 'Batu',
      sejarah: 'Prasasti peninggalan kerajaan Kanjuruhan.',
      fotoUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?q=80&w=400',
    ),
    Koleksi(
      id: '6',
      nama: 'Candi Kidal Model',
      era: 'TUMAPEL',
      asal: 'Turen',
      periode: 'Abad 13',
      material: 'Batu Andesit',
      sejarah: 'Replika relief Candi Kidal.',
      fotoUrl: '',
    ),
  ];
}
