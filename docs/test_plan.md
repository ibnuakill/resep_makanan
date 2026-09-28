# Testing Plan

## 1. Pendahuluan
Dokumen ini mendefinisikan strategi pengujian untuk aplikasi **Resep Makanan**. Pengujian dilakukan untuk memastikan logika, navigasi, dan state management berjalan sempurna sebelum aplikasi dirilis.

## 2. Unit Testing
Unit test difokuskan pada pengujian logika bisnis dan parsing data (Folder `models` dan `services`).

### Skenario Uji Unit:
1. **Model Parsing (`models/recipe.dart`):**
   - *Test:* Apakah `Recipe.fromDetail(json)` berhasil memetakan JSON TheMealDB yang kompleks (dengan banyak properti `strIngredient` & `strMeasure`) menjadi List bahan yang rapi?
   - *Test:* Bagaimana jika data JSON kehilangan properti? (Pengecekan null-safety).
2. **Repository (`services/recipe_repository.dart`):**
   - *Test:* Jika metode `.search()` dipanggil, apakah repository mengembalikan data List yang benar?
   - *Test:* Jika API error (misalnya `Timeout`), apakah ditangani atau dilempar dengan benar?

## 3. Widget / UI Testing
Widget test memastikan bahwa komponen UI merender elemen yang benar berdasarkan state tertentu.

### Skenario Uji Widget:
1. **Home Screen (`screens/home_screen.dart`):**
   - *Test:* Pastikan teks "Resep Makanan" muncul di layar.
   - *Test:* Pastikan input pencarian dapat diketik dan di-*submit*.
   - *Test:* Saat loading, pastikan `CircularProgressIndicator` terlihat.
2. **Detail Screen:**
   - *Test:* Pastikan tombol "Favorit" bisa ditekan dan berubah status warna (Icon terisi/kosong).

## 4. Integration Testing (E2E)
Pengujian seluruh alur aplikasi berjalan menggunakan data palsu (mock API) atau server staging jika tersedia.
- *Test Flow:* Buka Aplikasi -> Muncul Rekomendasi Hari Ini -> Ketik "Chicken" di kolom pencarian -> Muncul Daftar Chicken -> Tap salah satu resep -> Tap tombol Simpan ke Favorit -> Cek apakah tersimpan.

## 5. Tools yang Digunakan
- **flutter_test:** Untuk unit test dan widget test.
- **mockito:** (Jika diperlukan) Untuk me-*mocking* class `http.Client` agar kita bisa mengetes `ApiService` tanpa memanggil koneksi internet sungguhan.
- **integration_test:** SDK bawaan flutter untuk pengujian langsung di atas *real device* atau *emulator*.
