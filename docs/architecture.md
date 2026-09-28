# Architecture & Technical Design

## 1. Pendahuluan
Dokumen ini menguraikan struktur arsitektur teknis dari aplikasi **Resep Makanan**. Tujuannya adalah untuk memberikan panduan kepada pengembang tentang bagaimana kode diatur dan bagaimana aliran data bekerja di dalam aplikasi.

## 2. Pola Arsitektur
Aplikasi ini menggunakan pendekatan arsitektur yang berpusat pada pemisahan antara UI (User Interface) dan Data/Logic layer (Repository Pattern). 

- **UI Layer (`screens` & `widgets`):** Hanya bertugas menampilkan antarmuka dan merespons input dari pengguna.
- **Repository Layer (`services/recipe_repository.dart`):** Bertindak sebagai "single source of truth" yang memutuskan dari mana data diambil (apakah dari API online atau data lokal offline).
- **Service Layer (`services`):** Bertugas melakukan tugas spesifik seperti memanggil HTTP request ke API (`api_service.dart`) atau membaca/menulis ke penyimpanan lokal (`local_store.dart`).

## 3. Struktur Direktori Utama
```text
lib/
 ├── models/          # Berisi representasi data objek (mis: recipe.dart). Parsing JSON ke Object dilakukan di sini.
 ├── screens/         # Berisi halaman-halaman utama (mis: home_screen.dart, detail_screen.dart).
 ├── services/        # Logika bisnis, pemanggilan API, local storage, dan repository.
 │    ├── api_service.dart        # Logika request ke TheMealDB API.
 │    ├── local_recipes.dart      # Logika membaca assets/recipes_local.json.
 │    ├── local_store.dart        # Logika SharedPreferences (Favorit).
 │    └── recipe_repository.dart  # Mediator antara API dan Local.
 ├── widgets/         # Komponen UI yang dapat digunakan kembali (mis: recipe_card.dart).
 └── main.dart        # Titik awal aplikasi (Entry Point).
```

## 4. Aliran Data (Data Flow)
Contoh Aliran Data saat mencari resep:
1. **User Action:** Pengguna mengetik "Ayam" di `HomeScreen` dan menekan cari.
2. **UI memanggil Repository:** `HomeScreen` memanggil `recipeRepository.search("Ayam")`.
3. **Repository memanggil Service:** `RecipeRepository` memanggil `apiService.search("Ayam")`.
4. **Service melakukan Request HTTP:** `ApiService` menembak API, mendapatkan JSON, mengonversinya menjadi `List<Recipe>`, dan mengembalikannya ke Repository.
5. **UI Update:** Data `List<Recipe>` diterima oleh `HomeScreen`. UI di-*rebuild* untuk menampilkan daftar makanan kepada pengguna.
