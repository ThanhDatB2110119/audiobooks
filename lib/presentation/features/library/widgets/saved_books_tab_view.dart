import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/presentation/features/library/cubit/library_state.dart';
import 'package:audiobooks/presentation/features/player/cubit/player_cubit.dart';
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
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<LibraryCubit>().fetchAllLibraryContent();
            },
            // Nếu danh sách rỗng, hiển thị widget rỗng CÓ THỂ CUỘN
            child: state.savedBooks.isEmpty
                ? const _ScrollableEmptySavedBooksView() // <-- Widget mới
                : ListView.builder(
                    // Nếu có dữ liệu, hiển thị ListView như cũ
                    padding: const EdgeInsets.all(8.0),
                    itemCount: state.savedBooks.length,
                    itemBuilder: (context, index) {
                      return _SavedBookListItem(
                        book: state.savedBooks[index],
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
        contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 4.0, 8.0),
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
        trailing: IconButton(
          icon: const Icon(Icons.bookmark_remove_outlined),
          color: Colors.grey[600],
          tooltip: 'Bỏ lưu',
          onPressed: () {
            // Gọi cubit để thực hiện hành động bỏ lưu
            context.read<LibraryCubit>().removeSavedBook(book);
          },
        ),
        onTap: () {
          // Điều hướng đến PlayerPage, truyền vào danh sách sách đã lưu
          context.read<PlayerCubit>().startNewPlaylist(
            allSavedBooks,
            currentIndex,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bắt đầu phát...'),
              duration: Duration(seconds: 2),
            ),
          );
          // Có thể điều hướng đến PlayerPage ngay sau đó nếu muốn
          // context.push('/player');
        },
      ),
    );
  }
}

class _ScrollableEmptySavedBooksView extends StatelessWidget {
  const _ScrollableEmptySavedBooksView();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          // Luôn cho phép cuộn, ngay cả khi nội dung không vượt quá màn hình
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            // Đảm bảo widget con chiếm ít nhất toàn bộ chiều cao của viewport
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child:
                const _EmptySavedBooksView(), // Tái sử dụng widget hiển thị rỗng cũ
          ),
        );
      },
    );
  }
}
