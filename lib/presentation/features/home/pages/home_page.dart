import 'dart:io';

import 'package:audiobooks/presentation/features/auth/widgets/sign_out_button.dart';
import 'package:audiobooks/presentation/features/home/cubit/home_cubit.dart';
import 'package:audiobooks/presentation/features/home/cubit/home_state.dart';
import 'package:audiobooks/presentation/features/creator/widgets/text_input_dialog.dart';
import 'package:audiobooks/presentation/features/creator/widgets/url_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:audiobooks/presentation/features/creator/widgets/file_picker_dialog.dart';

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
                    // Container độc lập phía dưới AppBar - luôn hiển thị
                    Container(
                      height: 200,
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 1.8,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8.0),
                          shrinkWrap: true,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                print('Nhấn vào Khung 1');

                                final String? url = await showInputDialog(
                                  context: context,
                                  title: 'Nhập URL trang web',
                                  hintText: 'https://...',
                                );
                                if (url != null && url.isNotEmpty) {
                                  // Người dùng đã nhập và nhấn xác nhận
                                  // TODO: Gọi Cubit/Usecase để xử lý URL này
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Đang xử lý URL: $url'),
                                    ),
                                  );
                                } else {
                                  // Người dùng đã nhấn hủy hoặc không nhập gì
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã hủy thao tác'),
                                    ),
                                  );
                                }
                              },
                              icon: const FaIcon(
                                FontAwesomeIcons.link,
                                color: Colors.black,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.all(8.0),
                              ),
                              label: const Text(
                                'Nhập link',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            ElevatedButton.icon(
                              onPressed: () async {
                                print('Nhấn vào Khung 2');
                                // TODO: Thêm navigation đến page 2
                                // Gọi hàm để hiển thị dialog
                                final File? selectedFile =
                                    await showUploadFileDialog(context);

                                // Xử lý kết quả sau khi dialog đóng
                                if (selectedFile != null) {
                                  // Người dùng đã xác nhận và chọn một file
                                  // TODO: Gọi Cubit/Usecase để bắt đầu xử lý file này
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Đã chọn file: ${selectedFile.path.split('/').last}',
                                      ),
                                    ),
                                  );
                                } else {
                                  // Người dùng đã hủy
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Hành động đã được hủy'),
                                    ),
                                  );
                                }
                              },
                              icon: const FaIcon(
                                FontAwesomeIcons.folderOpen,
                                color: Colors.black,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.all(8.0),
                              ),
                              label: const Text(
                                'Chọn file',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            ElevatedButton.icon(
                              onPressed: () {
                                print('Nhấn vào Khung 3');
                                // TODO: Thêm navigation đến page 3

                                showTextInputDialog(
                                  context: context,
                                  title: 'Tạo sách nói từ văn bản',
                                  // Truyền vào hàm callback để xử lý text sau khi người dùng xác nhận
                                  onConfirm: (submittedText) {
                                    // Tại đây, bạn có thể gọi Cubit/Bloc để xử lý logic
                                    // Ví dụ: context.read<CreatorCubit>().createTextAudiobook(submittedText);

                                    print('Văn bản đã nhập: $submittedText');

                                    // Hiển thị một SnackBar để xác nhận
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Đã nhận văn bản!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                );
                              },

                              icon: const FaIcon(
                                FontAwesomeIcons.bookOpen,
                                color: Colors.black,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.all(8.0),
                              ),
                              label: const Text(
                                'Nhập văn bản',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                print('Nhấn vào Khung 4');
                                // TODO: Thêm navigation đến page 4
                              },
                              icon: const FaIcon(
                                FontAwesomeIcons.textSlash,
                                color: Colors.black,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.all(8.0),
                              ),
                              label: const Text(
                                'Khung 4',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                                      context.push('/home/details/${book.id.toString()}');
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
