// Lokasi: lib/features/book/presentation/add_by_isbn_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pijar_baca/core/services/book_api_service.dart';
import 'package:pijar_baca/features/book/presentation/add_book_screen.dart';

class AddByIsbnScreen extends StatefulWidget {
  const AddByIsbnScreen({super.key});

  @override
  State<AddByIsbnScreen> createState() => _AddByIsbnScreenState();
}

class _AddByIsbnScreenState extends State<AddByIsbnScreen> {
  final _formKey = GlobalKey<FormState>();
  final _isbnController = TextEditingController();
  final _apiService = BookApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _searchIsbn() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Panggil service yang sama dengan yang dipakai fitur scan
    final book = await _apiService.getBookByIsbn(_isbnController.text.trim());

    setState(() => _isLoading = false);

    if (book != null) {
      // Jika buku ditemukan, buka halaman AddBookScreen dengan data
      if (mounted) {
        Navigator.pop(context); // Tutup halaman ini
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddBookScreen(prefilledBook: book),
          ),
        );
      }
    } else {
      // Jika buku tidak ditemukan, tampilkan pesan error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ISBN tidak ditemukan. Periksa kembali nomornya.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Buku via ISBN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _isbnController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nomor ISBN (10 atau 13 digit)',
                  hintText: 'Ketik ISBN tanpa tanda hubung',
                ),
                // Hanya izinkan angka
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                // Validasi sederhana
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap masukkan nomor ISBN';
                  }
                  if (value.length != 10 && value.length != 13) {
                    return 'ISBN harus 10 atau 13 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _searchIsbn,
                  icon: _isLoading
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.search),
                  label: const Text('Cari Buku'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}