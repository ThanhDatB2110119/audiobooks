// presentation/features/search/pages/search_page.dart

import 'package:audiobooks/presentation/features/search/cubit/search_state.dart';
import 'package:audiobooks/presentation/features/search/cubit/search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

// Giữ nguyên StatefulWidget để quản lý TextEditingController
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  // Khai báo SearchCubit ở đây
  late final SearchCubit _searchCubit;

  @override
  void initState() {
    super.initState();
    // Khởi tạo Cubit
    _searchCubit = GetIt.instance<SearchCubit>();
    // Thêm listener để gọi search
    _controller.addListener(() {
      _searchCubit.search(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchCubit.close(); // Tự quản lý việc dispose Cubit
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cung cấp Cubit đã được khởi tạo bằng BlocProvider.value
    return BlocProvider.value(
      value: _searchCubit,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Tên sách, tác giả...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
              },
            ),
          ],
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            switch (state.status) {
              case SearchStatus.initial:
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nhập tên sách, tác giả để tìm kiếm'),
                    ],
                  ),
                );
              case SearchStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case SearchStatus.empty:
                return const Center(child: Text('Không tìm thấy kết quả nào.'));
              case SearchStatus.error:
                return Center(child: Text('Lỗi: ${state.errorMessage}'));
              case SearchStatus.loaded:
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: state.results.length,
                  itemBuilder: (context, index) {
                    final book = state.results[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 8.0,
                      ),
                      child: ListTile(
                        title: Text(book.title),
                        subtitle: Text(book.author),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.network(
                            book.coverImageUrl,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        onTap: () {
                          context.push(
                            '/home/details/${book.id}',
                            extra: {'books': state.results, 'index': index},
                          );
                        },
                      ),
                    );
                  },
                );
            }
          },
        ),
      ),
    );
  }
}
