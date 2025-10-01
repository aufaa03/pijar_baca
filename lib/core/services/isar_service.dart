import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pijar_baca/features/book/data/book_model.dart';
import 'package:pijar_baca/features/book/data/reading_session_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IsarService {
  late final Isar isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [BookSchema, ReadingSessionSchema],
      directory: dir.path,
      inspector: true,
    );
  }

  Future<List<Book>> getBooksByStatus(BookStatus status) async {
    return await isar.books.filter().statusEqualTo(status).findAll();
  }

  Future<void> saveBook(Book newBook) async {
    await isar.writeTxn(() async {
      await isar.books.put(newBook);
    });
  }

  // --- TAMBAHKAN DUA METHOD BARU DI BAWAH INI ---

  // Method untuk mencatat setiap sesi membaca (penting untuk statistik nanti)
  Future<void> createReadingSession(Book book, int pagesRead) async {
    final session = ReadingSession()
      ..pagesRead = pagesRead
      ..sessionDate = DateTime.now()
      ..book.value = book;

    await isar.writeTxn(() async {
      await isar.readingSessions.put(session);
      await session.book.save(); // Simpan hubungan antara sesi dan buku
    });
  }

  // Method utama untuk memperbarui progres buku
 Future<bool> updateBookProgress(Book book, int newCurrentPage) async {
    bool justFinished = false;
    if (newCurrentPage <= (book.currentPage ?? 0)) return justFinished;

    final pagesReadThisSession = newCurrentPage - (book.currentPage ?? 0);
    book.currentPage = newCurrentPage;

    if (newCurrentPage >= (book.totalPages ?? 0)) {
      book.status = BookStatus.finished;
      book.dateFinished = DateTime.now();
      justFinished = true;
    }

    await isar.writeTxn(() async {
      await isar.books.put(book);
    });

    await createReadingSession(book, pagesReadThisSession);

    // --- TAMBAHAN BARU: Beri hadiah Permata Beku jika mencapai milestone ---
    await _grantFreezeGemIfNeeded();

    return justFinished;
  }


  // Method untuk menghapus buku beserta sesi membacanya
  Future<void> deleteBook(Book book) async {
    await isar.writeTxn(() async {
      // Hapus semua sesi membaca yang terhubung dengan buku ini
      await isar.readingSessions
          .filter()
          .book((q) => q.idEqualTo(book.id))
          .deleteAll();
      // Hapus bukunya
      await isar.books.delete(book.id);
    });
  }

  // Menghitung total buku selesai tahun ini
  Future<int> getTotalBooksFinishedThisYear() async {
    final now = DateTime.now();
    return await isar.books
        .filter()
        .statusEqualTo(BookStatus.finished)
        .dateFinishedIsNotNull()
        .dateFinishedGreaterThan(DateTime(now.year, 1, 1))
        .count();
  }

  // Mendapatkan semua tanggal sesi membaca untuk kalender
  Future<Set<DateTime>> getReadingDays() async {
    final sessions = await isar.readingSessions.where().findAll();
    // Normalisasi tanggal untuk menghilangkan jam/menit/detik
    return sessions
        .map(
          (s) => DateTime(
            s.sessionDate.year,
            s.sessionDate.month,
            s.sessionDate.day,
          ),
        )
        .toSet();
  }

  //streak api
  Future<int> calculateStreak() async {
    // Ambil semua tanggal unik kita membaca
    final readingDays = await getReadingDays();
    if (readingDays.isEmpty) return 0;

    // Urutkan dari yang terbaru
    final sortedDays = readingDays.toList()..sort((a, b) => b.compareTo(a));

    var streak = 0;
    // Normalisasi tanggal hari ini
    final today = DateTime.now();
    var checkDay = DateTime(today.year, today.month, today.day);

    // Cek apakah hari ini ada di daftar
    if (sortedDays.contains(checkDay)) {
      streak++;
    } else {
      // Jika tidak ada, mulai cek dari kemarin
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    // Iterasi mundur untuk menghitung rentetan
    for (final day in sortedDays) {
      if (day.isAtSameMomentAs(checkDay)) {
        if (streak == 0)
          streak++; // Hanya untuk kasus di mana hari ini tidak membaca
        checkDay = checkDay.subtract(const Duration(days: 1));
      } else if (day.isBefore(checkDay)) {
        // Jika ada hari yang terlewat, hentikan
        break;
      }
    }
    return streak;
  }

  // Method untuk mengubah status buku dari wishlist ke reading
  Future<void> startReadingBook(Book book) async {
    // Set status baru dan reset progres
    book.status = BookStatus.reading;
    book.currentPage = 0;

    await isar.writeTxn(() async {
      // Simpan kembali objek buku yang sudah diperbarui
      await isar.books.put(book);
    });
  }

  // --- METHOD BARU: Untuk memberi hadiah Permata Beku ---
  Future<void> _grantFreezeGemIfNeeded() async {
    final currentStreak = await calculateStreak();
    // Jika streak adalah kelipatan 7 dan bukan 0
    if (currentStreak > 0 && currentStreak % 7 == 0) {
      final prefs = await SharedPreferences.getInstance();
      // Cek apakah hadiah untuk milestone ini sudah pernah diberikan
      final lastGrantedStreak = prefs.getInt('lastGrantedStreak') ?? 0;
      if (currentStreak > lastGrantedStreak) {
        final currentGems = prefs.getInt('freezeGemCount') ?? 0;
        await prefs.setInt('freezeGemCount', currentGems + 1);
        await prefs.setInt('lastGrantedStreak', currentStreak);
        print('Hadiah: 1 Permata Beku diberikan!');
      }
    }
  }

  Future<Map<String, int>> getStreakDetails() async {
    final readingDays = await getReadingDays();
    if (readingDays.isEmpty) return {'current': 0, 'longest': 0};

    final sortedDays = readingDays.toList()..sort((a, b) => b.compareTo(a));
    final prefs = await SharedPreferences.getInstance();
    int availableGems = prefs.getInt('freezeGemCount') ?? 0;

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    DateTime today = DateTime.now();
    DateTime checkDay = DateTime(today.year, today.month, today.day);

    bool wasLastDayFrozen = false;
    int usedGems = 0;

    // Hitung current streak
    for (int i = 0; i < sortedDays.length; i++) {
      if (sortedDays.contains(checkDay)) {
        currentStreak++;
        checkDay = checkDay.subtract(const Duration(days: 1));
      } else {
        // Cek apakah hari sebelumnya adalah hari membaca
        if (i > 0 && sortedDays[i-1].isAtSameMomentAs(checkDay.add(const Duration(days: 1)))) {
            // Ini adalah hari pertama yang terlewat
            if (availableGems > usedGems && !wasLastDayFrozen) {
                // Gunakan Permata Beku
                usedGems++;
                wasLastDayFrozen = true;
                checkDay = checkDay.subtract(const Duration(days: 1)); // Lompati hari yang terlewat
                continue; // Lanjutkan loop dari hari sebelumnya
            }
        }
        break; // Hentikan jika tidak bisa menggunakan permata
      }
    }


    // Hitung longest streak
    for (int i = 0; i < sortedDays.length; i++) {
      DateTime currentDate = sortedDays[i];
      if (i > 0) {
        DateTime previousDate = sortedDays[i - 1];
        Duration diff = previousDate.difference(currentDate);
        if (diff.inDays == 1) {
          tempStreak++;
        } else {
          // Reset jika ada gap
          tempStreak = 1;
        }
      } else {
        tempStreak = 1;
      }
      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }

  Future<void> checkAndUpdateStreak() async {
    final details = await getStreakDetails();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cachedCurrentStreak', details['current'] ?? 0);
    await prefs.setInt('cachedLongestStreak', details['longest'] ?? 0);

    print(
      "✅ Cached streak updated: ${details['current']} current, ${details['longest']} longest",
    );
  }
}
