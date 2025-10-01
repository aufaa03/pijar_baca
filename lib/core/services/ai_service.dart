import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pijar_baca/features/book/data/book_model.dart';


// Ini akan membantu kita mengidentifikasi error limit dengan lebih mudah di UI.
class RateLimitException implements Exception {
  final String message;
  RateLimitException(this.message);
}

class AIService {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: dotenv.env['GEMINI_API_KEY']!,
  );

 Future<String> getBookRecommendations(Book finishedBook) async {
    try {
      final prompt =
          'Saya baru saja selesai membaca buku "${finishedBook.title}" oleh ${finishedBook.author}. '
          'Tolong berikan 5 rekomendasi buku lain dengan tema atau gaya penulisan yang mirip. '
          'Berikan jawaban dalam format daftar bernomor (numbered list). '
          'Untuk setiap buku, sebutkan judul dan penulisnya saja dalam format: Judul Buku - Penulis.';
      
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ?? 'Maaf, tidak bisa memberikan rekomendasi saat ini.';
    } on GenerativeAIException catch (e) {
      // Periksa apakah pesan error mengandung kode '429'
      if (e.message.contains('429')) {
        throw RateLimitException('Batas penggunaan AI harian telah tercapai.');
      }
      return 'Terjadi kesalahan saat meminta rekomendasi. Coba lagi nanti.';
    }
  }

  Future<String> getInteractiveAnswer(Book book, String userQuestion) async {
    try {
      final prompt =
          'Dalam konteks buku "${book.title}" oleh ${book.author}, jawab pertanyaan berikut dengan jelas dan ringkas: "$userQuestion"';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ?? 'Maaf, saya tidak bisa menjawab pertanyaan itu saat ini.';
    } on GenerativeAIException catch (e) {
      if (e.message.contains('429')) {
        throw RateLimitException('Batas penggunaan AI harian telah tercapai.');
      }
      return 'Terjadi kesalahan saat memproses jawaban. Coba lagi nanti.';
    }
  }

  Future<String> generateBookQuiz(Book finishedBook) async {
    try {
      final prompt =
          'Saya baru selesai membaca buku "${finishedBook.title}" oleh ${finishedBook.author}. '
          'Buatkan saya kuis singkat berisi 3 pertanyaan pilihan ganda (A, B, C, D) untuk menguji pemahaman saya tentang plot atau karakter penting dari buku tersebut. '
          'PENTING: Berikan jawaban HANYA dalam format JSON yang valid. '
          'Struktur JSON harus berupa array dari objek, di mana setiap objek memiliki kunci "question" (string), "options" (array of string), dan "correct_answer_index" (integer 0-3).';
      
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ?? '[]';
    } on GenerativeAIException catch (e) {
      if (e.message.contains('429')) {
        throw RateLimitException('Batas penggunaan AI harian telah tercapai.');
      }
      return '[]';
    }
  }
}