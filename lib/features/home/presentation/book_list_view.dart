import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pijar_baca/features/book/data/book_model.dart';
import 'package:pijar_baca/features/book/presentation/book_detail_screen.dart';
import 'package:pijar_baca/features/book/presentation/book_provider.dart';
import 'package:pijar_baca/features/home/presentation/widgets/book_cover_item.dart';
import 'package:pijar_baca/main.dart';
import 'package:shimmer/shimmer.dart';

class BookListView extends ConsumerWidget {
  final BookStatus status;
  const BookListView({required this.status, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsyncValue = ref.watch(booksByStatusProvider(status));

    return booksAsyncValue.when(
      data: (books) {
        if (books.isEmpty) {
          return const Center(child: Text('Rak ini masih kosong.'));
        }
        return RefreshIndicator(
          onRefresh: () async {
            // Perintahkan Riverpod untuk me-refresh data saat ditarik
            ref.invalidate(booksByStatusProvider);
            // Tunggu sebentar agar provider sempat me-refresh
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 buku per baris
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2 / 3, // Rasio sampul buku
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                // Pindahkan Card ke sini untuk membungkus InkWell
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  // Ganti GestureDetector dengan InkWell
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailScreen(book: book),
                      ),
                    ).then((_) => ref.invalidate(booksByStatusProvider));
                  },
                  onLongPress: () =>
                      _showDeleteConfirmationDialog(context, ref, book),
                  child: BookCoverItem(
                    book: book,
                  ), // BookCoverItem tidak lagi punya Card
                ),
              );
            },
          ),
        );
      },
     loading: () => Shimmer.fromColors(
   baseColor: Colors.grey.shade300,
  highlightColor: Colors.grey.shade100,
  child: GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2 / 3,
    ),
    itemCount: 6, // Tampilkan 6 placeholder
    itemBuilder: (context, index) => const Card(),
  ),
),
      error: (err, stack) => Center(child: Text('Terjadi error: $err')),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: Text(
          'Anda yakin ingin menghapus "${book.title ?? 'buku ini'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await isarService.deleteBook(book);
              ref.invalidate(booksByStatusProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
