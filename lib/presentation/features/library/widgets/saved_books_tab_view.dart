import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/presentation/features/library/cubit/library_state.dart';
import 'package:flutter/material.dart';
// ======================= THÊM CÁC IMPORT CẦN THIẾT =======================
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audiobooks/presentation/features/library/cubit/library_cubit.dart';
import 'package:go_router/go_router.dart';

class SavedBooksTabView extends StatelessWidget {
  const SavedBooksTabView({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng BlocBuilder để lắng nghe state từ LibraryCubit.
    // Lưu ý: LibraryCubit đã được cung cấp bởi _MyBooksTabContainer ở cấp cao hơn,
    // nên cả hai tab đều có thể truy cập vào cùng một instance Cubit.
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        // ---- Hiển thị loading indicator cho các trạng thái ban đầu ----
        if (state is LibraryLoading || state is LibraryInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        // ---- Xử lý trạng thái tải thành công ----
        if (state is LibraryLoaded) {
          // 1. Kiểm tra xem danh sách sách đã lưu có rỗng không
          if (state.savedBooks.isEmpty) {
            // Nếu rỗng, hiển thị giao diện "Chưa có sách"
            return const _EmptySavedBooksView();
          }

          // 2. Nếu có dữ liệu, hiển thị danh sách
          return RefreshIndicator(
            onRefresh: () async {
              // Khi người dùng kéo để làm mới, gọi lại hàm fetch tổng
              await context.read<LibraryCubit>().fetchAllLibraryContent();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.savedBooks.length,
              itemBuilder: (context, index) {
                final book = state.savedBooks[index];
                // Sử dụng một widget item được thiết kế riêng
                return _SavedBookListItem(
                  book: book,
                  allSavedBooks: state.savedBooks,
                  currentIndex: index,
                );
              },
            ),
          );
        }

        // ---- Xử lý các trạng thái lỗi hoặc không xác định ----
        // Thường thì lỗi sẽ được xử lý bởi BlocListener ở cấp cao hơn,
        // nhưng chúng ta có thể thêm một fallback ở đây.
        return const Center(child: Text('Đã có lỗi xảy ra.'));
      },
    );
  }
}

class _EmptySavedBooksView extends StatelessWidget {
  const _EmptySavedBooksView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Chưa có sách nào được lưu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Những cuốn sách bạn thêm từ Trang chủ sẽ xuất hiện ở đây.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedBookListItem extends StatelessWidget {
  final BookEntity book;
  final List<BookEntity> allSavedBooks;
  final int currentIndex;

  const _SavedBookListItem({
    required this.book,
    required this.allSavedBooks,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Image.network(
            book.coverImageUrl,
            width: 50,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.book, size: 40);
            },
          ),
        ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(book.author),
        onTap: () {
          // Điều hướng đến PlayerPage, truyền vào danh sách sách đã lưu
          context.push(
            '/player',
            extra: {'books': allSavedBooks, 'index': currentIndex},
          );
        },
      ),
    );
  }
}
