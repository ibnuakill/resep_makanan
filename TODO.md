# To-Do List Pengembangan Aplikasi "Resep Makanan"

Daftar ini memuat langkah-langkah pengembangan lanjutan berdasarkan dokumen perancangan (`docs/`). Kita akan menyelesaikannya satu per satu.

### Tahap 1: Peningkatan UI / UX
- [x] Implementasi animasi transisi `Hero` dari *Recipe Card* ke *Detail Screen*.
- [x] Implementasi `SliverAppBar` pada *Detail Screen* agar gambar resep terlihat premium.

### Tahap 2: Optimalisasi Data Lokal
- [x] Update fungsi *Favorit* di `local_store.dart`: Simpan keseluruhan JSON objek `Recipe` ke dalam *SharedPreferences*, bukan hanya menyimpan ID-nya.
- [x] Pastikan halaman *Detail Screen* bisa merender data resep utuh dari *Local Storage* meskipun koneksi internet terputus (Offline Support).

### Tahap 3: Fitur Eksplorasi Baru
- [x] Tambahkan API Service untuk mengambil data filter Area/Negara (`/filter.php?a=`).
- [x] Tambahkan Dropdown atau *Chips* di UI Beranda untuk memfilter masakan berdasarkan Area (misal: Italian, Japanese, dll).

### Tahap 4: Fitur *Grocery List* (Daftar Belanja)
- [x] Buat model atau schema data baru untuk "Daftar Belanja".
- [x] Tambahkan tombol "Tambahkan ke Daftar Belanja" di *Detail Screen* (menarik data dari `strIngredient` dan `strMeasure`).
- [x] Buat halaman (screen) terpisah khusus untuk melihat dan mencentang (checklist) daftar belanja.

### Tahap 5: Testing (Jaminan Kualitas)
- [x] Buat *Unit Test* untuk memastikan parsing model `recipe.dart` tahan banting terhadap data *Null* dari API.
- [x] Buat *Widget Test* dasar untuk halaman beranda.
