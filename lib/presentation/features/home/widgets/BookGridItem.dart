import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/presentation/features/home/widgets/_InfoChip.dart';
import 'package:flutter/material.dart';



class BookGridItem extends StatelessWidget {
  final BookEntity book;
  final VoidCallback onTap;

  const BookGridItem({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Thêm một đường viền và đổ bóng nhẹ
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Phần ảnh bìa ---
              Expanded(
                child: Image.network(
                  book.coverImageUrl,
                  width: double.infinity, // Chiếm hết chiều rộng của container
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    // Bạn có thể dùng Shimmer effect ở đây nếu muốn
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.book, color: Colors.grey, size: 50));
                  },
                ),
              ),

              // --- Phần thông tin sách ---
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dòng 1: Tên sách
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Dòng 2 & 3: Thể loại và Tác giả
                    Wrap(
                      spacing: 6.0, // Khoảng cách giữa các chip
                      runSpacing: 4.0,
                      children: [
                        // Chip Thể loại
                        InfoChip(
                          text: book.categoryName,
                          backgroundColor: Colors.blue,
                        ),
                        // Chip Tác giả
                        InfoChip(
                          text: book.author,
                          backgroundColor: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}