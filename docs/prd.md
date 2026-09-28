# Product Requirements Document (PRD)

## 1. Pendahuluan
**Nama Produk:** Resep Makanan (Food Recipe App)
**Platform:** Android, iOS, Web (Flutter)
**Versi:** 1.0.0

### 1.1 Visi Produk
Aplikasi "Resep Makanan" bertujuan untuk menjadi asisten dapur yang praktis bagi pengguna, menyediakan ribuan resep makanan lezat dari seluruh dunia, baik secara online maupun offline. Aplikasi ini menyajikan antarmuka yang bersih dan modern untuk memudahkan pengguna mencari inspirasi makanan setiap hari.

## 2. Target Pengguna
- **Ibu Rumah Tangga / Pemasak Pemula:** Yang membutuhkan panduan langkah demi langkah memasak dengan mudah.
- **Pencinta Kuliner (Foodies):** Yang ingin mengeksplorasi resep makanan baru dari berbagai kategori dan negara.
- **Pengguna Sibuk:** Yang menginginkan rekomendasi makanan cepat atau mencari resep berdasarkan bahan yang ada.

## 3. Fitur Utama (Core Features)

### 3.1 Pencarian dan Jelajah Resep (Eksplorasi)
- **Kategori Makanan:** Pengguna dapat menelusuri resep berdasarkan kategori (misal: Seafood, Beef, Chicken, Dessert).
- **Pencarian Bebas:** Pengguna dapat mencari resep menggunakan kata kunci (nama makanan).
- **Rekomendasi Hari Ini (Random Recipe):** Menampilkan satu resep acak setiap kali pengguna membuka aplikasi sebagai inspirasi harian.

### 3.2 Detail Resep
- Menampilkan foto hidangan, nama hidangan, dan kategori.
- Menampilkan daftar bahan-bahan (ingredients) beserta takarannya.
- Menampilkan instruksi memasak (langkah-langkah).
- (Opsional) Tautan ke video tutorial memasak jika tersedia dari sumber data.

### 3.3 Mode Hibrida (Online & Offline)
- **Data Online:** Mengambil data resep yang sangat luas langsung dari public API (TheMealDB).
- **Data Lokal:** Menggunakan data JSON lokal (`assets/recipes_local.json`) sebagai fallback atau kumpulan resep eksklusif offline agar aplikasi tetap bisa digunakan tanpa koneksi internet penuh.

### 3.4 Fitur Simpan/Favorit (Local Storage)
- Pengguna dapat menyimpan resep ke daftar favorit.
- Data favorit disimpan secara lokal di perangkat pengguna (menggunakan SharedPreferences).

### 3.5 Pengaturan & Lokalisasi Bahasa
- Default bahasa untuk aplikasi dan instruksi memasak adalah **Bahasa Indonesia**.
- Teks instruksi memasak dari sumber internasional (TheMealDB) secara otomatis diterjemahkan ke Bahasa Indonesia menggunakan kamus kuliner & translation fallback.
- Tab **Pengaturan (Profil & Settings)** memungkinkan pengguna beralih bahasa manual antara Bahasa Indonesia (🇮🇩) dan English (🇬🇧).
- Pada halaman detail resep, disediakan tombol toggle cepat bahasa (🇮🇩 ID / 🇬🇧 EN) untuk kemudahan pengguna membandingkan teks asli dan terjemahan.

## 4. Spesifikasi Teknis

- **Framework Frontend:** Flutter (Dart)
- **UI/UX Design System:** Material Design 3 (Material 3), dengan `colorSchemeSeed: Colors.deepOrange`.
- **Sumber Data (API):** TheMealDB API (Free Tier - `https://www.themealdb.com/api/json/v1/1`).
- **Penyimpanan Lokal:** `shared_preferences` untuk menyimpan preferensi pengguna/resep favorit dan preferensi bahasa.
- **Manajemen Gambar:** `cached_network_image` untuk memuat gambar dari URL secara efisien dengan sistem caching.
- **Networking:** `http` package untuk memanggil REST API TheMealDB dan terjemahan online.

## 5. User Flow Utama
1. **Beranda (Home Screen):** Pengguna membuka aplikasi -> Melihat "Rekomendasi Hari Ini" -> Melihat daftar kategori -> Melihat resep-resep populer atau lokal.
2. **Cari Resep:** Pengguna mengetikkan nama makanan di kolom pencarian -> Aplikasi menampilkan daftar hasil (gambar & judul) -> Pengguna memilih salah satu.
3. **Detail Resep:** Pengguna masuk ke halaman detail -> Membaca bahan dan cara masak (otomatis Bahasa Indonesia) -> Pengguna dapat beralih bahasa atau mengklik tombol "Favorit".
4. **Pengaturan:** Pengguna membuka tab Pengaturan untuk melihat ringkasan favorit/riwayat dan mengubah preferensi bahasa.

## 6. Kebutuhan Non-Fungsional
- **Performa:** Aplikasi harus memuat daftar resep dari API dalam waktu kurang dari 3 detik (dengan asumsi koneksi stabil). Gambar harus di-cache agar tidak memuat ulang gambar yang sama secara berulang.
- **Ketersediaan Offline:** Setidaknya resep lokal (`recipes_local.json`), terjemahan lokal, dan resep favorit harus tetap bisa diakses tanpa koneksi internet.
- **Desain Responsif:** UI harus menyesuaikan dengan baik di berbagai ukuran layar smartphone (Portrait & Landscape).

## 7. Fase Pengembangan Berikutnya (Future Roadmap)
- Menambahkan filter berdasarkan asal negara (Area).
- Menambahkan integrasi kalori atau nilai gizi.
