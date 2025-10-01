import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:pijar_baca/core/services/isar_service.dart';
import 'package:pijar_baca/features/book/data/book_model.dart';
import 'package:pijar_baca/main.dart';
part 'book_provider.g.dart';


@riverpod
Future<List<Book>> booksByStatus(BooksByStatusRef ref, BookStatus status) {
  // Provider ini akan memanggil service untuk mengambil buku berdasarkan status
  return isarService.getBooksByStatus(status);
}