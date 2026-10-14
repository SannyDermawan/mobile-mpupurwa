import 'package:flutter/material.dart';

import 'koleksi_detail_page.dart';
import 'koleksi_model.dart';

class KatalogScreen extends StatefulWidget {
  const KatalogScreen({Key? key}) : super(key: key);

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedEra = "Semua";
  List<Koleksi> _allKoleksi = [];
  List<Koleksi> _filteredKoleksi = [];
  bool _isLoading = false;

  // Warna sesuai Desain UI
  static const Color primaryGold = Color(0xFFD4A017); // Warna Emas/Kuning
  static const Color goldLight = Color(0xFFE8C86A);
  static const Color bgGrey = Color(0xFFF9F9F9);
  static const Color cardDark = Color(0xFF1F1F1F); // Background placeholder icon
  static const Color textDark = Color(0xFF1A1A1A);

  final List<String> _eraOptions = ["Semua", "Kanjuruhan", "Tumapel", "Singosari", "Prasasti"];

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Data tiruan yang sama persis dengan UI
    _allKoleksi = [
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
        fotoUrl: '', // Kosong untuk menampilkan placeholder icon seperti UI
      ),
      Koleksi(
        id: '4',
        nama: 'Makara Gapura',
        era: 'SINGOSARI',
        asal: 'Singosari',
        periode: 'Abad 13',
        material: 'Batu Andesit',
        sejarah: 'Hiasan gapura berbentuk hewan mitologi Makara.',
        fotoUrl: '', // Kosong untuk placeholder icon
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
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      _filteredKoleksi = _allKoleksi.where((item) {
        final matchesSearch = item.nama.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        );
        final matchesEra =
            _selectedEra == "Semua" || item.era.toUpperCase() == _selectedEra.toUpperCase();
        return matchesSearch && matchesEra;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header Title
            const Text(
              "Katalog Koleksi",
              style: TextStyle(
                fontFamily: 'Serif', // Menggunakan font serif
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 16),

            // 1. Search Bar (Bulat Halus)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: bgGrey,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300, width: 0.8),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilter(),
                  decoration: const InputDecoration(
                    hintText: "Cari nama koleksi...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Chip Filter Era
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _eraOptions.length,
                itemBuilder: (context, index) {
                  final era = _eraOptions[index];
                  final isSelected = _selectedEra == era;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEra = era;
                          _applyFilter();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? goldLight : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? goldLight : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          era,
                          style: TextStyle(
                            color: isSelected ? textDark : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 3. Grid 2 Kolom
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredKoleksi.isEmpty
                  ? const Center(
                      child: Text("Koleksi tidak ditemukan", style: TextStyle(color: Colors.grey)),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.76,
                      ),
                      itemCount: _filteredKoleksi.length,
                      itemBuilder: (context, index) {
                        final item = _filteredKoleksi[index];
                        return _buildCollectionCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Kartu Koleksi Sesui UI
  Widget _buildCollectionCard(Koleksi item) {
    final bool hasImage = item.fotoUrl.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => KoleksiDetailPage(koleksi: item)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar / Icon Placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: hasImage ? Colors.transparent : cardDark,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: hasImage
                      ? Image.network(
                          item.fotoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildPlaceholderIcon(index: int.tryParse(item.id) ?? 1),
                        )
                      : _buildPlaceholderIcon(index: int.tryParse(item.id) ?? 1),
                ),
              ),
            ),

            // Teks Era dan Nama Koleksi
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.era.toUpperCase(),
                    style: const TextStyle(
                      color: primaryGold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.nama,
                    style: const TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Icon Vektor Emas untuk item tanpa gambar (seperti Siwa Catur Muka & Makara Gapura)
  Widget _buildPlaceholderIcon({required int index}) {
    IconData iconData;
    if (index % 3 == 0) {
      iconData = Icons.article_outlined;
    } else if (index % 3 == 1) {
      iconData = Icons.change_history_outlined;
    } else {
      iconData = Icons.all_inclusive_outlined;
    }

    return Center(child: Icon(iconData, size: 38, color: primaryGold));
  }
}
