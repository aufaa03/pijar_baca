// Lokasi: lib/core/services/book_api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- Tambahkan impor ini
import 'package:pijar_baca/features/book/data/book_model.dart';

class BookApiService {
  final Dio _dio = Dio();

  Future<Book?> getBookByIsbn(String isbn) async {
    // 1. Ambil API Key dari .env
    final apiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'];

    // Jika API Key tidak ada, berikan peringatan (opsional tapi bagus)
    if (apiKey == null) {
      print('ERROR: GOOGLE_BOOKS_API_KEY tidak ditemukan di .env');
      return null;
    }

    // 2. Tambahkan parameter '&key=$apiKey' di akhir URL
    final url = 'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn&key=$apiKey';
    
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
          ..status = BookStatus.wishlist
          ..dateAdded = DateTime.now();
      }
    } catch (e) {
      print('Error fetching book data: $e');
    }
    return null;
  }
}