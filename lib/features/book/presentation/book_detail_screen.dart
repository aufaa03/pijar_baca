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

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          book.title ?? 'Detail Buku',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onBackground,
      ),
      body: CustomScrollView(
        slivers: [
          // Header dengan cover dan info buku
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover buku
                  Container(
                    height: 160,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: book.coverUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  _buildPlaceholderCover(colorScheme),
                            )
                          : _buildPlaceholderCover(colorScheme),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Info buku
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title ?? 'Tanpa Judul',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'oleh ${book.author ?? 'Tanpa Penulis'}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${book.totalPages ?? 0} Halaman',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Deskripsi buku
          if (book.description != null && book.description!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deskripsi',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      book.description!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Tombol Mulai Membaca (untuk wishlist)
          if (book.status == BookStatus.wishlist)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FilledButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text(
                      'Mulai Membaca',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      await isarService.startReadingBook(book);
                      ref.invalidate(booksByStatusProvider);
                      await notificationService.scheduleDailyReminder();
                      if (mounted) Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      foregroundColor: colorScheme.onPrimary,
                      shadowColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),

          // Progress dan AI Section (untuk buku yang sedang dibaca)
          if (book.status == BookStatus.reading) ...[
            // Progress Section
            SliverToBoxAdapter(
              child: _buildProgressSection(context, book, progress),
            ),

            // AI Assistant Section
            SliverToBoxAdapter(child: _buildAISection(context)),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderCover(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceVariant,
      child: Icon(
        Icons.book_rounded,
        color: colorScheme.onSurfaceVariant,
        size: 40,
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    Book book,
    double progress,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Progres Bacaan',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
            color: colorScheme.primary,
            backgroundColor: colorScheme.surfaceVariant,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% selesai',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                '${book.currentPage ?? 0}/${book.totalPages ?? 0} halaman',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showUpdateProgressDialog(context, ref, book),
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Update Progres'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tanya AI',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Diskusikan buku ini dengan AI',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _questionController,
            decoration: InputDecoration(
              hintText: 'Contoh: Apa tema utama buku ini?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.3),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          // Di _buildAISection, update bagian button:
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoadingAI ? null : _askAI,
              icon: _isLoadingAI
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded, size: 18),
              label: _isLoadingAI
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Memproses'),
                        SizedBox(width: 4),
                        Text(
                          '...',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : const Text('Tanya AI'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (_aiAnswer != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Jawaban AI',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _aiAnswer!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- LOGIC METHODS ---
  // --- LOGIC METHODS ---
  void _askAI() async {
    if (_questionController.text.isEmpty) return;

    setState(() {
      _isLoadingAI = true;
      _aiAnswer = null;
    });

    // Tampilkan snackbar info untuk response yang lama
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Colors.white),
                strokeWidth: 2,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI sedang memproses pertanyaan...\nIni mungkin memakan waktu 10-30 detik',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue.shade700,
          duration: const Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    try {
      // Timeout setelah 45 detik
      final answer = await _aiService
          .getInteractiveAnswer(widget.book, _questionController.text)
          .timeout(
            const Duration(seconds: 45),
            onTimeout: () {
              throw TimeoutException(
                'AI mengambil waktu terlalu lama untuk merespon',
              );
            },
          );

      if (mounted) {
        setState(() {
          _aiAnswer = answer;
        });
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        _showTimeoutDialog(context);
      }
      setState(() => _aiAnswer = null);
    } on RateLimitException catch (e) {
      if (mounted) _showRateLimitDialog(context, e.message);
      setState(() => _aiAnswer = null);
    } catch (e) {
      if (mounted) {
        _showErrorDialog(context, e.toString());
      }
      setState(() => _aiAnswer = null);
    } finally {
      if (mounted) {
        setState(() => _isLoadingAI = false);
      }
    }
  }

  void _showTimeoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_off_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Respon Terlalu Lama',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'AI membutuhkan waktu lebih lama dari biasanya untuk merespon.\n\n'
                'Ini bisa terjadi karena:\n'
                '• Koneksi internet yang lambat\n'
                '• Server AI sedang sibuk\n'
                '• Pertanyaan yang kompleks\n\n'
                'Silakan coba lagi dalam beberapa saat.',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mengerti'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'Maaf, terjadi kesalahan saat memproses pertanyaan Anda.\n\n'
                'Silakan coba lagi nanti atau periksa koneksi internet Anda.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Progres',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Halaman saat ini',
                      hintText: 'Halaman: ${book.currentPage ?? 0}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
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
                ),
              ],
            ),
          ),
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
            return Dialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.celebration_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Buku Selesai!',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<String>(
                      future: _aiService.getBookRecommendations(finishedBook),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('AI sedang menyiapkan rekomendasi...'),
                              SizedBox(height: 16),
                              CircularProgressIndicator(),
                            ],
                          );
                        }
                        return Text(
                          snapshot.data ?? 'Tidak ada rekomendasi.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isQuizLoading)
                          // ignore: dead_code
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                        else
                          FilledButton.icon(
                            icon: const Icon(Icons.quiz_rounded, size: 18),
                            label: const Text('Uji Ingatanmu'),
                            onPressed: () async {
                              setState(() => isQuizLoading = true);
                              String jsonString = await _aiService
                                  .generateBookQuiz(finishedBook);

                              final startIndex = jsonString.indexOf('[');
                              final endIndex = jsonString.lastIndexOf(']');

                              if (startIndex != -1 && endIndex != -1) {
                                jsonString = jsonString.substring(
                                  startIndex,
                                  endIndex + 1,
                                );
                              }

                              try {
                                final List<dynamic> jsonList = jsonDecode(
                                  jsonString,
                                );
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
                                  throw Exception(
                                    'Kuis kosong setelah parsing.',
                                  );
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
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tutup'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRateLimitDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Batas Penggunaan Tercapai',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                '$message\n\nFitur AI akan tersedia kembali besok setelah pukul 14:00 WIB.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mengerti'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
