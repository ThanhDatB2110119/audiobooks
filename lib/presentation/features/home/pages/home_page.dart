import 'package:audiobooks/presentation/features/auth/widgets/sign_out_button.dart';
import 'package:audiobooks/presentation/features/home/cubit/home_cubit.dart';
import 'package:audiobooks/presentation/features/home/cubit/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home Page'),
//         actions: [SignOutButton()],
//       ),
//       body: const Center(child: Text('Welcome to the Home Page!')),
//     );
//   }
// }

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
      child: Scaffold(
        appBar: AppBar(
          // Giữ nguyên AppBar của bạn, có thể đổi title cho phù hợp hơn
          title: const Text('Thư viện sách nói'),
          actions: const [
            SignOutButton(), // Giữ nguyên nút SignOut của bạn
          ],
        ),
        // 2. Sử dụng BlocBuilder để lắng nghe sự thay đổi state từ HomeCubit
        //    và rebuild UI tương ứng.
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            // 3. Xử lý các trạng thái khác nhau của UI
            
            // Trạng thái đang tải dữ liệu
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Trạng thái tải dữ liệu thành công
            if (state is HomeLoaded) {
              // Xử lý trường hợp không có sách nào
              if (state.books.isEmpty) {
              return Center(
                child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Text(
                  'Hiện chưa có sách nào trong thư viện.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                ),
              );
              }
              
              // Hiển thị danh sách sách bằng ListView.builder để tối ưu hiệu năng
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.books.length,
                itemBuilder: (context, index) {
                  final book = state.books[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10.0),
                      leading: AspectRatio(
                        aspectRatio: 2 / 3, // Tỉ lệ phổ biến của bìa sách
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.network(
                            book.coverImageUrl,
                            fit: BoxFit.cover,
                            // Hiển thị placeholder trong lúc tải ảnh
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            // Hiển thị icon lỗi nếu không tải được ảnh
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.book, size: 40, color: Colors.grey);
                            },
                          ),
                        ),
                      ),
                      title: Text(
                        book.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(book.author),
                      onTap: () {
                        // TODO: Điều hướng đến màn hình Player
                        // Ví dụ: GoRouter.of(context).push('/player/${book.id}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Bạn đã chọn: ${book.title}')),
                        );
                      },
                    ),
                  );
                },
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
            return const Center(child: Text('Chào mừng bạn đến với ứng dụng!'));
          },
        ),
      ),
    );
  }
}
