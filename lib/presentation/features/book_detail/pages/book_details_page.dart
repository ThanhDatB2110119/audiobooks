import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/presentation/features/book_detail/cubit/book_details_cubit.dart';
import 'package:audiobooks/presentation/features/book_detail/cubit/book_details_state.dart';
import 'package:audiobooks/presentation/features/player/cubit/player_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class BookDetailsPage extends StatelessWidget {
  final String bookId;

  final List<BookEntity> books;
  final int currentIndex;

  const BookDetailsPage({
    super.key,
    required this.bookId,
    required this.books,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.instance<BookDetailsCubit>()..fetchBookDetails(bookId),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            // AppBar sẽ hiển thị tiêu đề sách khi dữ liệu được tải xong
            title: BlocBuilder<BookDetailsCubit, BookDetailsState>(
              builder: (context, state) {
                if (state is BookDetailsLoaded) {
                  return Text(state.book.title);
                }
                return const Text('Đang tải...');
              },
            ),
            actions: [
              BlocBuilder<BookDetailsCubit, BookDetailsState>(
                builder: (context, state) {
                  if (state is BookDetailsLoaded) {
                    return IconButton(
                      icon: Icon(
                        state.isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () =>
                          context.read<BookDetailsCubit>().toggleSaveStatus(),
                      tooltip: state.isSaved ? 'Bỏ lưu' : 'Lưu sách',
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocBuilder<BookDetailsCubit, BookDetailsState>(
            builder: (context, state) {
              if (state is BookDetailsLoading || state is BookDetailsInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is BookDetailsLoaded) {
                final book = state.book;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Ảnh bìa
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          book.coverImageUrl,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tiêu đề sách
                      Text(
                        book.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Tác giả
                      Text(
                        'Tác giả: ${book.author}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                            ),
                      ),

                      const SizedBox(height: 12),
                      Chip(
                        label: Text(
                          book.categoryName,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      ),

                      const SizedBox(height: 24),
                      // Nút Phát
                      // ElevatedButton.icon(
                      //   style: ElevatedButton.styleFrom(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 40,
                      //       vertical: 15,
                      //     ),
                      //     textStyle: const TextStyle(fontSize: 18),
                      //   ),
                      //   onPressed: () {
                      //     //Điều hướng tới màn hình Player
                      //     final currentState = context
                      //         .read<BookDetailsCubit>()
                      //         .state;

                      //     // Đảm bảo state là Loaded và có dữ liệu sách
                      //     if (currentState is BookDetailsLoaded) {
                      //       // 1. Ra lệnh cho PlayerCubit (singleton) bắt đầu phát.
                      //       // Vì chỉ có 1 cuốn sách, chúng ta tạo một playlist chỉ chứa cuốn sách đó.
                      //       context.read<PlayerCubit>().startNewPlaylist(
                      //         books,
                      //         currentIndex,
                      //       );

                      //       // 2. Hiển thị thông báo cho người dùng
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         const SnackBar(
                      //           content: Text('Bắt đầu phát...'),
                      //           duration: Duration(seconds: 2),
                      //         ),
                      //       );
                      //     }
                      //   },
                      //   icon: const Icon(Icons.play_arrow),
                      //   label: const Text('Phát sách'),
                      // ),
                      const SizedBox(height: 24),
                      // Mô tả sách
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Mô tả',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Divider(height: 20),
                      Text(
                        book.description,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'Các phần',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(height: 20),
                      (book.parts == null || book.parts!.isEmpty)
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Không tìm thấy các phần của sách.',
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: book.parts!.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemBuilder: (context, index) {
                                final part = book.parts?[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text('${part?.partNumber}'),
                                  ),
                                  title: Text(part?.title ?? ''),
                                  trailing: const Icon(
                                    Icons.play_circle_outline,
                                  ),
                                  onTap: () {
                                    // 1. Kiểm tra xem `parts` có rỗng hay không trước khi sử dụng.
                                    //    Mặc dù chúng ta đã có kiểm tra ở trên, thêm ở đây để tăng độ an toàn.
                                    if (book.parts!.isEmpty) return;

                                    // 2. Sử dụng `.map` và chuyển đổi sang List<BookEntity> "ảo"
                                    final playlist = book.parts!.map((p) {
                                      return BookEntity(
                                        // Dùng id của PART làm id chính để PlayerCubit nhận diện
                                        id: int.tryParse(p.id) ?? 0,
                                        title:
                                            '${book.title} - ${p.title}', // Ghép tên sách và tên phần
                                        author: book.author,
                                        description: book.description,
                                        coverImageUrl: book.coverImageUrl,
                                        categoryId: book.categoryId,
                                        categoryName: book.categoryName,
                                        // Quan trọng: Gán audioUrl của phần này
                                        audioUrl: p.audioUrl,
                                        // `parts` của BookEntity "ảo" này không cần thiết
                                        parts: const [],
                                      );
                                    }).toList(); // Chuyển từ Iterable sang List

                                    // 3. Ra lệnh cho PlayerCubit bắt đầu phát từ phần được chọn
                                    context
                                        .read<PlayerCubit>()
                                        .startNewPlaylist(playlist, index);

                                    // 4. Điều hướng đến trang Player
                                    context.push('/player');
                                  },
                                );
                              },
                            ),
                    ],
                  ),
                );
              }

              if (state is BookDetailsError) {
                return Center(child: Text('Lỗi: ${state.message}'));
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
