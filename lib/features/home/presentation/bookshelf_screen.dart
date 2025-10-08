import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pijar_baca/features/book/data/book_model.dart';
import 'package:pijar_baca/features/book/presentation/add_book_screen.dart';
import 'package:pijar_baca/features/book/presentation/book_detail_screen.dart';
import 'package:pijar_baca/features/stats/presentation/stats_screen.dart';
import 'package:pijar_baca/features/book/presentation/scan_isbn_screen.dart';
import 'package:pijar_baca/features/book/presentation/book_provider.dart';
import 'package:pijar_baca/features/settings/presentation/settings_screen.dart';
import 'package:pijar_baca/features/book/presentation/add_by_isbn_screen.dart';
import 'package:pijar_baca/features/streak/presentation/streak_detail_screen.dart';
import 'package:pijar_baca/features/streak/presentation/streak_detail_provider.dart';
import 'package:pijar_baca/main.dart';

class BookshelfScreen extends ConsumerStatefulWidget {
  const BookshelfScreen({super.key});

  @override
  ConsumerState<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends ConsumerState<BookshelfScreen> {
  int _currentIndex = 0;
  final List<BookStatus> _tabStatus = [
    BookStatus.reading,
    BookStatus.finished,
    BookStatus.wishlist,
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await isarService.checkAndUpdateStreak();
      ref.invalidate(streakDetailsProvider);
    });
  }

  void _showAddBookModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: Wrap(
          children: [
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddBookScreen(),
                        ),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanIsbnScreen(),
                        ),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddByIsbnScreen(),
                        ),
                      );
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

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int itemCount,
    required bool isActive,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: isActive
                  ? Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.4),
                    ),
                    if (itemCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade500,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            itemCount > 9 ? '9+' : itemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final currentBooks = ref.watch(
      booksByStatusProvider(_tabStatus[_currentIndex]),
    );
    final totalBooks = currentBooks.maybeWhen(
      data: (books) => books.length,
      orElse: () => 0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getHeaderTitle(_currentIndex),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalBooks Buku',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _getHeaderSubtitle(_currentIndex),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDarkMode
          ? colorScheme.surface
          : Colors.white, // PAKAI WHITE BERSIH DI LIGHT MODE
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailScreen(book: book),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDarkMode
                ? colorScheme.surface
                : Colors.white, // BACKGROUND PUTIH BERSIH
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  isDarkMode ? 0.1 : 0.08,
                ), // SHADOW LEBIH SOFT DI LIGHT MODE
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: isDarkMode
                ? null
                : Border.all(
                    color: Colors
                        .grey
                        .shade100, // BORDER SANGAT HALUS DI LIGHT MODE
                    width: 1,
                  ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Cover
                  Container(
                    height: constraints.maxHeight * 0.7,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      color: isDarkMode
                          ? colorScheme.surfaceVariant
                          : Colors
                                .grey
                                .shade50, // BACKGROUND COVER LEBIH TERANG DI LIGHT MODE
                    ),
                    child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Image.network(
                              book.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderCover(
                                  colorScheme,
                                  isDarkMode,
                                );
                              },
                            ),
                          )
                        : _buildPlaceholderCover(colorScheme, isDarkMode),
                  ),

                  // Book Info
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Judul
                              Text(
                                book.title ?? 'Tanpa Judul',
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  color: isDarkMode
                                      ? colorScheme.onSurface
                                      : Colors
                                            .grey
                                            .shade800, // TEXT LEBIH GELAP DI LIGHT MODE
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              // Author
                              Text(
                                book.author ?? 'Tanpa Penulis',
                                style: textTheme.labelSmall?.copyWith(
                                  color: isDarkMode
                                      ? colorScheme.onSurface.withOpacity(0.7)
                                      : Colors
                                            .grey
                                            .shade600, // AUTHOR LEBIH CONTRAST DI LIGHT MODE
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          // Status Section
                          _buildBookStatus(
                            book,
                            colorScheme,
                            textTheme,
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookStatus(
    Book book,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDarkMode,
  ) {
    if (book.status == BookStatus.reading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: (book.currentPage ?? 0) / (book.totalPages ?? 1),
            backgroundColor: isDarkMode
                ? colorScheme.surfaceVariant
                : Colors.grey.shade200,
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
            minHeight: 3,
          ),
          const SizedBox(height: 2),
          Text(
            '${book.currentPage ?? 0}/${book.totalPages ?? 0}',
            style: textTheme.labelSmall?.copyWith(
              color: isDarkMode
                  ? colorScheme.onSurface.withOpacity(0.6)
                  : Colors.grey.shade600,
              fontSize: 9,
            ),
          ),
        ],
      );
    } else if (book.status == BookStatus.finished) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(
            isDarkMode ? 0.1 : 0.15,
          ), // LEBIH TERANG DI LIGHT MODE
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 10, color: Colors.green),
            const SizedBox(width: 2),
            Text(
              'Selesai',
              style: textTheme.labelSmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
            ),
          ],
        ),
      );
    } else {
      return Text(
        '${book.totalPages ?? 0} hlm',
        style: textTheme.labelSmall?.copyWith(
          color: isDarkMode
              ? colorScheme.onSurface.withOpacity(0.5)
              : Colors.grey.shade500,
          fontSize: 9,
        ),
      );
    }
  }

  Widget _buildPlaceholderCover(ColorScheme colorScheme, bool isDarkMode) {
    return Container(
      color: isDarkMode
          ? colorScheme.surfaceVariant
          : Colors.grey.shade100, // BACKGROUND LEBIH TERANG DI LIGHT MODE
      child: Center(
        child: Icon(
          Icons.book_rounded,
          color: isDarkMode
              ? colorScheme.onSurfaceVariant
              : Colors.grey.shade400, // ICON LEBIH SOFT DI LIGHT MODE
          size: 36,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada buku',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateMessage(_currentIndex),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyStateMessage(int index) {
    switch (index) {
      case 0:
        return 'Mulai baca buku pertama Anda\natau tambah dari wishlist';
      case 1:
        return 'Belum ada buku yang selesai dibaca';
      case 2:
        return 'Tambahkan buku yang ingin\nAnda baca nanti';
      default:
        return 'Belum ada buku dalam koleksi';
    }
  }

  String _getHeaderTitle(int index) {
    switch (index) {
      case 0:
        return 'Sedang Dibaca';
      case 1:
        return 'Buku Selesai';
      case 2:
        return 'Wishlist';
      default:
        return 'Koleksi Buku';
    }
  }

  String _getHeaderSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Lanjutkan membaca buku-buku yang sedang kamu baca';
      case 1:
        return 'Lihat semua buku yang sudah berhasil kamu selesaikan';
      case 2:
        return 'Simpan buku yang ingin kamu baca nanti';
      default:
        return 'Kelola koleksi buku kamu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final readingBooks = ref.watch(booksByStatusProvider(BookStatus.reading));
    final finishedBooks = ref.watch(booksByStatusProvider(BookStatus.finished));
    final wishlistBooks = ref.watch(booksByStatusProvider(BookStatus.wishlist));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Pijar Baca',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          // Streak Widget
          Consumer(
            builder: (context, ref, child) {
              final detailsAsync = ref.watch(streakDetailsProvider);

              return detailsAsync.when(
                data: (data) {
                  final current = data['current'] ?? 0;
                  IconData iconData = Icons.emoji_events_outlined;
                  Color iconColor = Colors.grey.shade400;

                  if (current > 0 && current <= 7) {
                    iconData = Icons.local_fire_department_outlined;
                    iconColor = Colors.orange.shade600;
                  } else if (current > 7) {
                    iconData = Icons.local_fire_department;
                    iconColor = Colors.red.shade600;
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DetailStreakScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(iconData, color: iconColor, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            current.toString(),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(right: 8),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (e, s) => const Icon(Icons.error_outline, size: 20),
              );
            },
          ),

          // Statistics Button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
            icon: Icon(
              Icons.bar_chart_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: 'Statistik',
          ),

          // Settings Button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: Icon(
              Icons.settings_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: 'Pengaturan',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          _buildHeaderSection(context),

          // Book List - SESUAIKAN ASPECT RATIO
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final booksAsync = ref.watch(
                  booksByStatusProvider(_tabStatus[_currentIndex]),
                );

                return booksAsync.when(
                  data: (books) {
                    if (books.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return _buildBookCard(context, book);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 65,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _buildBottomNavItem(
                  icon: Icons.auto_stories_rounded,
                  label: 'Baca',
                  index: 0,
                  itemCount: readingBooks.maybeWhen(
                    data: (books) => books.length,
                    orElse: () => 0,
                  ),
                  isActive: _currentIndex == 0,
                ),
                _buildBottomNavItem(
                  icon: Icons.verified_rounded,
                  label: 'Selesai',
                  index: 1,
                  itemCount: finishedBooks.maybeWhen(
                    data: (books) => books.length,
                    orElse: () => 0,
                  ),
                  isActive: _currentIndex == 1,
                ),
                _buildBottomNavItem(
                  icon: Icons.bookmark_rounded,
                  label: 'Nanti',
                  index: 2,
                  itemCount: wishlistBooks.maybeWhen(
                    data: (books) => books.length,
                    orElse: () => 0,
                  ),
                  isActive: _currentIndex == 2,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookModal(context),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
