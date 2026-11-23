# Rencana integrasi aplikasi dengan Web Admin

Hasil pembacaan repositori `website-admin-museum-mpu-purwa` (Express + Prisma + MySQL,
frontend Next.js). Dokumen ini menjadi bahan kerja minggu depan.

## 1. Apa yang sudah cocok

| Aplikasi mobile | Web Admin (`Collection` di Prisma) | Catatan |
|---|---|---|
| `nama` | `name` | |
| `era` (KANJURUHAN, TUMAPEL, SINGOSARI) | `era` (`Kanjuruhan`, `Tumapel`, `Singosari`, `Majapahit`, `Prasasti`) | Aplikasi membandingkan era tanpa peduli huruf besar-kecil, jadi aman. |
| `periode` | `period` | |
| `asal` | `origin` | |
| `material` | `material` | |
| `ukuran` | `dimensions` | Baru terisi untuk 6 arca yang plakatnya terbaca jelas. |
| `sejarah` | `meaning` | |
| `fotoUrl` | `photoUrl` | Di admin berupa tautan Vercel Blob. Di aplikasi sekarang jalur `assets/…`. |
| `videoUrl` | `videoUrl` | Tautan YouTube, sama. |
| `pdfUrl` | `pdfUrl` | Di admin berupa tautan Vercel Blob. Di aplikasi sekarang tautan Google Drive. |

`KoleksiImage` sudah menampilkan alamat `assets/…` dari aset dan alamat lain dari internet,
jadi foto dari Vercel Blob bisa langsung dipakai tanpa mengubah tampilan.

`python ml/export_admin.py` membuat `ml/hasil/koleksi_untuk_admin.json` berisi 13 arca dengan
nama kolom persis seperti tabel `collections`, siap dijadikan bahan seed atau input manual.

## 2. Yang belum ada di Web Admin (pekerjaan minggu depan)

1. **Endpoint publik untuk aplikasi.** Semua `/api/collections` dilindungi `requireAuth`
   (cookie admin). Aplikasi mobile tidak punya cookie itu. Perlu rute baca-saja, misalnya
   `GET /api/public/collections` dan `GET /api/public/collections/:id`, tanpa login.
   Jangan membuka `POST/PATCH/DELETE`.
2. **Endpoint tulis dari aplikasi** untuk modul yang sudah ada di dashboard admin:
   - pendaftaran akun pengunjung (`VisitorAccount`) dan login pengunjung,
   - check-in setelah scan QR (`Visit`),
   - pengajuan booking rombongan (`Booking`, status awal `pending`).
   Sekarang sesi login disimpan lokal (`SharedPreferences`), sedangkan kunjungan dan booking hanya di memori (`InMemoryVisitRepository`, `InMemoryBookingRepository`) dan hilang saat aplikasi ditutup.
3. **CORS.** `app.ts` hanya mengizinkan `FRONTEND_URL`. Aplikasi native tidak terkena CORS,
   tetapi kalau diuji lewat Flutter Web perlu origin tambahan.
4. **Id koleksi.** Di admin `id` berupa angka otomatis (`Int`), di aplikasi berupa teks
   (`brahma`, `ganesha-1`, …). Setelah aplikasi membaca dari API, `Koleksi.id` menjadi
   angka (dibaca sebagai teks) dan `assets/data/koleksi_serupa.json` harus dibuat ulang
   dengan id tersebut (lihat bagian 3).

## 3. Fitur "Koleksi serupa" setelah terhubung ke admin

Rekomendasi dihitung di komputer, bukan di server, dan tidak berubah selama isi PDF tidak
berubah. Jadi urutan kerjanya:

1. Admin menambah/mengubah koleksi dan mengunggah PDF lewat Manajemen Koleksi.
2. Ekspor daftar koleksi dari API ke `koleksi.json` (id = id dari database, `pdfFile` = nama
   berkas PDF yang diunduh ke `ml/data/pdf/`).
3. `python ml/build_serupa.py` (atau versi embedding di Colab) menghasilkan
   `koleksi_serupa.json`.
4. Berkas itu dipasang sebagai aset, atau (lebih baik) diunggah ke server dan disajikan lewat
   `GET /api/public/collections/:id/serupa` supaya admin tidak perlu merilis ulang aplikasi.

Tahap 2 sampai 4 bisa dijadikan satu skrip atau tombol "Hitung ulang rekomendasi" di admin
bila waktunya cukup. Untuk UAS, cukup tahap manual.

## 4. Urutan pengerjaan yang disarankan

1. Seed 13 arca ke database dari `ml/hasil/koleksi_untuk_admin.json`; unggah foto dan PDF lewat
   halaman Manajemen Koleksi supaya `photoUrl`/`pdfUrl` menjadi tautan Vercel Blob.
2. Tambah rute publik baca-saja untuk koleksi di backend.
3. Buat `ApiKoleksiRepository` di aplikasi (`lib/features/collections/repository/`) yang
   mengimplementasikan `KoleksiRepository`, lalu ganti satu baris di `lib/main.dart`.
   ViewModel dan tampilan tidak perlu diubah, itulah gunanya pola Repository.
4. Hubungkan akun, check-in, dan booking dengan cara yang sama (satu repository per fitur).
5. Hitung ulang rekomendasi dengan id dari database.
