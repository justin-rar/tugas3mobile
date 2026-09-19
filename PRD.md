# PRD — Aplikasi "Hari Baik" (Flutter + Supabase)

Mata kuliah: Pemrograman Aplikasi Mobile · Deadline: Senin, 21 September 2026
Dokumen ini adalah sumber kebenaran (source of truth) untuk agent yang membangun aplikasi. Ikuti semua bagian, terutama **Bagian 8 (Error Handling)** dan **Bagian 11 (Definition of Done)**.

---

## 1. Ringkasan Produk

**Hari Baik** adalah aplikasi mobile (Android) untuk menghitung weton, kecocokan, dan kebaikan tanggal acara berdasarkan primbon Jawa, serta mengonversi tanggal ke kalender Hijriah, Weton, dan Saka Bali. Pengguna login, menyimpan data orang dan rencana acara di database, dan memakai fitur pendukung (kalkulator umur, stopwatch).

Aplikasi dibuat untuk memenuhi tugas kuliah dengan persyaratan berikut (semuanya WAJIB):
1. Terkoneksi ke database dan memiliki tema (tema: hari baik / primbon Jawa).
2. Memiliki login dengan session.
3. Halaman utama berisi **6 menu vertikal di tengah layar**: Daftar Anggota, Komputasi sesuai tema, CRUD sesuai tema, Konversi Hijriah, Konversi tanggal lahir ke umur (tahun, bulan, hari, jam, menit, detik), Konversi Kalender Weton dan Saka Bali.
4. **Bottom Navigation Bar 3 menu**: Beranda, Stopwatch, Bantuan (berisi cara penggunaan + tombol Logout).
5. Ada laporan pembuatan aplikasi (dikerjakan orang lain, bukan bagian PRD ini, tapi aplikasi harus mudah di-screenshot).

## 2. Tujuan & Bukan Tujuan

**Tujuan:** semua persyaratan di atas berjalan stabil, UI rapi, tidak crash, dan semua kegagalan ditangani dengan pesan yang jelas.

**Bukan tujuan (jangan dikerjakan):** iOS/web, notifikasi push, mode offline penuh, kalender lunar Bali lengkap (sasih, penanggal/panglong), pembayaran, multi-bahasa (cukup Bahasa Indonesia), login sosial (Google, dll).

## 3. Pengguna & Skenario Utama

Pengguna: mahasiswa/dosen penilai dan orang awam yang ingin mengecek weton.
1. Daftar/login → masuk Beranda.
2. Tambah data orang (nama + tanggal lahir) → weton dan neptu dihitung otomatis.
3. Cek kecocokan dua orang atau cek tanggal acara → lihat hasil (Pegat/Ratu/Jodoh/dst).
4. Simpan rencana acara beserta hasilnya (CRUD).
5. Konversi tanggal ke Hijriah, Weton, Saka Bali; hitung umur; pakai stopwatch.
6. Buka Bantuan → baca panduan → Logout.

## 4. Tech Stack & Konstanta

