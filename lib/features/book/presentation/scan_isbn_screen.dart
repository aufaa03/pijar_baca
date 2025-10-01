import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pijar_baca/core/services/book_api_service.dart';
import 'package:pijar_baca/features/book/presentation/add_book_screen.dart';

class ScanIsbnScreen extends StatefulWidget {
  const ScanIsbnScreen({super.key});

  @override
  State<ScanIsbnScreen> createState() => _ScanIsbnScreenState();
}

class _ScanIsbnScreenState extends State<ScanIsbnScreen> {
  final BookApiService _apiService = BookApiService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan ISBN Buku')),
      body: MobileScanner(
        onDetect: (capture) async {
          if (_isProcessing) return;
          setState(() {
            _isProcessing = true;
          });

          final barcode = capture.barcodes.first;
          if (barcode.rawValue != null) {
            // Panggil API untuk mendapatkan data buku
            final book = await _apiService.getBookByIsbn(barcode.rawValue!);

            // Periksa hasilnya
            if (book != null) {
              // ---- JIKA SUKSES ----
              // Kembali ke halaman rak buku, lalu buka halaman tambah buku
              if (mounted) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBookScreen(prefilledBook: book),
                  ),
                );
              }
            } else {
              // ---- JIKA GAGAL ----
              // Tampilkan pesan error dan biarkan pengguna scan lagi
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ISBN tidak ditemukan atau tidak valid.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              // Tunggu sebentar sebelum mengizinkan scan berikutnya
              await Future.delayed(const Duration(seconds: 2));
              setState(() {
                _isProcessing = false;
              });
            }
          } else {
            // Jika barcode kosong, izinkan scan lagi
            setState(() {
              _isProcessing = false;
            });
          }
        },
      ),
    );
  }
}
