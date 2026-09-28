# API Specification (TheMealDB)

## 1. Pendahuluan
Aplikasi ini menggunakan API publik gratis dari **TheMealDB** v1. Karena menggunakan *free tier*, API Key secara default adalah `1`.
- **Base URL:** `https://www.themealdb.com/api/json/v1/1`

## 2. Endpoints yang Digunakan

### 2.1 Pencarian Berdasarkan Nama
Mencari daftar resep menggunakan kata kunci (nama hidangan).
- **Endpoint:** `/search.php`
- **Method:** `GET`
- **Query Params:**
  - `s` (string): Nama hidangan (contoh: `s=Arrabiata`)
- **Response Format:** Mengembalikan detail penuh resep dalam array `meals`.

### 2.2 Filter Berdasarkan Kategori
Mencari daftar resep yang masuk ke dalam kategori tertentu.
- **Endpoint:** `/filter.php`
- **Method:** `GET`
- **Query Params:**
  - `c` (string): Nama kategori (contoh: `c=Seafood`)
- **Response Format:** Mengembalikan informasi *summary* resep (Hanya ID, Nama, dan Thumbnail).

### 2.3 Detail Resep Berdasarkan ID
Mengambil informasi lengkap beserta bahan dan instruksi dari satu resep menggunakan ID uniknya.
- **Endpoint:** `/lookup.php`
- **Method:** `GET`
- **Query Params:**
  - `i` (string): Meal ID (contoh: `i=52772`)
- **Response Format:** Mengembalikan detail penuh satu resep dalam array `meals`.

### 2.4 Daftar Kategori
Mengambil semua daftar kategori makanan yang tersedia (misal: Beef, Chicken, Dessert).
- **Endpoint:** `/list.php`
- **Method:** `GET`
- **Query Params:**
  - `c` (string): Selalu bernilai `list` (`c=list`)
- **Response Format:** Mengembalikan list berisi objek kategori.

### 2.5 Resep Acak (Rekomendasi)
Mengambil satu resep makanan acak. Berguna untuk fitur "Rekomendasi Hari Ini".
- **Endpoint:** `/random.php`
- **Method:** `GET`
- **Response Format:** Mengembalikan detail penuh satu resep acak dalam array `meals`.

## 3. Penanganan Error (Error Handling)
- Jika response `statusCode != 200`, aplikasi akan melempar `Exception('HTTP {status} untuk {uri}')`.
- Jika properti `meals` bernilai `null` (misal, hasil pencarian tidak ditemukan), API ini akan dikonversi menjadi *List kosong* (`[]`) di Flutter.
