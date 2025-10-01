// Lokasi: lib/features/home/presentation/bookshelf_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pijar_baca/features/book/data/book_model.dart';
import 'package:pijar_baca/features/book/presentation/add_book_screen.dart';
import 'package:pijar_baca/features/home/presentation/book_list_view.dart';
import 'package:pijar_baca/features/stats/presentation/stats_screen.dart';
import 'package:pijar_baca/features/book/presentation/scan_isbn_screen.dart';
import 'package:pijar_baca/features/book/presentation/book_provider.dart';
import 'package:pijar_baca/features/settings/presentation/settings_screen.dart';
import 'package:pijar_baca/features/book/presentation/add_by_isbn_screen.dart';
import 'package:pijar_baca/features/streak/presentation/streak_detail_screen.dart';
import 'package:pijar_baca/features/streak/presentation/streak_detail_provider.dart';
// import 'package:pijar_baca/features/streak/presentation/streak_cache_provider.dart';
import 'package:pijar_baca/main.dart'; // buat akses isarService

class BookshelfScreen extends ConsumerStatefulWidget {
  const BookshelfScreen({super.key});

  @override
  ConsumerState<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends ConsumerState<BookshelfScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await isarService.checkAndUpdateStreak();
      ref.invalidate(streakDetailsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final readingBooks = ref.watch(booksByStatusProvider(BookStatus.reading));
    final finishedBooks = ref.watch(booksByStatusProvider(BookStatus.finished));
    final wishlistBooks = ref.watch(booksByStatusProvider(BookStatus.wishlist));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pijar Baca'),
          centerTitle: true,
          actions: [
            Consumer(
              builder: (context, ref, child) {
                final cacheAsync = ref.watch(streakCacheProvider);
                final detailsAsync = ref.watch(streakDetailsProvider);

                return cacheAsync.when(
                  data: (cached) {
                    int current = cached['current'] ?? 0;
                    print("data streak cache : $current");

                    return detailsAsync.when(
                      data: (fresh) {
                        current = fresh['current'] ?? current;
                    print("data streak details : $current");

                        IconData iconData = Icons.whatshot_outlined;
                        Color iconColor = Colors.grey.shade600;

                        if (current > 0 && current <= 7) {
                          iconData = Icons.local_fire_department_outlined;
                          iconColor = Colors.orange.shade700;
                        } else if (current > 7) {
                          iconData = Icons.local_fire_department;
                          iconColor = Colors.red.shade700;
                        }

                        return TextButton(
                          onPressed: () {
                            ref.invalidate(streakDetailsProvider);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DetailStreakScreen(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(iconData, color: iconColor),
                              const SizedBox(width: 4),
                              TweenAnimationBuilder<int>(
                                tween: IntTween(begin: 0, end: current),
                                duration: const Duration(milliseconds: 800),
                                builder: (context, value, child) {
                                  return Text(
                                    value.toString(),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .appBarTheme
                                          .foregroundColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => _loadingStreak(current),
                      error: (e, s) => const Icon(Icons.error),
                    );
                  },
                  loading: () => const SizedBox(
                    width: 48,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (e, s) => const Icon(Icons.error),
                );
              },
            ),

            // Tombol Statistik
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsScreen()),
                );
              },
              icon: const Icon(Icons.bar_chart),
              tooltip: 'Statistik',
            ),
            // Tombol Pengaturan
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              tooltip: 'Pengaturan',
            ),
          ],
          bottom: TabBar(
            tabs: [
              _TabWithCounter(
                title: 'Sedang Dibaca',
                booksAsyncValue: readingBooks,
              ),
              _TabWithCounter(
                title: 'Selesai Dibaca',
                booksAsyncValue: finishedBooks,
              ),
              _TabWithCounter(
                title: 'Ingin Dibaca',
                booksAsyncValue: wishlistBooks,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BookListView(status: BookStatus.reading),
            BookListView(status: BookStatus.finished),
            BookListView(status: BookStatus.wishlist),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Tambah Manual'),
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
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text('Scan ISBN'),
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
                  ListTile(
                    leading: const Icon(Icons.numbers),
                    title: const Text('Ketik ISBN'),
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
            );
          },
          child: const Icon(Icons.add),
          tooltip: 'Tambah Buku',
        ),
      ),
    );
  }

  Widget _loadingStreak(int cached) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 4),
        Text(cached.toString()), // sementara pake cache
      ],
    );
  }
}

// Helper widget untuk tab dengan counter
class _TabWithCounter extends StatelessWidget {
  final String title;
  final AsyncValue<List<Book>> booksAsyncValue;

  const _TabWithCounter({required this.title, required this.booksAsyncValue});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          booksAsyncValue.when(
            data: (books) => CircleAvatar(
              radius: 10,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                books.length.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            loading: () => const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (err, stack) => const Icon(Icons.error, size: 16),
          ),
        ],
      ),
    );
  }
}
