# Pijar Baca 🔥

**Pijar Baca** adalah aplikasi _personal reading tracker_ yang dibangun menggunakan Flutter. Aplikasi ini tidak hanya mencatat progres membaca, tetapi juga memotivasi pengguna melalui statistik menarik dan sistem *streak* (rentetan membaca) yang divisualisasikan sebagai api yang terus menyala.



---

## ✨ Fitur Utama

- **Rak Buku Digital**: Kelola koleksi buku Anda dalam tiga rak utama: "Sedang Dibaca", "Selesai Dibaca", dan "Ingin Dibaca" (Wishlist).
- **Penambahan Buku Fleksibel**:
  - **Manual**: Masukkan data buku secara manual.
  - **Scan ISBN**: Pindai barcode ISBN buku fisik untuk mengisi data secara otomatis via Google Books API.
  - **Ketik ISBN**: Cari dan tambahkan buku dengan mengetik nomor ISBN.
- **Pelacakan Progres**: Catat halaman terakhir yang dibaca dan lihat progres bar secara visual.
- **Sistem Streak Api 🔥**: Jaga konsistensi membaca harian untuk membuat api terus menyala.
- **Streak Freeze 💎**: Dapatkan "Permata Beku" sebagai hadiah dan gunakan secara otomatis untuk melindungi *streak* saat Anda melewatkan satu hari.
- **Asisten Membaca Cerdas (AI)**: Didukung oleh Google Gemini, aplikasi ini dapat:
  - Memberikan **rekomendasi buku** yang dipersonalisasi.
  - **Menjawab pertanyaan** apa pun tentang isi buku yang sedang dibaca.
  - Membuat **kuis interaktif** setelah Anda menyelesaikan sebuah buku.
- **Dasbor Statistik**: Visualisasikan kebiasaan membaca Anda melalui kalender aktivitas dan rekor pencapaian.
- **Notifikasi Kustom**: Atur waktu pengingat harian agar tidak lupa membaca dan menjaga api *streak*.
- **UI Modern & Tematik**: Tampilan modern dengan tema buku yang kalem dan nyaman di mata.

---

## 🚀 Teknologi yang Digunakan

- **Framework**: Flutter
- **Database Lokal**: Isar
- **State Management**: Riverpod
- **Integrasi API**: Dio (untuk Google Books API), google_generative_ai (untuk Google Gemini)
- **UI & Visualisasi**: `cached_network_image`, `google_fonts`, `table_calendar`
- **Fitur Native**: `mobile_scanner`, `flutter_local_notifications`

---

## 🛠️ Instalasi & Penyiapan

Untuk menjalankan proyek ini di lingkungan lokal Anda, ikuti langkah-langkah berikut:

1.  **Prasyarat**:
    - Pastikan Anda sudah menginstal [Flutter SDK](https://flutter.dev/docs/get-started/install).
    - Siapkan Emulator Android atau perangkat fisik.

2.  **Clone Repositori**:
    ```bash
    git clone [https://github.com/NAMA_ANDA/pijar_baca.git](https://github.com/NAMA_ANDA/pijar_baca.git)
    cd pijar_baca
    ```

3.  **Siapkan API Key**:
    - Buka [Google AI Studio](https://aistudio.google.com/) untuk mendapatkan API Key Gemini Anda.
    - Buat file baru di folder utama proyek dengan nama `.env`.
    - Isi file `.env` dengan format berikut:
      ```
      GEMINI_API_KEY=MASUKKAN_API_KEY_ANDA_DI_SINI
      ```

4.  **Instal Dependensi**:
    ```bash
    flutter pub get
    ```

5.  **Jalankan Code Generator**:
    Karena proyek ini menggunakan `riverpod_generator` dan `isar_generator`, jalankan perintah ini satu kali:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

6.  **Jalankan Aplikasi**:
    ```bash
    flutter run
    ```

---