- Flutter (stable terbaru), Dart, Material 3, **hanya Android** yang wajib jalan.
- Backend: **Supabase** (Auth email+password, PostgreSQL). Package: `supabase_flutter`.
- Package lain: `hijri` (Hijriah), `intl` (format tanggal, locale `id_ID`), `flutter_dotenv` (konfigurasi).
- State management: sederhana dan konsisten. Gunakan `StatefulWidget` + service class, atau `provider` jika perlu. **Jangan** memakai kombinasi banyak state manager.
- Kunci API: simpan di `.env` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`), masukkan `.env` ke `.gitignore`, sediakan `.env.example`. **Dilarang hardcode kunci di kode.**
- File referensi yang sudah tersedia dan HARUS dipakai (jangan tulis ulang rumusnya kecuali ada bug):
  - `schema.sql` → skema database + RLS + data awal.
  - `kalender_util.dart` → logika weton, wuku, Saka Bali, umur, hari baik. Letakkan di `lib/utils/kalender_util.dart`.

## 5. Struktur Folder

```
lib/
  main.dart                 // init dotenv, Supabase, error handler global, AuthGate
  core/
    app_exception.dart      // sealed class exception aplikasi
    error_handler.dart      // mapping error -> pesan Indonesia
    result_state.dart       // state loading/empty/error/data (opsional)
    constants.dart
  utils/
    kalender_util.dart
    validators.dart
  services/
    auth_service.dart
    orang_service.dart
    acara_service.dart
    anggota_service.dart
    aturan_service.dart
  screens/
    auth/login_screen.dart, register_screen.dart
    shell/main_shell.dart           // Scaffold + BottomNavigationBar
    home/home_screen.dart           // 6 menu
    anggota/anggota_screen.dart
    hari_baik/hari_baik_screen.dart
    crud/orang_list_screen.dart, orang_form_screen.dart,
         acara_list_screen.dart, acara_form_screen.dart
    hijriah/hijriah_screen.dart
    umur/umur_screen.dart
    kalender/kalender_screen.dart   // weton + Saka Bali
    stopwatch/stopwatch_screen.dart
    bantuan/bantuan_screen.dart
  widgets/
    app_button.dart, loading_view.dart, error_view.dart, empty_view.dart
