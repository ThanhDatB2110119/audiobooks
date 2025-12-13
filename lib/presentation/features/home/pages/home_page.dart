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
      create: (_) => GetIt.instance<HomeCubit>()..fetchData(),
      child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(
              150.0,
            ), // Tăng chiều cao AppBar
            child: AppBar(
              backgroundColor: Colors.white70, // Thêm màu nền xanh cho AppBar
              // Giữ nguyên AppBar của bạn, có thể đổi title cho phù hợp hơn
              title: GestureDetector(
                onTap: () {
                  // Điều hướng đến trang tìm kiếm
                  context.push('/home/search');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Tìm kiếm sách',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              // actions: const [
              //   SignOutButton(), // Giữ nguyên nút SignOut của bạn
              // ],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Thanh lọc thể loại ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Text(
                        'Thể loại',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),

                    // Widget Wrap sẽ tự động sắp xếp các widget con của nó theo hàng ngang,
                    // và sẽ "wrap" (xuống dòng) khi không còn đủ không gian.
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Builder(
                        builder: (context) {
                          // Lấy danh sách các chip từ state
                          final List<Widget> allChips = [
                            _buildChip(
                              context,
                              state,
                              label: 'Tất cả',
                              categoryId: null,
                            ),
                            ...state.categories.map(
                              (category) => _buildChip(
                                context,
                                state,
                                label: category.name,
                                categoryId: category.id,
                              ),
                            ),
                          ];

                          // Logic để chia các chip thành 3 hàng
                          const int numberOfRows = 3;
                          List<List<Widget>> columns = List.generate(
                            (allChips.length / numberOfRows).ceil(),
                            (_) => [],
                          );
                          for (int i = 0; i < allChips.length; i++) {
                            columns[i % columns.length].add(
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 6.0,
                                ), // Khoảng cách giữa các chip trong 1 cột
                                child: allChips[i],
                              ),
                            );
                          }

                          // Hiển thị các cột chip
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: columns.map((chipColumn) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  right: 6.0,
                                ), // Khoảng cách giữa các cột
                                child: IntrinsicWidth(
                                  // Làm cho chiều rộng của cột bằng với chip dài nhất
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .stretch, // Các chip trong cột sẽ dài bằng nhau
                                    children: chipColumn,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 24),

                    // --- Danh sách sách ---
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
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
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
                          context.read<HomeCubit>().fetchData();
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

  /// Hàm helper để tạo một ChoiceChip đã được tùy chỉnh
  Widget _buildChip(
    BuildContext context,
    HomeLoaded state, {
    required String label,
    required String? categoryId,
  }) {
    final isSelected = state.selectedCategoryId == categoryId;

    // Sử dụng InkWell để có hiệu ứng gợn sóng khi nhấn
    return InkWell(
      // Bọc trong BorderRadius để hiệu ứng gợn sóng cũng được bo tròn
      borderRadius: BorderRadius.circular(20.0),
      onTap: () {
        // Chỉ kích hoạt hành động nếu chip chưa được chọn
        if (!isSelected) {
          context.read<HomeCubit>().filterByCategory(categoryId);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ), // Thêm hiệu ứng chuyển màu mượt mà
        // --- Widget Container để vẽ giao diện cho Chip ---
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[700],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Center(
          // Căn giữa Text bên trong
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center, // Căn giữa cho text nhiều dòng
            maxLines: 1, // Đảm bảo text không xuống dòng
            overflow: TextOverflow.ellipsis, // Thêm ... nếu text quá dài
          ),
        ),
      ),
    );
  }
}
