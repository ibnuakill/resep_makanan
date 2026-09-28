# Local Storage & Database Schema

## 1. Pendahuluan
Aplikasi ini perlu bekerja secara offline sebagian. Dokumen ini menjelaskan skema penyimpanan lokal menggunakan JSON statis dan `shared_preferences`.

## 2. SharedPreferences (Preferensi Pengguna & Favorit)
Data dinamis pengguna (seperti daftar favorit) disimpan secara Key-Value menggunakan package `shared_preferences`.

### 2.1 Skema Data Favorit
- **Key:** `favorite_recipes`
- **Tipe Data:** `List<String>`
- **Deskripsi:** Berisi daftar string yang menyimpan *Meal ID* atau JSON String dari resep tersebut.

*(Catatan Implementasi: Disarankan menyimpan seluruh JSON String objek Recipe jika ingin detail favorit dapat dibuka saat offline. Namun, jika hanya menyimpan ID, aplikasi harus memanggil `/lookup.php` saat pengguna ingin membuka detail resep favorit).*

## 3. Resep Lokal Statis (`assets/recipes_local.json`)
Aplikasi memuat data JSON ini di awal untuk mempercepat load atau ketika tidak ada koneksi internet.

### 3.1 Skema JSON (Contoh)
```json
{
  "meals": [
    {
      "idMeal": "L001",
      "strMeal": "Nasi Goreng Spesial",
      "strCategory": "Lokal",
      "strInstructions": "1. Haluskan bumbu... 2. Panaskan wajan...",
      "strMealThumb": "https://example.com/nasi-goreng.jpg",
      "strIngredient1": "Nasi Putih",
      "strMeasure1": "2 piring",
      "strIngredient2": "Telur",
      "strMeasure2": "2 butir"
    }
  ]
}
```
**Catatan:** Skema JSON lokal diusahakan **100% identik** dengan respon JSON yang dikembalikan oleh TheMealDB, agar fungsi `.fromJson` di class `Recipe` dapat bekerja dengan mulus baik untuk API maupun Data Lokal.
