import 'package:isar/isar.dart';
import 'package:pijar_baca/features/book/data/book_model.dart';

part 'reading_session_model.g.dart';

@collection
class ReadingSession {
  Id id = Isar.autoIncrement;

  // Berapa halaman yang dibaca dalam sesi ini.
  late int pagesRead;

  // Kapan sesi membaca ini dicatat.
  @Index()
  late DateTime sessionDate;

  // Menghubungkan sesi ini ke sebuah buku.
  // Ini seperti 'foreign key' di database relasional.
  final book = IsarLink<Book>();
}