```

## 6. Model Data

Gunakan tabel di `schema.sql`: `anggota`, `aturan_hari_baik`, `orang`, `rencana_acara`. Buat model Dart (`fromMap`/`toMap`) untuk tiap tabel. Kolom `user_id` diisi otomatis oleh database (`default auth.uid()`), jadi jangan dikirim dari aplikasi. Semua query CRUD otomatis terbatas pada data milik user karena RLS.

## 7. Persyaratan Fungsional

### F1. Autentikasi & Session
- Register: email, password (min. 6 karakter), konfirmasi password. Login: email + password.
- **Session:** setelah login, sesi dipulihkan otomatis saat aplikasi dibuka ulang. `AuthGate` di `main.dart` memeriksa `Supabase.instance.client.auth.currentSession`: ada → `MainShell`, tidak ada → `LoginScreen`. Dengarkan `onAuthStateChange` untuk otomatis pindah ke Login saat sesi berakhir.
- Logout memanggil `signOut()` lalu kembali ke Login dan menghapus stack navigasi.
- **Acceptance criteria:**
  - Tutup dan buka ulang aplikasi setelah login → langsung masuk Beranda tanpa login lagi.
  - Setelah logout → tidak bisa kembali ke halaman dalam dengan tombol Back.
  - Semua error auth ditampilkan dengan pesan Indonesia (lihat Bagian 8).

### F2. Beranda (menu utama)
- Judul + sapaan singkat (email pengguna).
- **6 tombol/kartu besar disusun vertikal dan berada di tengah layar** (`Center` + `Column`, bisa di-scroll jika layar kecil): Daftar Anggota, Hitung Hari Baik, Data Orang & Acara, Konversi Hijriah, Kalkulator Umur, Kalender Weton & Saka Bali.
- Tiap tombol membuka layar terkait; Bottom Navigation tetap terlihat.

### F3. Daftar Anggota
- Membaca tabel `anggota` (nama, NIM, peran), tampil sebagai list. Ada pull-to-refresh.
- Tampilkan empty state jika kosong dan error state + tombol "Coba lagi" jika gagal.

### F4. Hitung Hari Baik (komputasi)
Dua mode (tab atau segmented button):
- **Kecocokan dua orang:** pilih/isi dua tanggal lahir (bisa memilih dari data `orang`) → total neptu → hasil.
- **Cek tanggal acara:** pilih satu orang + tanggal acara → hasil.
- Aturan: `sisa = totalNeptu % 8`; sisa 0 dianggap 8. Hasil: 1 Pegat, 2 Ratu, 3 Jodoh, 4 Topo, 5 Tinari, 6 Padu, 7 Sujanan, 8 Pesthi. **Baik:** 2, 3, 5, 6, 8; **kurang baik:** 1, 4, 7. Arti tiap hasil dibaca dari tabel `aturan_hari_baik`. Jika gagal dimuat, pakai teks fallback lokal dan tetap tampilkan hasil.
- Tampilkan rincian: weton dan neptu masing-masing, total, sisa, nama hasil, arti, dan badge Baik/Kurang Baik.
- Tombol "Simpan sebagai rencana acara" (mode acara) → menyimpan ke `rencana_acara`.
- Footer kecil: "Hasil berdasarkan primbon tradisional, bukan kepastian."

### F5. CRUD (Data Orang & Acara)
Halaman punya dua tab: **Orang** dan **Acara**.
- **Orang:** Create (nama, tanggal lahir → hari, pasaran, neptu dihitung otomatis dan disimpan), Read (list, urut terbaru, tampilkan weton + neptu), Update (edit nama/tanggal lahir, hitung ulang weton), Delete (dengan dialog konfirmasi).
- **Acara:** Create (pilih orang opsional, jenis acara: Pernikahan/Pindah Rumah/Usaha/Lainnya, tanggal acara, catatan; hasil hari baik dihitung otomatis), Read, Update, Delete (konfirmasi).
- Validasi form lihat Bagian 8.4. Setelah create/update/delete: tampilkan SnackBar sukses dan refresh list.

### F6. Konversi Hijriah
- Pilih tanggal Masehi (default hari ini) → tampilkan tanggal Hijriah (`hari nama-bulan tahun H`) memakai package `hijri`.
- Catat di layar (teks kecil) bahwa hasil bisa berbeda 1 hari dari penetapan Kemenag.

### F7. Kalkulator Umur
- Input tanggal lahir (+ jam lahir opsional, default 00:00).
- Output: **tahun, bulan, hari, jam, menit, detik** memakai `KalenderUtil.hitungUmur`, diperbarui tiap 1 detik dengan `Timer.periodic`.
- Timer wajib di-`cancel` di `dispose()`, dan `setState` hanya jika `mounted`.
- Tampilkan juga total hari hidup (opsional).

### F8. Kalender Weton & Saka Bali
- Pilih tanggal → tampilkan: hari, pasaran (weton), neptu hari + neptu pasaran + total, wuku; serta Saka Bali: tahun Saka, saptawara, pancawara, wuku. Pakai `KalenderUtil.hitungWeton` dan `hitungSakaBali`.
- Catatan di layar: Saka Bali adalah versi sederhana (tahun Saka + wewaran + wuku), bukan kalender lunar lengkap.

### F9. Stopwatch (Bottom Nav)
- Tombol Start/Pause, Reset, dan Lap (daftar lap). Tampilan `mm:ss.SS`.
- Memakai kelas `Stopwatch` Dart + `Timer.periodic` (tiap ~30 ms). Timer di-cancel di `dispose()`. Tidak boleh terus berjalan bocor di background saat layar dihancurkan.
- Catatan: memakai `IndexedStack` pada shell agar state stopwatch tidak hilang saat pindah tab.

### F10. Bantuan (Bottom Nav)
- Berisi panduan penggunaan tiap menu (teks ringkas, bisa `ExpansionTile`), keterangan singkat metode hitung, dan tombol **Logout** (dengan dialog konfirmasi).

### F11. Bottom Navigation Bar
- 3 item persis: **Beranda**, **Stopwatch**, **Bantuan**. Ikon + label. Sub-halaman menu (F3-F8) dibuka lewat `Navigator.push` di atas shell.

## 8. Error Handling (WAJIB)

### 8.1 Prinsip
1. **Aplikasi tidak boleh crash** karena error yang bisa diprediksi. Tidak ada exception yang lolos tanpa penanganan.
2. **Jangan pernah menampilkan pesan mentah/stack trace ke pengguna.** Tampilkan pesan Bahasa Indonesia yang ramah; detail teknis hanya lewat `debugPrint`.
3. Setiap operasi async punya tiga keadaan yang ditangani: **loading, error, sukses** (plus **empty** untuk list).
4. Tombol aksi dinonaktifkan selama loading (cegah double submit).
5. Semua panggilan jaringan diberi **timeout 15 detik**.
6. Setelah `await`, cek `if (!mounted) return;` sebelum memakai `context`/`setState`.

### 8.2 Arsitektur penanganan error
- `core/app_exception.dart`: `sealed class AppException implements Exception { final String message; }` dengan subclass: `NetworkException`, `AuthFailure`, `DatabaseFailure`, `ValidationFailure`, `NotFoundFailure`, `UnknownFailure`.
- `core/error_handler.dart`: fungsi `AppException mapError(Object e)` yang memetakan:
  - `SocketException`, `ClientException`, `HandshakeException` → `NetworkException("Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.")`
  - `TimeoutException` → `NetworkException("Server terlalu lama merespons. Coba lagi.")`
  - `AuthException` (Supabase) → `AuthFailure` sesuai tabel 8.3
  - `PostgrestException` → `DatabaseFailure` (lihat 8.5)
  - `FormatException` / `TypeError` saat parsing → `UnknownFailure("Data dari server tidak sesuai format.")`
  - lainnya → `UnknownFailure("Terjadi kesalahan tak terduga. Coba lagi.")`
- **Setiap method di `services/`** dibungkus `try/catch` + `.timeout(...)` dan **melempar `AppException`** (bukan exception mentah) via `mapError`. Layer UI hanya menangkap `AppException`.
- `widgets/error_view.dart`: ikon + pesan + tombol **"Coba lagi"** (callback retry). `widgets/empty_view.dart`: pesan untuk data kosong. `widgets/loading_view.dart`: indikator + teks.
- Aksi (simpan/hapus/login): tampilkan hasil lewat **SnackBar** (merah untuk gagal, hijau untuk sukses). Muat data list/halaman: tampilkan `ErrorView` dengan retry.

### 8.3 Error autentikasi (pesan wajib)
| Kondisi | Pesan ke pengguna |
|---|---|
| Email/password salah | "Email atau password salah." |
| Email belum dikonfirmasi (jika aktif) | "Email belum dikonfirmasi. Cek kotak masuk emailmu." |
| Email sudah terdaftar | "Email sudah terdaftar. Silakan login." |
| Password terlalu lemah/pendek | "Password terlalu lemah. Gunakan minimal 6 karakter." |
| Format email tidak valid | "Format email tidak valid." |
| Terlalu banyak percobaan (rate limit) | "Terlalu banyak percobaan. Tunggu beberapa saat lalu coba lagi." |
| Sesi kedaluwarsa/signed out | Pindah ke Login + SnackBar "Sesi berakhir. Silakan login kembali." |
| Error auth lain | "Gagal masuk. Coba lagi." |

Pemetaan dilakukan dari `AuthException.code`/`message`; jika tidak dikenali, pakai pesan terakhir.

### 8.4 Validasi input (`utils/validators.dart`)
- **Email:** wajib, format valid (regex sederhana), trim spasi.
- **Password:** wajib, min. 6 karakter; **konfirmasi password** harus sama.
- **Nama:** wajib, 2-50 karakter setelah trim.
- **Tanggal lahir:** wajib, **tidak boleh di masa depan**, tidak sebelum 1 Januari 1900.
- **Tanggal acara:** wajib, rentang 1900-2100.
- **Jenis acara:** wajib dipilih.
- **Kalkulator umur:** jika tanggal lahir di masa depan → tampilkan pesan "Tanggal lahir tidak boleh di masa depan" dan jangan hitung.
- Pesan validasi ditampilkan inline di bawah field (`Form` + `validator`). Tombol simpan tidak memanggil server jika validasi gagal.

### 8.5 Error database (PostgrestException)
| Kondisi | Penanganan |
|---|---|
| Tabel/kolom tidak ditemukan atau skema belum dijalankan | "Data belum siap. Hubungi pengembang." + log detail |
| Pelanggaran RLS/izin (kode `42501`) | "Kamu tidak punya izin untuk aksi ini." |
| Data tidak ditemukan (mis. edit item yang sudah dihapus) | "Data tidak ditemukan. Mungkin sudah dihapus." lalu refresh list |
| Pelanggaran constraint / data tidak valid | "Data tidak valid. Periksa isian lalu coba lagi." |
| Lainnya | "Gagal memproses data. Coba lagi." |

### 8.6 Error di logika kalender
- Semua fungsi `KalenderUtil` menerima `DateTime` valid; validasi tanggal dilakukan **sebelum** memanggil fungsi.
- Bungkus pemanggilan UI dengan `try/catch`; bila gagal, tampilkan "Perhitungan gagal. Coba tanggal lain." dan **jangan crash**.
- Konversi Hijriah dibungkus `try/catch` karena package bisa melempar error pada tanggal di luar rentang; tampilkan "Tanggal di luar rentang konversi Hijriah."

### 8.7 Error global (di `main.dart`)
- `WidgetsFlutterBinding.ensureInitialized()`, muat `.env` di dalam `try/catch`. Jika `.env` atau inisialisasi Supabase gagal, tampilkan **layar error konfigurasi** yang jelas ("Konfigurasi aplikasi belum lengkap") dan bukan layar merah.
- Pasang `FlutterError.onError` dan `PlatformDispatcher.instance.onError` → `debugPrint` detail, return `true`.
- Atur `ErrorWidget.builder` agar widget yang gagal build menampilkan kotak pesan ramah, bukan layar merah bawaan.
- Bungkus `runApp` dengan `runZonedGuarded` (atau gunakan `PlatformDispatcher`) untuk error async yang lolos.

### 8.8 Edge case yang harus ditangani
- Koneksi hilang saat sedang simpan/hapus → pesan jaringan, data list tidak berubah, tombol aktif lagi.
- Pengguna menekan Back saat loading → tidak crash; operasi selesai diam-diam (cek `mounted`).
- List kosong → `EmptyView` dengan ajakan menambah data.
- Layar kecil / teks besar → tidak ada overflow (gunakan `SingleChildScrollView`, `Flexible`/`Expanded`).
- Hapus data orang yang dipakai di acara → acara tetap ada (`orang_id` jadi null; tampilkan "Orang dihapus").
- Tanggal yang dekat pergantian hari/bulan/kabisat pada hitung umur → hasil tetap benar (lihat tes 10.3).
- Timer/stopwatch tidak bocor saat pindah layar atau logout.

## 9. Persyaratan Non-Fungsional
- UI Material 3, tema konsisten (warna hangat bernuansa Jawa: cokelat/emas boleh), font terbaca, tombol menu besar, kontras cukup.
- Semua teks Bahasa Indonesia; tanggal diformat `id_ID` (contoh: "19 September 2026").
- Perpindahan halaman dan pemuatan data terasa responsif (< 2 detik pada koneksi normal); tampilkan loading indicator.
- Kode rapi: pisahkan UI, service, dan util; beri komentar singkat pada rumus. `flutter analyze` tanpa error.

## 10. Rumus & Kasus Uji (untuk verifikasi)

### 10.1 Weton
Neptu hari: Minggu 5, Senin 4, Selasa 3, Rabu 7, Kamis 8, Jumat 6, Sabtu 9. Neptu pasaran: Legi 5, Pahing 9, Pon 7, Wage 4, Kliwon 8. Neptu = jumlah keduanya. Acuan hitung: 21 Mei 2000 = Minggu Pahing = awal Wuku Sinta; siklus wuku 210 hari (30 wuku × 7 hari).

### 10.2 Kasus uji weton/wuku
| Tanggal | Hasil yang diharapkan |
|---|---|
| 21 Mei 2000 | Minggu Pahing, neptu 14, Wuku Sinta |
| 28 Mei 2000 | Minggu Wage, neptu 9, Wuku Landep |
| 17 Agustus 1945 | Jumat Legi, neptu 11 |
| 21 Mei 2000 + 210 hari | Wuku kembali Sinta |

### 10.3 Kasus uji umur
- Lahir 15 Maret 2005 08:30:00 → dihitung pada 19 September 2026 10:45:30 = **21 tahun, 6 bulan, 4 hari, 2 jam, 15 menit, 30 detik**.
- Lahir 31 Januari 2000 00:00 → dihitung pada 1 Maret 2000 00:00 harus menghasilkan bulan/hari yang tidak negatif dan konsisten (periksa perilaku peminjaman hari).
- Tanggal lahir masa depan → ditolak dengan pesan validasi.

### 10.4 Kasus uji hari baik
- Jumat Legi (11) + Jumat Legi (11) = 22, sisa 6 → **Padu (baik)**.
- Total neptu 16 → sisa 0 → dianggap 8 → **Pesthi (baik)**.
- Total neptu 9 → sisa 1 → **Pegat (kurang baik)**.

Jika ada hasil uji yang tidak cocok dengan tabel ini, periksa `kalender_util.dart` dan laporkan diskrepansinya; jangan diam-diam mengubah rumus.

## 11. Definition of Done (checklist tugas)
- [ ] Terkoneksi Supabase; skema dari `schema.sql` aktif; RLS berfungsi.
- [ ] Register, login, session persisten, dan logout berjalan.
- [ ] Beranda menampilkan **6 menu vertikal di tengah layar** dan semuanya berfungsi.
- [ ] Daftar Anggota, Hitung Hari Baik, CRUD (Orang & Acara), Hijriah, Umur (sampai detik), Weton + Saka Bali berfungsi.
- [ ] Bottom Navigation 3 menu: Beranda, Stopwatch, Bantuan (ada panduan + Logout).
- [ ] Semua skenario Bagian 8 tertangani; tidak ada layar merah/crash pada uji: mode pesawat, password salah, form kosong, tanggal masa depan, hapus data, logout saat loading.
- [ ] `flutter analyze` bersih; `.env` tidak masuk repo; ada `.env.example`.
- [ ] Semua kasus uji Bagian 10 lolos.
- [ ] Aplikasi bisa dibangun (`flutter build apk`) dan dijalankan di emulator/HP.
- [ ] Layar-layar siap di-screenshot untuk laporan.

## 12. Rencana Implementasi (urutan pengerjaan untuk agent)
1. **Fondasi:** buat project, tambahkan dependency, `.env`, `core/` (exception + error handler + widget loading/error/empty), `main.dart` dengan error global + `AuthGate`.
2. **Auth:** login, register, session, logout + pesan error 8.3.
3. **Shell:** `MainShell` + bottom nav (Beranda, Stopwatch, Bantuan) + Beranda 6 menu.
4. **Util & fitur kalender:** pasang `kalender_util.dart`, jalankan kasus uji, lalu layar Hijriah, Umur, Weton/Saka Bali.
5. **Database:** service + model, Daftar Anggota, CRUD Orang, CRUD Acara.
6. **Hari Baik:** dua mode + simpan ke acara.
7. **Stopwatch & Bantuan.**
8. **Hardening:** uji semua skenario error, rapikan UI, jalankan `flutter analyze` dan checklist Bagian 11.

Prioritas jika waktu mepet: (1) Auth + session, (2) Beranda + bottom nav, (3) CRUD, (4) Umur, Hijriah, Weton, (5) Hari Baik, (6) Stopwatch + Bantuan, (7) Saka Bali dan poles UI.

## 13. Asumsi & Risiko
- Tanggal Nyepi di `kalender_util.dart` (2024-2027) perlu diverifikasi manual; di luar tabel dipakai perkiraan 15 Maret.
- Aturan hari baik mengikuti metode umum primbon; sumber lain bisa berbeda. Sebutkan di aplikasi dan laporan.
- Hijriah dari package bisa selisih 1 hari dari Kemenag.
- Email confirmation Supabase sebaiknya dimatikan saat pengembangan agar login tidak tertahan.
- Data anggota di `schema.sql` harus diganti dengan anggota kelompok sebenarnya.
