# Museum Mpu Purwa — Aplikasi Mobile

Aplikasi mobile untuk pengunjung **Museum Mpu Purwa** (Flutter, Android): katalog arca dan
prasasti, konfirmasi kunjungan lewat scan QR, booking rombongan, dan profil pengunjung.
Aplikasi ini pasangan dari Admin Web Museum Mpu Purwa (repo terpisah).

Desain acuan: `Museum_Mpu_Purwa_App.html` (mockup interaktif). Warna, font, ukuran, dan teks
diambil dari file itu.

## Menjalankan

```bash
flutter pub get
flutter run
```

Catatan:

- Font (Fraunces dan Karla) diunduh lewat `google_fonts` saat pertama kali dipakai, jadi
  jalankan pertama kali dengan internet aktif.
- Aplikasi belum memanggil backend. Semua data masih dummy (lihat bagian *Repository dummy*).
- Masuk di mode demo: kode OTP 4 digit apa pun diterima.

Perintah pemeriksaan:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Struktur folder

```
lib/
  main.dart                 titik masuk, memulihkan sesi login
  app.dart                  MaterialApp.router + Provider (state dan repository)
  core/                     fondasi bersama (milik Leader)
    theme/                  app_colors, app_text_styles, app_theme, app_dimens
    router/                 app_router, app_routes, main_shell (navbar)
    widgets/                komponen UI bersama
    network/                api_config, api_client (dio)
    constants/              app_images, museum_hours
    storage/                session_storage (shared_preferences)
    state/                  auth_controller, visit_status_controller, visitor_profile
  features/
    auth/                   Auth Gate, Login, Register, OTP        (Leader)
    home/                   Beranda                                (Leader)
    collections/            Katalog, Detail Koleksi                (Teman 1)
    info/                   Kunjungan & Lokasi                     (Teman 1)
    profile/                Profil Saya                            (Teman 1)
    visit/                  Scan QR, Kunjungan Tercatat            (Teman 2)
    booking/                Booking Rombongan, Status Booking      (Teman 2)
assets/images/              foto koleksi (diekstrak dari HTML desain)
```

## Pemilik folder

| Pemilik | Folder | Layar |
|---|---|---|
| **Leader** | `lib/core/`, `lib/features/auth/`, `lib/features/home/` | Auth Gate, Login, Register, OTP, Beranda, plus fondasi bersama |
| **Teman 1** | `lib/features/collections/`, `lib/features/info/`, `lib/features/profile/` | Katalog Koleksi, Detail Koleksi, Kunjungan & Lokasi, Profil Saya |
| **Teman 2** | `lib/features/visit/`, `lib/features/booking/` | Scan QR, Kunjungan Tercatat, Booking Rombongan, Status Booking |

### Aturan tim

1. **Kerjakan hanya folder `features/` milikmu.** Perubahan di `core/` dibicarakan dulu dengan Leader.
2. Layar milik Teman 1 dan Teman 2 sekarang berupa **placeholder** (`Scaffold` + judul + komentar
   `// TODO(Teman X): implementasi layar ini`). Ganti isinya, jangan ganti nama kelas atau
   path rutenya.
3. **Jam buka museum hanya boleh dibaca dari `core/constants/museum_hours.dart`**
   (Senin–Jumat 08.00–16.00, Sabtu–Minggu tutup, mengikuti admin web). Jangan menulis jam buka
   langsung di layar mana pun, dan jangan menyalin jam buka dari HTML (08.00–15.00, Senin tutup)
   karena sudah usang. Layar Info memakai `MuseumHours.rows` untuk kartu "Jam Operasional".
4. Jangan mengubah `Museum_Mpu_Purwa_App.html`.
5. Jangan menambah fitur di luar desain HTML.

## Rute dan navigasi

Semua path ada di `lib/core/router/app_routes.dart`. Pakai konstanta itu, bukan string manual:

```dart
context.go(AppRoutes.booking);
context.go(AppRoutes.koleksiDetail('ganesya')); // /koleksi/ganesya
context.go(AppRoutes.katalogDenganEra('Tumapel')); // /katalog?era=Tumapel
```

| Path | Layar | Pemilik |
|---|---|---|
| `/authgate`, `/login`, `/register`, `/otp` | alur auth (tanpa navbar) | Leader |
| `/beranda` | Beranda (tab) | Leader |
| `/katalog?era=` | Katalog Koleksi (tab) | Teman 1 |
| `/koleksi/:id` | Detail Koleksi | Teman 1 |
| `/info` | Kunjungan & Lokasi (tab) | Teman 1 |
| `/profil` | Profil Saya | Teman 1 |
| `/scan-qr` | Konfirmasi Kunjungan (tombol Scan di navbar) | Teman 2 |
| `/kunjungan-tercatat` | Kunjungan Tercatat | Teman 2 |
| `/booking` | Booking Rombongan (tab) | Teman 2 |
| `/status-booking` | Status Booking | Teman 2 |

- **Navbar**: Beranda, Katalog, [Scan], Booking, Info. Seperti di HTML, navbar tampil di semua
  layar setelah login. Tab hanya menyala di Beranda, Katalog, Booking, dan Info.
