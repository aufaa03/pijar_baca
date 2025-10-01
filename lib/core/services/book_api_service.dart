import 'package:dio/dio.dart';
import 'package:pijar_baca/features/book/data/book_model.dart';

class BookApiService {
  final Dio _dio = Dio();

  Future<Book?> getBookByIsbn(String isbn) async {
    final url = 'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn';
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data['totalItems'] > 0) {
        final item = response.data['items'][0]['volumeInfo'];

        return Book()
          ..title = item['title']
          ..author = (item['authors'] as List).join(', ')
          ..totalPages = item['pageCount']
          ..coverUrl = item['imageLinks']?['thumbnail']
          ..description = item['description']
          ..status = BookStatus.wishlist // Masuk ke wishlist dulu
          ..dateAdded = DateTime.now();
      }
    } catch (e) {
      print('Error fetching book data: $e');
    }
    return null;
  }
}