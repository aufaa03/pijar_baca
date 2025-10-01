import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pijar_baca/features/book/data/book_model.dart';
import 'package:google_fonts/google_fonts.dart';

class BookCoverItem extends StatelessWidget {
  final Book book;
  const BookCoverItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // Agar gambar mengikuti bentuk Card
      child: book.coverUrl != null && book.coverUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: book.coverUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) => _buildErrorCover(),
            )
          : _buildErrorCover(),
    );
  }

 Widget _buildErrorCover() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.grey.shade300, Colors.grey.shade400],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    padding: const EdgeInsets.all(8),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            book.title ?? 'Tanpa Judul',
            textAlign: TextAlign.center,
            style: GoogleFonts.lora( // Gunakan font judul kita
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            book.author ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
}