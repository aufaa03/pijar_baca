# Pijar Baca 🔥

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Aplikasi *personal reading tracker* yang dibangun menggunakan Flutter untuk membantu Anda membangun dan melacak kebiasaan membaca secara konsisten dan menyenangkan.

![Demo Pijar Baca](link-ke-gif-demo-anda.gif)

---

## ✨ Fitur-Fitur Unggulan

Pijar Baca dirancang dengan fitur-fitur modern untuk memberikan pengalaman terbaik bagi para pecinta buku.

#### **Manajemen Cerdas**
- **Rak Buku Digital**: Kelola koleksi dalam tiga rak: "Sedang Dibaca", "Selesai Dibaca", dan "Ingin Dibaca".
- **Penambahan Buku Fleksibel**: Tambah buku secara **manual**, **ketik ISBN**, atau **pindai barcode ISBN** fisik menggunakan kamera untuk mendapatkan data otomatis dari Google Books API.
- **Pelacakan Progres**: Catat halaman terakhir yang dibaca dan lihat progres bar visual di setiap buku.

#### **Gamifikasi & Motivasi**
- **Sistem Streak Api 🔥**: Jaga konsistensi membaca harian untuk membuat api *streak* terus menyala dengan **animasi dinamis** yang berubah sesuai pencapaian.
- **Streak Freeze 💎**: Dapatkan "Permata Beku" sebagai hadiah setiap 7 hari untuk melindungi *streak* Anda secara otomatis saat Anda melewatkan satu hari.
- **Halaman Detail Streak**: Lacak rekor *streak* terpanjang dan lihat kalender konsistensi Anda.
- **Notifikasi Kustom**: Atur waktu pengingat harian agar tidak lupa membaca.

#### **Asisten Membaca Cerdas (AI)**
Didukung oleh Google Gemini, Pijar Baca menjadi partner membaca Anda:
- **Rekomendasi Buku**: Dapatkan rekomendasi buku yang dipersonalisasi setelah Anda menyelesaikan sebuah buku.
- **Tanya Jawab Interaktif**: Ajukan pertanyaan apa pun tentang isi buku yang sedang dibaca dan dapatkan jawaban dari AI.
- **Kuis Interaktif**: Uji pemahaman Anda dengan kuis yang dibuat secara otomatis setelah Anda menamatkan buku.

---

## 🖼️ Galeri Aplikasi

| Rak Buku (Galeri) | Halaman Detail | Statistik & Kalender |
| :---: |:---:|:---:|
| <img src="" width="250"> | <img src="" width="250"> | <img src="" width="250"> |
| **Kuis Interaktif** | **Pengaturan** | **Onboarding** |
| <img src="" width="250"> | <img src="" width="250"> | <img src="" width="250"> |

---

## 🚀 Teknologi yang Digunakan

- **Framework**: Flutter
- **Database Lokal**: Isar
- **State Management**: Riverpod
- **Integrasi API**: Dio, `google_generative_ai` (Google Gemini), Google Books API
- **UI & Visualisasi**: `cached_network_image`, `google_fonts`, `table_calendar`, `introduction_screen`, `lottie`
- **Fitur Native**: `mobile_scanner`, `flutter_local_notifications`, `permission_handler`

---

## 🛠️ Instalasi & Penyiapan

Untuk menjalankan proyek ini di lingkungan lokal Anda, ikuti langkah-langkah berikut:

1.  **Prasyarat**:
    - Pastikan Anda sudah menginstal [Flutter SDK](https://flutter.dev/docs/get-started/install).
    - Siapkan Emulator Android atau perangkat fisik.

2.  **Clone Repositori**:
    ```bash
    git clone [https://github.com/NAMA_GITHUB_ANDA/pijar_baca.git](https://github.com/aufaa03/pijar_baca.git)
    cd pijar_baca
    ```
3.  **Siapkan API Keys (Penting!)**:
    Proyek ini memerlukan **dua** API Key agar berfungsi penuh.
    - Buat file baru di folder utama proyek dengan nama `.env`.
    - Isi file `.env` dengan format berikut:
      ```
      # 1. Dapatkan dari Google AI Studio untuk fitur AI
      GEMINI_API_KEY=MASUKKAN_API_KEY_GEMINI_ANDA

      # 2. Dapatkan dari Google Cloud Console untuk fitur Scan ISBN
      GOOGLE_BOOKS_API_KEY=MASUKKAN_API_KEY_GOOGLE_BOOKS_ANDA
      ```

4.  **Instal Dependensi**:
    ```bash
    flutter pub get
    ```

5.  **Jalankan Code Generator**:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

6.  **Jalankan Aplikasi**:
    ```bash
    flutter run
    ```

---

## 🧑‍💻 Kontributor

Dibuat dan dikembangkan oleh:

- **[Muhammad Aufa Rozaky](https://github.com/aufaa03)**

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah Lisensi MIT - lihat file [LICENSE](LICENSE) untuk detailnya.
