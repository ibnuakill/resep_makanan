---
description: Aturan utama untuk Agent di proyek Resep Makanan. Memastikan PRD selalu menjadi acuan.
---

# Panduan Proyek Resep Makanan

Saat bekerja di proyek ini, Anda (Agent AI) **DIWAJIBKAN** untuk selalu berpedoman pada Product Requirements Document (PRD).

## Aturan Utama:
1. **Baca Dokumen Perancangan**: Sebelum menulis kode atau menyarankan fitur baru, bacalah dokumen terkait di folder `docs/`:
   - `docs/prd.md` (Spesifikasi produk utama)
   - `docs/architecture.md` (Struktur dan pola arsitektur aplikasi)
   - `docs/api_spec.md` (Spesifikasi API endpoint)
   - `docs/local_storage_spec.md` (Skema penyimpanan lokal)
   - `docs/ui_ux.md` (Panduan tampilan visual)
   - `docs/test_plan.md` (Panduan pengujian)
2. **Kesesuaian Fitur**: Pastikan kode atau fitur yang Anda buat sejalan dengan visi, desain, dan arsitektur yang tertera di dalam dokumen-dokumen tersebut.
3. **Penyimpangan**: Jika pengguna meminta fitur atau perubahan yang bertentangan dengan dokumen-dokumen perancangan, berikan peringatan atau mintalah konfirmasi apakah dokumen tersebut harus diubah terlebih dahulu.

Dengan mengikuti `AGENTS.md` ini, pengembangan aplikasi akan selalu terarah dan sesuai dengan spesifikasi yang telah disepakati.
