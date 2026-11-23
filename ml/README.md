# Koleksi Serupa: analisis teks arca (NLP)

Fitur "Koleksi serupa" di halaman Detail Koleksi memilih arca yang isi
penjelasannya paling mirip. Hitungannya dilakukan **di komputer** (skrip ini),
hasilnya disimpan sebagai JSON dan dibaca aplikasi Flutter. Jadi tidak ada model
yang harus dijalankan di HP.

```
assets/data/koleksi.json          data semua arca (dipakai aplikasi DAN skrip ini)
ml/data/pdf/<berkas>.pdf          PDF penjelasan detail tiap arca
ml/data/teks/<id>.txt             alternatif: teks biasa kalau tidak ada PDF
ml/build_serupa.py                skrip pembuat rekomendasi
ml/koleksi_serupa_colab.ipynb     notebook Colab untuk model embedding
ml/export_admin.py                ubah koleksi.json ke format tabel `collections` Web Admin
ml/data/sumber_qr.json            tautan PDF/YouTube hasil scan QR plakat + asal foto
ml/hasil/evaluasi.json            hasil evaluasi (untuk laporan)
assets/data/koleksi_serupa.json   hasil akhir yang dibaca aplikasi
```

## Cara menambah arca

1. Tambah satu objek di `assets/data/koleksi.json` (salin yang sudah ada).
   - `id` harus unik (string).
   - `fotoUrl`: taruh foto di `assets/images/` lalu isi `assets/images/nama.jpg`.
   - `videoUrl`: tautan YouTube. `pdfUrl`: tautan PDF (dibuka tombol "Baca PDF").
   - `pdfFile`: nama berkas PDF di `ml/data/pdf/` (untuk analisis teks).
2. Taruh PDF-nya di `ml/data/pdf/`.
3. Jalankan ulang skrip (lihat di bawah), lalu `flutter run`.

## Menjalankan

```bash
pip install -r ml/requirements.txt
python ml/build_serupa.py                  # pakai model terbaik yang terpasang
python ml/build_serupa.py --model tfidf    # paksa TF-IDF (tanpa unduh model)
```

Skrip mencetak sumber teks tiap arca (`pdf`, `txt`, atau `metadata`) dan hasil
evaluasi. Kalau ada arca bertanda `metadata`, rekomendasinya belum memakai
penjelasan detail, jadi hasilnya belum bagus.

### Memakai embedding (lebih baik untuk makna)

Embedding perlu `sentence-transformers` (membawa PyTorch, besar). Cara termudah:
**Google Colab**.

Buka `ml/koleksi_serupa_colab.ipynb` di Colab dan jalankan sel berurutan. Notebook itu
meminta `bahan.zip` (folder `ml/` + `assets/data/koleksi.json`), menjalankan TF-IDF lalu
embedding, dan mengunduh `koleksi_serupa.json` serta `evaluasi.json`. Timpa kedua berkas
itu di proyek, lalu `flutter test`.

## Bahan untuk laporan

- **Model:** TF-IDF + kemiripan kosinus (pembanding) dan
  `paraphrase-multilingual-MiniLM-L12-v2` (embedding kalimat, mendukung bahasa Indonesia).
- **Peran:** memberi rekomendasi "Koleksi serupa" di Detail Koleksi.
- **Data training:** tidak ada pelatihan ulang (model terlatih dipakai apa adanya);
  data masukan adalah teks PDF penjelasan tiap arca.
- **Evaluasi:** `precision@k` pada `ml/hasil/evaluasi.json`, yaitu porsi tetangga
  terdekat yang satu era dengan arca asal, dibandingkan dengan pilihan acak.
- **Integrasi:** JSON hasil dibaca `AssetSerupaRepository`, digabung dengan data arca
  oleh `KoleksiSerupaViewModel`, ditampilkan oleh `KoleksiSerupaSection`.

## Catatan

- Dengan hanya 6 arca dan teks singkat, hasilnya belum bermakna. Kualitas naik
  tajam setelah ada PDF penjelasan dan minimal sekitar 10–12 arca.
- PDF hasil scan (berupa gambar) tidak terbaca; skrip menandainya `pdf-kosong`
  dan perlu OCR dulu.

## Status data saat ini

- 13 arca asli (foto dari kunjungan museum, PDF dari QR plakat). Ringkasan hasil TF-IDF ada di
  `ml/hasil/evaluasi.json`; embedding belum dijalankan (perlu Colab).
- `avalokitesvara`: PDF hasil scan, teksnya ditranskripsi manual di `ml/data/teks/avalokitesvara.txt`.
- `ganesha-2` memakai PDF yang identik dengan `dewa-ganesha`, dan PDF `figur-wanita` berupa esai
  umum. Ganti dengan PDF yang benar bila ada.
- Era tiap arca adalah perkiraan dari isi PDF; periksa bersama pihak museum.
- Rencana integrasi dengan Web Admin: lihat `docs/integrasi-web-admin.md`.
