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
          return _buildEmptyState(context, ref);
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(booksByStatusProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          color: Theme.of(context).colorScheme.primary,
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2 / 3,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return _buildBookCard(context, ref, book);
            },
          ),
        );
      },
      loading: () => _buildShimmerLoading(),
      error: (err, stack) => _buildErrorState(context, ref, err),
    );
  }

  Widget _buildBookCard(BuildContext context, WidgetRef ref, Book book) {
    final coverUrl = book.coverUrl ?? '';
    final title = book.title ?? 'Judul Tidak Tersedia';
    final author = book.author ?? 'Penulis Tidak Tersedia';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailScreen(book: book),
              ),
            ).then((_) => ref.invalidate(booksByStatusProvider));
          },
          onLongPress: () => _showDeleteConfirmationDialog(context, ref, book),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover with Progress Indicator
                Stack(
                  children: [
                    // Book Cover
                    Container(
                      width: double.infinity,
                      height: 100, // Reduced from 120
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        image: coverUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(coverUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: coverUrl.isEmpty
                          ? Center(
                              child: Icon(
                                Icons.book_rounded,
                                size: 28, // Reduced from 32
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.6),
                              ),
                            )
                          : null,
                    ),

                    // Progress Indicator for Reading Books
                    if (status == BookStatus.reading &&
                        book.currentPage != null &&
                        book.totalPages != null &&
                        book.totalPages! > 0)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.all(4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: book.currentPage! / book.totalPages!,
                              backgroundColor: Colors.black.withOpacity(0.2),
                              color: _getProgressColor(
                                context,
                                book.currentPage! / book.totalPages!,
                              ),
                              minHeight: 3,
                            ),
                          ),
                        ),
                      ),

                    // Status Badge
                    if (status != BookStatus.reading)
                      Positioned(
                        top: 4, // Reduced from 6
                        right: 4, // Reduced from 6
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ), // Reduced
                          decoration: BoxDecoration(
                            color: _getStatusColor(context, status),
                            borderRadius: BorderRadius.circular(
                              4,
                            ), // Reduced from 6
                          ),
                          child: Icon(
                            _getStatusIcon(status),
                            size: 10, // Reduced from 12
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8), // Reduced from 12
                // Book Title - FIXED: Using Expanded to prevent overflow
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 2), // Reduced from 4
                // Author
                Text(
                  author,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4), // Added small spacing
                // Progress Text for Reading Books
                if (status == BookStatus.reading &&
                    book.currentPage != null &&
                    book.totalPages != null)
                  Text(
                    '${book.currentPage}/${book.totalPages}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 10, // Smaller font
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24), // Reduced from 32
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, // Reduced from 120
                height: 100, // Reduced from 120
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 40, // Reduced from 48
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20), // Reduced from 24
              Text(
                _getEmptyStateTitle(status),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _getEmptyStateSubtitle(status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20), // Reduced from 24
              FilledButton(
                onPressed: () {
                  _showAddBookModal(context, ref);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ), // Reduced
                ),
                child: const Text('Tambah Buku'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBookModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            // Header Modal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tambah Buku Baru',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih cara menambahkan buku ke koleksimu',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Options
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  _buildModalOption(
                    context,
                    icon: Icons.edit_rounded,
                    title: 'Tambah Manual',
                    subtitle: 'Isi detail buku secara manual',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to AddBookScreen - you'll need to import this
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => AddBookScreen()));
                    },
                  ),
                  _buildDivider(),
                  _buildModalOption(
                    context,
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Scan ISBN',
                    subtitle: 'Scan barcode buku menggunakan kamera',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to ScanIsbnScreen - you'll need to import this
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => ScanIsbnScreen()));
                    },
                  ),
                  _buildDivider(),
                  _buildModalOption(
                    context,
                    icon: Icons.numbers_rounded,
                    title: 'Ketik ISBN',
                    subtitle: 'Masukkan nomor ISBN secara manual',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to AddByIsbnScreen - you'll need to import this
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => AddByIsbnScreen()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.withOpacity(0.1),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2 / 3,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 10,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                ref.invalidate(booksByStatusProvider);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) {
    final title = book.title ?? 'buku ini';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Buku',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Anda yakin ingin menghapus "$title" dari koleksi?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.6),
            ),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await isarService.deleteBook(book);
              ref.invalidate(booksByStatusProvider);
              if (context.mounted) Navigator.pop(context);

              // Show snackbar confirmation
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    content: Text(
                      '"$title" berhasil dihapus',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getEmptyStateTitle(BookStatus status) {
    switch (status) {
      case BookStatus.reading:
        return 'Belum Ada Buku Sedang Dibaca';
      case BookStatus.finished:
        return 'Belum Ada Buku Selesai';
      case BookStatus.wishlist:
        return 'Belum Ada Wishlist';
    }
  }

  String _getEmptyStateSubtitle(BookStatus status) {
    switch (status) {
      case BookStatus.reading:
        return 'Mulai baca buku pertama Anda dan lacak progresnya di sini';
      case BookStatus.finished:
        return 'Buku yang sudah selesai dibaca akan muncul di sini';
      case BookStatus.wishlist:
        return 'Tambahkan buku yang ingin Anda baca nanti';
    }
  }

  Color _getProgressColor(BuildContext context, double progress) {
    if (progress < 0.25) return Colors.red.shade400;
    if (progress < 0.5) return Colors.orange.shade400;
    if (progress < 0.75) return Colors.yellow.shade600;
    return Colors.green.shade500;
  }

  Color _getStatusColor(BuildContext context, BookStatus status) {
    switch (status) {
      case BookStatus.finished:
        return Colors.green.shade500;
      case BookStatus.wishlist:
        return Colors.blue.shade500;
      case BookStatus.reading:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getStatusIcon(BookStatus status) {
    switch (status) {
      case BookStatus.finished:
        return Icons.check_rounded;
      case BookStatus.wishlist:
        return Icons.bookmark_rounded;
      case BookStatus.reading:
        return Icons.book_rounded;
    }
  }
}
