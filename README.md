# Aplikasi Hari Baik - Tugas 3 Pemrograman Aplikasi Mobile

Aplikasi mobile berbasis Flutter yang terintegrasi dengan **Supabase** (Autentikasi, Database PostgreSQL, dan Row Level Security) serta perhitungan kalender Masehi & Hijriah.

---

## 📱 Fitur Aplikasi

1. **Autentikasi**:
   - Register akun baru & Login pengguna via Supabase Auth
   - Logout & session persistence otomatis
2. **Dashboard / Home**:
   - Ringkasan tanggal hari ini (Masehi & Hijriah)
   - Status hari baik hari ini
   - Navigasi cepat ke seluruh modul
3. **Cek Hari Baik**:
   - Perhitungan status hari baik berdasarkan aturan tanggal dan hari
   - Detail rekomendasi aktivitas & pantangan
4. **Kalender**:
   - Tampilan kalender Masehi & Hijriah terintegrasi
5. **Hitung Umur**:
   - Kalkulator umur detail dalam tahun, bulan, hari
6. **Stopwatch**:
   - Fitur stopwatch dengan pencatatan putaran (lap)
7. **CRUD**:
   - Manajemen Data Orang
   - Manajemen Rencana Acara (terhubung dengan data orang)
8. **Daftar Anggota**:
   - Informasi anggota kelompok pengembang aplikasi
9. **Bantuan**:
   - Panduan lengkap penggunaan setiap fitur aplikasi

---

## 👥 Panduan Setup untuk Teman / Kolaborator Tim

Karena file `.env` berisi kunci API Supabase dan **tidak di-upload ke GitHub demi keamanan**, ikuti langkah-langkah berikut agar aplikasi bisa langsung berjalan di komputermu:

### 1. Clone Repository & Masuk ke Folder Project
```bash
git clone <URL_REPO_GITHUB_KAMU>
cd tugas3
```

### 2. Unduh Dependencies Flutter
Pastikan Flutter SDK sudah terpasang, lalu jalankan:
```bash
flutter pub get
```

### 3. Setup File `.env` (PENTING ⚠️)
1. Di root project, buat file baru bernama `.env` (atau duplikasi dari `.env.example`):
   ```bash
   cp .env.example .env
   ```
2. Isi file `.env` tersebut dengan kredensial Supabase:
   ```env
   SUPABASE_URL=https:/xxxxx.supabase.co
   SUPABASE_ANON_KEY=xxxxxxx
   ```
   > 💡 **Catatan:** Minta isi lengkap `SUPABASE_URL` dan `SUPABASE_ANON_KEY` ke teman kelompok pemilik project Supabase.

---

## 🗄️ Konfigurasi Supabase (Database & Skema)

Jika kamu ingin menggunakan database milik sendiri atau membuat database baru di Supabase:

1. Buat project baru di [Supabase Console](https://supabase.com/dashboard).
2. Masuk ke menu **SQL Editor** di dashboard Supabase.
3. Buka file [`schema.sql`](./schema.sql) yang ada di root repository ini.
4. Copy seluruh query di file `schema.sql` dan paste ke SQL Editor Supabase, lalu klik **Run**.
5. Skema ini sudah mencakup pembuatan:
   - Tabel `anggota`
   - Tabel `aturan_hari_baik` (beserta seed data)
   - Tabel `orang`
   - Tabel `rencana_acara`
   - Row Level Security (RLS) policies
6. Ambil **Project URL** dan **Anon Key** dari menu **Project Settings > API**, lalu masukkan ke file `.env` lokalmu.

---

## 🚀 Menjalankan Aplikasi

Jalankan perintah:
```bash
flutter run
```
Pilih perangkat / emulator yang ingin digunakan (Android, Chrome/Web, atau Windows).
