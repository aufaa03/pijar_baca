import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pijar_baca/core/services/ai_service.dart';
import 'package:pijar_baca/features/book/data/book_model.dart';
import 'package:pijar_baca/features/book/presentation/book_provider.dart';
import 'package:pijar_baca/features/quiz/data/quiz_model.dart';
import 'package:pijar_baca/features/quiz/presentation/quiz_screen.dart';
import 'package:pijar_baca/main.dart';
import 'package:pijar_baca/features/home/presentation/streak_provider.dart';
import 'package:pijar_baca/features/streak/presentation/streak_detail_provider.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  final _aiService = AIService();
  final _questionController = TextEditingController();
  String? _aiAnswer;
  bool _isLoadingAI = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final progress = (book.currentPage ?? 0) / (book.totalPages ?? 1);

    return Scaffold(
      appBar: AppBar(title: Text(book.title ?? 'Detail Buku')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: book.coverUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.book_outlined),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title ?? 'Tanpa Judul',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'oleh ${book.author ?? 'Tanpa Penulis'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Chip(label: Text('${book.totalPages ?? 0} Halaman')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (book.description != null && book.description!.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deskripsi',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Tombol Mulai Membaca
          if (book.status == BookStatus.wishlist)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('Mulai Membaca'),
                onPressed: () async {
                  // Ubah status buku
                  await isarService.startReadingBook(book);
                  // Refresh rak buku
                  ref.invalidate(booksByStatusProvider);

                  // 🔔 Set reminder harian
                  await notificationService.scheduleDailyReminder();

                  // Kembali ke halaman utama
                  if (mounted) Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

          // Kalau statusnya lagi dibaca → tampilkan progres & AI
          if (book.status == BookStatus.reading) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progres Bacaan',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Halaman ${book.currentPage ?? 0} dari ${book.totalPages ?? 0} (${(progress * 100).toStringAsFixed(0)}%)',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () =>
                            _showUpdateProgressDialog(context, ref, book),
                        icon: const Icon(Icons.edit_note),
                        label: const Text('Update Progres'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Kupas Tuntas Isi Buku',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text(
                      'Tanya apa saja tentang buku ini!',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Apa tema utama buku ini?',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoadingAI ? null : _askAI,
                      icon: const Icon(Icons.psychology),
                      label: const Text('Tanya AI'),
                    ),
                    if (_isLoadingAI)
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (_aiAnswer != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jawaban AI:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SelectableText(_aiAnswer!),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- LOGIC METHODS ---
  void _askAI() async {
    if (_questionController.text.isEmpty) return;
    setState(() => _isLoadingAI = true);
    try {
      final answer = await _aiService.getInteractiveAnswer(
        widget.book,
        _questionController.text,
      );
      setState(() {
        _aiAnswer = answer;
      });
    } on RateLimitException catch (e) {
      if (mounted) _showRateLimitDialog(context, e.message);
      setState(() => _aiAnswer = null);
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }

  // --- DIALOGS ---
  void _showUpdateProgressDialog(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Progres'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Baca sampai halaman...',
                hintText: 'Halaman saat ini: ${book.currentPage ?? 0}',
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Harap masukkan nomor halaman';
                final page = int.parse(value);
                if (page <= (book.currentPage ?? 0))
                  return 'Halaman harus lebih besar';
                if (page > (book.totalPages ?? 0))
                  return 'Melebihi total halaman';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newPage = int.parse(controller.text);
                  final bool justFinished = await isarService
                      .updateBookProgress(book, newPage);
                  ref.invalidate(streakCountProvider);
                  ref.invalidate(booksByStatusProvider);
                  ref.invalidate(streakDetailsProvider);
                  ref.invalidate(streakCacheProvider);
                  setState(() {});

                  if (mounted) Navigator.pop(context);

                  if (justFinished && mounted) {
                    _showRecommendationDialog(context, book);
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showRecommendationDialog(BuildContext context, Book finishedBook) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isQuizLoading = false;
            return AlertDialog(
              title: const Text('Buku Selesai!'),
              content: FutureBuilder<String>(
                future: _aiService.getBookRecommendations(finishedBook),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('AI sedang menyiapkan rekomendasi untukmu...'),
                        SizedBox(height: 20),
                        CircularProgressIndicator(),
                      ],
                    );
                  }
                  return SingleChildScrollView(
                    child: Text(snapshot.data ?? 'Tidak ada rekomendasi.'),
                  );
                },
              ),
              actions: [
                if (isQuizLoading)
                  // ignore: dead_code
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )
                else
                  TextButton.icon(
                    icon: const Icon(Icons.quiz),
                    label: const Text('Uji Ingatanmu'),
                    onPressed: () async {
                      setState(() => isQuizLoading = true);
                      String jsonString = await _aiService.generateBookQuiz(
                        finishedBook,
                      );

                      final startIndex = jsonString.indexOf('[');
                      final endIndex = jsonString.lastIndexOf(']');

                      if (startIndex != -1 && endIndex != -1) {
                        jsonString = jsonString.substring(
                          startIndex,
                          endIndex + 1,
                        );
                      }

                      try {
                        final List<dynamic> jsonList = jsonDecode(jsonString);
                        final questions = jsonList
                            .map((json) => QuizQuestion.fromJson(json))
                            .toList();
                        if (questions.isNotEmpty && mounted) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  QuizScreen(questions: questions),
                            ),
                          );
                        } else {
                          throw Exception('Kuis kosong setelah parsing.');
                        }
                      } catch (e) {
                        print('Gagal mem-parsing JSON kuis: $e');
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'AI gagal membuat kuis. Coba lagi untuk buku lain.',
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRateLimitDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batas Penggunaan Tercapai'),
        content: Text(
          '$message\n\nFitur AI akan tersedia kembali besok setelah pukul 14:00 WIB.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}
