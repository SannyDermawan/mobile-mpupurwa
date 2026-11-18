# Penerapan MVVM pada Aplikasi Museum Mpu Purwa

> Bahan presentasi — Pemrograman Mobile, materi *App Architecture & Design Patterns*.
> Buka file ini di VS Code, lalu tekan `Ctrl+Shift+V` (Preview). Sambil presentasi,
> tampilkan juga **Explorer** (`Ctrl+Shift+E`) untuk menunjukkan struktur foldernya.

---

## 1. Ringkasan (30 detik)

Aplikasi Museum Mpu Purwa sebelumnya sudah memakai `Provider`, tetapi logika masih menumpuk
di dalam widget: data dummy katalog, validasi form, filter pencarian, dan timer OTP semuanya
ditulis di `State` milik halaman. Sekarang seluruh aplikasi disusun dengan **MVVM + Repository**
dan struktur **feature-first**, sesuai panduan arsitektur resmi Flutter yang dibahas di materi.

| Yang dipindahkan | Dari | Ke |
|---|---|---|
| Data dummy koleksi | `State` halaman Katalog | `KoleksiRepository` |
| Filter pencarian + era | `setState` di Katalog | `KatalogViewModel` |
| Validasi form booking (peserta, HP, tanggal) | `State` halaman Booking | `BookingViewModel` |
| Hitung mundur + validasi OTP | `State` halaman OTP | `OtpViewModel` |
| Simpan sesi login | `AuthController` + `SessionStorage` langsung | `AuthViewModel` → `AuthRepository` |
| Buka tautan (peta, telepon, PDF) | `url_launcher` di widget | `LinkLauncher` (service) dipakai ViewModel |

Hasil terukur:

- **12 ViewModel**, **5 Repository** (antarmuka + implementasi), 6 Model.
- **54 test lulus**, 22 di antaranya test ViewModel murni tanpa widget (`test/viewmodel/`).
- `flutter analyze`: tanpa error dan tanpa warning.

---

## 2. Dasar teori (dari materi dosen)

**Empat prinsip** (slide *Prinsip Dasar*) dan di mana wujudnya di aplikasi:

| Prinsip | Wujud di aplikasi |
|---|---|
| Separation of Concerns | View hanya menampilkan, ViewModel mengelola state, Repository mengurus data |
| Single Source of Truth | Sesi login hanya dimiliki `AuthRepository`; daftar booking hanya dimiliki `BookingRepository` |
| Unidirectional Data Flow | State mengalir ke bawah (ViewModel → View), event mengalir ke atas (View → ViewModel) |
| Dependency Inversion | ViewModel bergantung pada `abstract class XxxRepository`, bukan implementasinya |

**Lapisan menurut panduan Flutter** (slide *Lapisan menurut panduan arsitektur Flutter*):

```
┌────────────────────────── UI layer ──────────────────────────┐
│  View (widget)   ◄── state ──   ViewModel (ChangeNotifier)   │
│  Page + widgets  ── event ──►   state layar + logika layar   │
└──────────────────────────────┬───────────────────────────────┘
                               │ memanggil (lewat antarmuka)
┌──────────────────────────────▼───────────────────────────────┐
│ Data layer                                                   │
│  Repository (abstract + implementasi)  ──►  Service / sumber │
│  mis. KoleksiRepository                     data: API, lokal │
└──────────────────────────────────────────────────────────────┘
```

Layer **Domain / use case** bersifat opsional pada materi ("boleh dilewati di aplikasi kecil"),
jadi sengaja **tidak** dibuat. Alasannya ada di bagian 9.

---

## 3. Pemetaan komponen (seperti soal latihan di materi)

Materi membahas latihan "Tentukan komponennya!". Berikut pemetaan yang sama untuk aplikasi museum:

| Aktivitas | Komponen | File |
|---|---|---|
| Mendefinisikan atribut `id, nama, era, asal, periode, ...` pada koleksi | **Model** | `features/collections/model/koleksi_model.dart` |
| Menampilkan `TextField` pencarian dan chip era | **View** | `features/collections/view/katalog_page.dart` |
| Menerima ketikan pencarian, menyimpan era terpilih, menghitung daftar yang tampil | **ViewModel** | `features/collections/viewmodel/katalog_view_model.dart` |
| Mengambil daftar koleksi dari sumber data | **Repository** | `features/collections/repository/koleksi_repository.dart` |
| Menyimpan sesi login ke penyimpanan perangkat | **Repository** → Service | `features/auth/repository/local_auth_repository.dart` → `core/storage/session_storage.dart` |
| Memvalidasi jumlah peserta (2–500) dan format nomor HP | **ViewModel** | `features/booking/viewmodel/booking_view_model.dart` |
| Membuka tautan Google Maps / telepon | **Service** (dipanggil ViewModel) | `core/services/link_launcher.dart` |

