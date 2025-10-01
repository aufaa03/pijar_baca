// Lokasi: lib/features/book/presentation/add_book_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Impor ConsumerStatefulWidget
import 'package:pijar_baca/main.dart';
import 'package:pijar_baca/features/book/data/book_model.dart';
import 'package:pijar_baca/features/book/presentation/book_provider.dart'; // Impor provider
import 'package:pijar_baca/features/home/presentation/streak_provider.dart';

// Ubah menjadi ConsumerStatefulWidget agar bisa akses 'ref'
class AddBookScreen extends ConsumerStatefulWidget {
  final Book? prefilledBook;

  const AddBookScreen({super.key, this.prefilledBook});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _totalPagesController = TextEditingController();
  bool _isSaving = false; // State untuk loading
  // variable untuk menyimpan status yang dipilih dari dropdown default : reading
  BookStatus _selectedStatus = BookStatus.reading;
  @override
  void initState() {
    super.initState();
    if (widget.prefilledBook != null) {
      _titleController.text = widget.prefilledBook!.title ?? '';
      _authorController.text = widget.prefilledBook!.author ?? '';
      _totalPagesController.text =
          widget.prefilledBook!.totalPages?.toString() ?? '';
      // Jika dari hasil scan, defaultnya masuk ke 'Ingin Dibaca'
      _selectedStatus = widget.prefilledBook!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _totalPagesController.dispose();
    super.dispose();
  }

  // --- PERBAIKAN UTAMA DI SINI ---
  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true); // Mulai loading

      final newBook = Book()
        ..title = _titleController.text
        ..author = _authorController.text
        ..totalPages = int.tryParse(_totalPagesController.text) ?? 0
        ..currentPage = 0
        ..status = _selectedStatus
        ..coverUrl = widget.prefilledBook?.coverUrl
        ..description = widget.prefilledBook?.description
        ..dateAdded = DateTime.now();

      // 1. Tunggu (await) sampai proses simpan ke database selesai
      await isarService.saveBook(newBook);

      // 2. Perintahkan Riverpod untuk me-refresh data rak buku
      ref.invalidate(booksByStatusProvider);
            // Perintahkan Riverpod untuk me-refresh data streak
      ref.invalidate(streakCountProvider);
      // 3. Tutup halaman SETELAH semuanya selesai
      if (mounted) Navigator.pop(context);
    }
  }

  String _statusToString(BookStatus status) {
    switch (status) {
      case BookStatus.reading:
        return 'Sedang Dibaca';
      case BookStatus.finished:
        return 'Selesai Dibaca';
      case BookStatus.wishlist:
        return 'Ingin Dibaca';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.prefilledBook == null ? 'Tambah Buku Baru' : 'Konfirmasi Buku',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Buku'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Judul tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Penulis'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _totalPagesController,
                decoration: const InputDecoration(labelText: 'Jumlah Halaman'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Jumlah halaman tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),
               DropdownButtonFormField<BookStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Pilih Rak',
                ),
                items: BookStatus.values.map((BookStatus status) {
                  return DropdownMenuItem<BookStatus>(
                    value: status,
                    child: Text(_statusToString(status)),
                  );
                }).toList(),
                onChanged: (BookStatus? newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveBook,
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Simpan Buku'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
