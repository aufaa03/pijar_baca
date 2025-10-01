import 'package:isar/isar.dart';

// Baris ini wajib ada untuk memberitahu build_runner
// bahwa file ini perlu di-generate.
part 'book_model.g.dart';

@collection // Menandakan bahwa kelas ini adalah sebuah tabel di database.
class Book {
  Id id = Isar.autoIncrement; // Kunci primer yang akan bertambah otomatis.

  @Index() // Membuat index untuk pencarian yang lebih cepat berdasarkan status.
  @Enumerated(EnumType.name)
  late BookStatus status;

  String? title;
  String? author;
  String? coverUrl; // URL gambar sampul buku.
  String? description;
  int? totalPages;
  int? currentPage;
  

  DateTime? dateAdded;
  DateTime? dateFinished;
}


// Enum untuk status buku.
// Menyimpannya sebagai nama (String) lebih mudah dibaca di database.
enum BookStatus {
  reading,
  finished,
  wishlist
}