---

## 4. Alur data: contoh fitur Katalog

```
 Pengguna mengetik "arca"
        │
        ▼
 [View]       KatalogScreen  ── onChanged ──►  vm.search('arca')
                                                     │
 [ViewModel]  KatalogViewModel                       ▼
                _query = 'arca'  →  notifyListeners()
                filtered = _all.where(nama & era cocok)
                                                     │
        ▲                                            │
        └──── context.watch<KatalogViewModel>() ◄────┘   (View di-rebuild otomatis)

 Saat layar dibuka:
 [ViewModel] load() ──► [Repository] KoleksiRepository.fetchAll()
                              └─ DummyKoleksiRepository (sekarang) / API (nanti)
```

Satu arah: **View → ViewModel → Repository**, dan **state kembali ke View lewat `notifyListeners()`**.

---

## 5. Struktur folder (tampilkan di VS Code Explorer)

Aturan sederhananya: **satu folder per fitur, di dalamnya empat folder sesuai peran MVVM.**

```
lib/
├── main.dart                         titik masuk, memulihkan sesi login
├── app.dart                          composition root: semua dependensi dirakit di sini
├── core/                             fondasi bersama (bukan milik satu fitur)
│   ├── constants/                    app_images, museum_hours
│   ├── network/                      api_client, api_config          (Service, siap untuk API)
│   ├── router/                       app_router, app_routes, main_shell
│   ├── services/                     link_launcher                   (Service)
│   ├── storage/                      session_storage                 (Service)
│   ├── theme/                        warna, font, tema
│   ├── utils/                        tanggal_format
│   └── widgets/                      tombol, kartu, navbar, dst.
└── features/
    ├── auth/
    │   ├── model/                    visitor_profile
    │   ├── repository/               auth_repository, local_auth_repository
    │   ├── viewmodel/                auth, login, register, otp
    │   └── view/                     auth_gate, login, register, otp (+ widgets/)
    ├── home/
    │   ├── model/                    home_models
    │   ├── repository/               home_repository (+ DummyHomeRepository)
    │   ├── viewmodel/                home_view_model
    │   └── view/                     beranda_page (+ widgets/)
    ├── collections/
    │   ├── model/                    koleksi_model
    │   ├── repository/               koleksi_repository, dummy_koleksi_repository
    │   ├── viewmodel/                katalog_view_model, koleksi_detail_view_model
    │   └── view/                     katalog_page, koleksi_detail_page
    ├── booking/
    │   ├── model/                    booking_model
    │   ├── repository/               booking_repository (+ InMemoryBookingRepository)
    │   ├── viewmodel/                booking_view_model
    │   └── view/                     booking_page, status_booking_page
    ├── visit/
    │   ├── model/                    visit_record
    │   ├── repository/               visit_repository (+ InMemoryVisitRepository)
    │   ├── viewmodel/                visit_status_view_model, kunjungan_tercatat_view_model
    │   └── view/                     scan_qr_page, kunjungan_tercatat_page
    ├── profile/
    │   ├── viewmodel/                profile_view_model
    │   └── view/                     profile_page
    └── info/
        ├── model/                    museum_info
        ├── viewmodel/                info_view_model
        └── view/                     info_page

test/
├── viewmodel/viewmodel_test.dart     22 test ViewModel murni (tanpa widget)
├── beranda_flow_test.dart            alur Login → OTP → Beranda, navbar, banner
├── booking_visit_test.dart           form Booking, Status Booking, Scan QR
├── profile_flow_test.dart            Profil dan keluar akun
├── museum_hours_test.dart            jam buka
└── widget_test.dart                  smoke test aplikasi
```

Folder `repository/` tidak ada di `profile` dan `info` karena memang tidak ada data yang
perlu diambil: `profile` memakai sesi dari `AuthViewModel`, `info` memakai data statis `MuseumInfo`.

---

## 6. Sebelum dan sesudah

Contoh paling jelas: halaman **Katalog**.