- **Berpindah layar**: pakai `context.go(...)`. Karena itu tombol kembali di layarmu memakai
  `AppTopBar(fallbackRoute: ...)` supaya tahu harus ke mana (di HTML: Detail kembali ke Katalog,
  layar lain kembali ke Beranda).
- **Guard login**: belum login hanya bisa ke `authgate/login/register/otp`; sudah login diarahkan
  ke `beranda`. Logout cukup `context.read<AuthController>().logout()`, router yang memindahkan layar.
- **Era di Katalog**: `?era=` berisi `Kanjuruhan`, `Tumapel`, `Singosari`, atau `Prasasti`.
  Baca lewat `GoRouterState.uri.queryParameters['era']` (sudah diteruskan ke `KatalogPage(era: ...)`).
  Saat Katalog sudah terbuka lalu `era` berubah, widget yang sama dibangun ulang, jadi tangani
  perubahan lewat `didUpdateWidget`.

### Mendaftarkan halaman baru

Edit `lib/core/router/app_router.dart`. Tambahkan `GoRoute` (path absolut) ke
`StatefulShellBranch` yang sesuai, atau konsultasikan dengan Leader bila perlu cabang baru:

```dart
GoRoute(
  path: AppRoutes.statusBooking,
  name: AppRoutes.statusBookingName,
  builder: (context, state) => const StatusBookingPage(),
),
```

## Komponen bersama (`lib/core/widgets/`)

| Widget | Fungsi | Padanan di HTML |
|---|---|---|
| `AppButton` (`primary`, `secondary`, `cream`, `outlineCream`) | tombol | `.btn-primary`, `.btn-secondary`, `.btn-cream`, `.btn-outline-cream` |
| `AppPillButton` | tombol pil emas + panah | `.hero-cta` |
| `AppTextField`, `AppTextFieldRow` | input + label, textarea (`maxLines: 3`), dua kolom | `.form-group`, `.form-row2` |
| `AppTopBar`, `CircleIconButton` | bar atas dengan tombol kembali, tombol ikon bulat | `.topbar`, `.iconbtn` |
| `AppCard`, `CardHeader`, `HoursRow`, `InfoBar` | kartu, kepala kartu, baris jam, kotak info | `.card`, `.card-head`, `.hours-row`, `.infobar` |
| `SectionHead` | judul bagian + tautan "Lihat semua" | `.section-head` |
| `EraChip`, `EraBadge`, `EraOverlayBadge` | chip filter dan badge era | `.chip`, `.feat-badge`, `.detail-badge` |
| `LinkRow` | baris tautan dengan panah | `.link-row` |

Warna, font, dan ukuran: `AppColors`, `AppTextStyles` (`serif()` untuk Fraunces, `sans()` untuk
Karla), `AppDimens`. Jangan menulis kode warna atau ukuran font langsung di layar.

```dart
AppTopBar(title: 'Booking Rombongan', titleSize: 17, fallbackRoute: AppRoutes.beranda)
AppButton(label: 'Kirim', onPressed: () {})
Text('Judul', style: AppTextStyles.sectionTitle)
```

## State bersama

- `AuthController` (`context.watch<AuthController>()`): `isLoggedIn`, `profile` (`VisitorProfile`),
  `login()`, `logout()`, `updateProfile(...)`. Sesi tersimpan di perangkat. Data pengguna saat ini
  dummy (Amanda Putri, sesuai HTML).
- `VisitStatusController`: `visitRecordedToday`. **Teman 2** memanggil
  `context.read<VisitStatusController>().markVisitRecorded()` saat scan QR berhasil; banner di
  Beranda otomatis berubah menjadi "Kunjungan hari ini tercatat."

## Repository dummy

Layar tidak boleh memegang data statis sendiri. Data diambil lewat repository (antarmuka abstrak
+ implementasi dummy) yang disediakan di `app.dart` lewat `Provider`. Contoh yang sudah ada:
`features/home/data/home_repository.dart` (`HomeRepository` dan `DummyHomeRepository`).

```dart
// di layar:
final repo = context.read<HomeRepository>();
final content = await repo.loadContent();
```

Pola untuk layarmu: buat `xxx_repository.dart` berisi `abstract class XxxRepository` dan
`DummyXxxRepository` dengan data dari HTML, daftarkan di `app.dart`. Saat backend untuk aplikasi
mobile siap, buat implementasi yang memakai `ApiClient` (`core/network/`) dan ganti satu baris
di `app.dart`; UI tidak perlu diubah.

Kontrak dengan layar lain: **id koleksi** (`ganesya`, `brahma`, `catur`, `makara`, `prasasti`,
`nandi`) dipakai untuk membuka `/koleksi/:id`. Beranda hanya memakai model kecilnya sendiri
(`FeaturedCollection`); model koleksi lengkap milik Teman 1.

## Aset gambar

Foto koleksi ada di `assets/images/` dan konstanta path-nya di `lib/core/constants/app_images.dart`.
Aset sudah terdaftar di `pubspec.yaml`.
