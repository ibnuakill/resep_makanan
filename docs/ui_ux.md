# UI / UX Design Guidelines

## 1. Tema Utama (Theme)
Aplikasi menggunakan **Material Design 3 (M3)** dari Flutter, yang menjamin tampilan modern, animasi yang mulus, dan palet warna yang dinamis.

- **Warna Utama (Seed Color):** `Colors.deepOrange`
- **Konsep Tampilan:** Bersih, lapang (banyak white space), dan fokus pada gambar-gambar makanan yang menggugah selera.
- **Mode Tampilan:** Default aplikasi menggunakan *Light Mode*, namun tema M3 akan secara otomatis mengatur varian gelap jika *Dark Mode* diterapkan.

## 2. Tipografi (Typography)
Bawaan dari Material Design (Roboto) dengan aturan:
- **Headings (H1/H2):** Bold, digunakan pada Judul Halaman dan Nama Makanan di halaman Detail.
- **Body Text:** Regular, untuk list bahan, takaran, dan cara memasak.

## 3. Komponen Utama
### 3.1 Card Resep (`RecipeCard`)
- Bentuk rounded rectangle (sudut melengkung) standar M3.
- Menampilkan gambar makanan (`strMealThumb`) secara penuh (Cover/Fill) sebagai latar belakang, atau gambar berada di atas teks di bawahnya.
- Jika gambar di-load dari internet, menggunakan `CachedNetworkImage` dengan animasi *fade-in* atau placeholder agar tidak terlihat kosong.

### 3.2 Halaman Beranda (Home Screen)
- **Header:** Judul Aplikasi atau Salam Sapaan.
- **Search Bar:** Bar pencarian berbentuk kapsul (TextField dengan prefix icon Kaca Pembesar).
- **Section Rekomendasi:** Menampilkan `Card` besar untuk resep acak hari ini.
- **Daftar Kategori / List Horizontal:** Kumpulan chip/tombol untuk memfilter kategori makanan.

### 3.3 Halaman Detail
- **App Bar:** Transparan dengan background gambar makanan (SliverAppBar).
- **Body Konten:** 
  - Nama Makanan (Besar), Kategori, dan Tombol Favorit di kanan.
  - Tab atau Section terpisah antara "Bahan-bahan (Ingredients)" dan "Cara Memasak (Instructions)".

## 4. Interaksi
- **Tap Card:** Membuka animasi transisi ke Halaman Detail.
- **Swipe:** Boleh digunakan pada list horizontal (seperti Kategori).
- **Feedback Visual:** Ripple effect bawaan Material 3 digunakan di setiap tombol.