**Sebelum** — satu `State` mengurus semuanya (data, filter, dan tampilan) di satu file 324 baris:

```dart
class _KatalogScreenState extends State<KatalogScreen> {
  List<Koleksi> _allKoleksi = [];
  List<Koleksi> _filteredKoleksi = [];

  void _loadDummyData() {
    _allKoleksi = [ Koleksi(id: '1', nama: 'Arca Ganesya Tikus', ...), ... ];   // data
    _applyFilter();
  }

  void _applyFilter() {
    setState(() { _filteredKoleksi = _allKoleksi.where(...).toList(); });       // logika
  }
  // ... lalu build() yang menampilkan semuanya
}
```

**Sesudah** — tiga file dengan tugas masing-masing:

```dart
// Repository  — dari mana data berasal
abstract class KoleksiRepository {
  Future<List<Koleksi>> fetchAll();
}

// ViewModel   — state dan logika layar (tanpa import widget)
class KatalogViewModel extends ChangeNotifier {
  KatalogViewModel(this._repository, {String? initialEra});
  List<Koleksi> get filtered => ...;          // pencarian + filter era
  Future<void> load() async { ... }
  void search(String query) { ...; notifyListeners(); }
  void selectEra(String era) { ...; notifyListeners(); }
}

// View        — hanya menampilkan
final vm = context.watch<KatalogViewModel>();
TextField(onChanged: vm.search);
GridView.builder(itemCount: vm.filtered.length, ...);
```

Ringkasan per fitur:

| Fitur | Logika yang keluar dari View |
|---|---|
| Auth (Login/Register/OTP) | aturan validasi, state persetujuan, hitung mundur OTP, proses verifikasi |
| Beranda | pemuatan data dan state memuat/gagal (`FutureBuilder` + `setState` diganti `HomeViewModel`) |
| Katalog | data dummy, pencarian, filter era, dukungan `?era=` |
| Detail Koleksi | teks cadangan bila data kosong, pembukaan tautan video/PDF |
| Booking | validasi, aturan tanggal kunjungan, penyimpanan pengajuan |
| Kunjungan | status kunjungan hari ini dan riwayat |
| Profil | data diri dari sesi, riwayat, aksi keluar akun |
| Info | jam operasional, alamat, kontak, pembukaan tautan |

---

## 7. Dependency Injection: `app.dart`

Semua dependensi dirakit di **satu tempat**. Mengganti data dummy dengan API cukup mengubah
baris di sini; ViewModel dan View tidak ikut berubah.

```dart
MultiProvider(
  providers: [
    // Service & Repository (lapisan data)
    Provider<HomeRepository>.value(value: widget.homeRepository ?? const DummyHomeRepository()),
    Provider<KoleksiRepository>.value(value: widget.koleksiRepository ?? const DummyKoleksiRepository()),
    Provider<VisitRepository>.value(value: _visitRepository),
    Provider<LinkLauncher>.value(value: widget.linkLauncher ?? const UrlLauncherService()),

    // ViewModel yang dipakai banyak layar (lapisan UI)
    ChangeNotifierProvider<AuthViewModel>.value(value: widget.authViewModel),
    ChangeNotifierProvider<VisitStatusViewModel>(create: ...),
    ChangeNotifierProvider<BookingViewModel>(create: ...),
  ],
  ...
)
```

- ViewModel milik **satu layar** (`KatalogViewModel`, `OtpViewModel`, `HomeViewModel`, ...)
  dibuat oleh layarnya sendiri lewat `ChangeNotifierProvider` dan ikut dibuang saat layar ditutup.
- Di `main.dart`: `AuthViewModel(LocalAuthRepository(storage))` — repository disuntikkan dari luar.

---

## 8. Pengujian

Keuntungan utama MVVM (slide *Kelebihan*: "logika di ViewModel bisa diuji tanpa UI"):
ViewModel diuji dengan **repository palsu**, tanpa widget, tanpa emulator.

```dart
test('pencarian tidak peka huruf besar-kecil dan digabung dengan era', () async {
  final vm = KatalogViewModel(_FakeKoleksiRepository());   // repository palsu
  await vm.load();

  vm.search('arca');
  expect(vm.filtered, hasLength(2));

  vm.selectEra('Kanjuruhan');
  expect(vm.filtered.map((k) => k.nama), ['Arca Brahma']);
});
```

Jalankan:

```bash
flutter test                         # 54 test
flutter test test/viewmodel          # hanya test ViewModel
flutter analyze                      # tanpa error dan warning
```

---

## 9. Pertanyaan yang mungkin ditanyakan dosen

**Kenapa memakai `Provider`, bukan Riverpod atau Bloc?**
Pada materi `provider` berstatus "cukup untuk aplikasi kecil". Aplikasi ini kecil (7 fitur,
13 layar), dan **`ChangeNotifier` + `Provider` adalah kombinasi yang dipakai contoh resmi
panduan arsitektur Flutter** untuk MVVM. Karena ViewModel hanya bergantung pada `Listenable`
dan repository lewat konstruktor, migrasi ke Riverpod nanti tinggal mengganti cara
menyediakan ViewModel, bukan menulis ulang logikanya.

**Kenapa tidak pakai Clean Architecture (domain/data/presentation)?**
Menurut materi, domain layer / use case "boleh dilewati di aplikasi kecil", dan Clean
Architecture punya kekurangan "banyak boilerplate untuk fitur sederhana". Belum ada logika bisnis
yang dipakai ulang banyak ViewModel, jadi lapisan itu belum memberi manfaat. Struktur sekarang
mudah ditingkatkan: `repository/` sudah berupa antarmuka (Dependency Inversion).

**Kenapa halaman Profil dan Info tidak punya Repository?**
Repository dibuat untuk **sumber data**. Profil memakai sesi yang sudah dimiliki `AuthRepository`;
Info memakai data statis. Membuat repository kosong hanya menambah kelas tanpa fungsi.

**Masih ada `setState` di View. Apakah itu melanggar MVVM?**
Tidak. Materi (slide *Dua jenis state*) membedakan *ephemeral state* dan *app state*. Yang masih
memakai `setState` hanya state milik satu widget: controller teks, tanggal yang sedang dipilih
di form, dan node era yang sedang terbuka di linimasa Beranda. State yang dibagi antar-layar
atau perlu diuji sudah ada di ViewModel.

**Apakah View boleh mengenal Repository?**
View tidak memanggil method Repository sama sekali. Tiga halaman (Beranda, Katalog, Profil)
hanya mengambil repository dari `Provider` untuk **menyuntikkannya ke ViewModel** saat
ViewModel dibuat. Pemanggilan data tetap lewat ViewModel.

**Datanya masih dummy?**
Ya. Backend aplikasi mobile belum ada. Karena itulah repository dibuat berupa antarmuka:
`DummyKoleksiRepository` / `InMemoryBookingRepository` nanti diganti implementasi berbasis
`ApiClient` (sudah ada di `core/network/`) tanpa mengubah ViewModel atau View.

---

## 10. Skenario demo (±5 menit)

1. **Struktur** — buka Explorer, buka `lib/features/collections/`, tunjukkan `model` → `repository`
   → `viewmodel` → `view`.
2. **Satu fitur lengkap (Katalog)**
   - `view/katalog_page.dart`: hanya ada `context.watch<KatalogViewModel>()` dan widget.
   - `viewmodel/katalog_view_model.dart`: getter `filtered`, `search`, `selectEra`; **tidak ada import widget**.
   - `repository/koleksi_repository.dart` + `dummy_koleksi_repository.dart`: antarmuka dan data.
3. **DI** — buka `lib/app.dart`, tunjuk blok `MultiProvider`.
4. **Uji** — jalankan di terminal: `flutter test test/viewmodel` (22 test lulus tanpa emulator).
5. **Aplikasi** — `flutter run`: Login → OTP → Beranda, cari "arca" di Katalog, isi form Booking
   dengan nomor HP salah untuk menunjukkan validasi dari `BookingViewModel`.

---

## 11. Batasan yang jujur disampaikan

- Data masih dummy; belum ada panggilan ke backend.
- Rute `/koleksi/:id` belum memuat detail berdasarkan id (detail dibuka dari Katalog dengan objek
  `Koleksi`), jadi dari kartu "Koleksi Unggulan" di Beranda saat ini jatuh ke Katalog. Id di Beranda
  (`ganesya`, `brahma`) juga belum sama dengan id di Katalog (`'1'`, `'2'`).
- Belum ada domain layer / use case (sengaja, lihat bagian 9).
- Folder `core/network/api_client.dart` sudah siap tetapi belum dipanggil dari repository mana pun.
