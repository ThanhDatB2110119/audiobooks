import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/presentation/features/book_detail/cubit/book_details_cubit.dart';
import 'package:audiobooks/presentation/features/book_detail/cubit/book_details_state.dart';
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
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        onPressed: () {
                          // TODO: Điều hướng tới màn hình Player
                          context.push(
                            '/player',
                            extra: {'books': books, 'index': currentIndex},
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sẽ mở màn hình Player...'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Phát sách'),
                      ),
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
