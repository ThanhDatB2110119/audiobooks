import 'package:audiobooks/presentation/features/auth/widgets/sign_out_button.dart';
import 'package:audiobooks/presentation/features/home/cubit/home_cubit.dart';
import 'package:audiobooks/presentation/features/home/cubit/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Cung cấp HomeCubit cho cây widget con.
    //    - Sử dụng GetIt để lấy instance đã được đăng ký.
    //    - Dùng toán tử `..` (cascade) để gọi `fetchBooks()` ngay sau khi Cubit được tạo.
    //      Điều này giúp tải dữ liệu ngay khi màn hình được build.
    return BlocProvider(
      create: (_) => GetIt.instance<HomeCubit>()..fetchBooks(),
      child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(
              150.0,
            ), // Tăng chiều cao AppBar
            child: AppBar(
              backgroundColor: Colors.blue, // Thêm màu nền xanh cho AppBar
              // Giữ nguyên AppBar của bạn, có thể đổi title cho phù hợp hơn
              title: const Text('Thư viện sách nói'),
              actions: const [
                SignOutButton(), // Giữ nguyên nút SignOut của bạn
              ],
            ),
          ),
          // 2. Sử dụng BlocBuilder để lắng nghe sự thay đổi state từ HomeCubit
          //    và rebuild UI tương ứng.
          body: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              // 3. Xử lý các trạng thái khác nhau của UI

              // Trạng thái đang tải dữ liệu
              if (state is HomeLoading) {
                //return const Center(child: CircularProgressIndicator());
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ).animate().shimmer(duration: 800.ms);
              }

              // Trạng thái tải dữ liệu thành công
              if (state is HomeLoaded) {
                // Hiển thị danh sách sách
                return Column(
                  children: [
                    // Danh sách sách hoặc thông báo không có sách
                    Expanded(
                      child: state.books.isEmpty
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: const Text(
                                  'Hiện chưa có sách nào trong thư viện.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: state.books.length,
                              itemBuilder: (context, index) {
                                final book = state.books[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(10.0),
                                    leading: AspectRatio(
                                      aspectRatio: 2 / 3,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          4.0,
                                        ),
                                        child: Image.network(
                                          book.coverImageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                    color: Colors.white,
                                                  ),
                                                ).animate().shimmer(
                                                  duration: 800.ms,
                                                );
                                              },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.book,
                                                  size: 40,
                                                  color: Colors.grey,
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      book.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(book.author),
                                    onTap: () {
                                      //context.push('/home/details/${book.id.toString()}');
                                      context.push(
                                        '/home/details/${book.id}',
                                        extra: {
                                          'books': state.books,
                                          'index': index,
                                        },
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Bạn đã chọn: ${book.title}',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              }

              // Trạng thái có lỗi xảy ra
              if (state is HomeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lỗi: ${state.message}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Cho phép người dùng thử tải lại
                          context.read<HomeCubit>().fetchBooks();
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              // Trạng thái ban đầu hoặc không xác định (hiếm khi xảy ra)
              return const Center(
                child: Text('Chào mừng bạn đến với ứng dụng!'),
              );
            },
          ),
        ),
      ),
    );
  }
}
