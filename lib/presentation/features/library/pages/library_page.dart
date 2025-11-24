// presentation/features/library/pages/library_page.dart

import 'package:audiobooks/presentation/features/library/cubit/library_state.dart';
import 'package:flutter/material.dart';
// ======================= THÊM CÁC IMPORT CẦN THIẾT =======================
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:audiobooks/domain/entities/personal_document_entity.dart';
import 'package:audiobooks/presentation/features/library/cubit/library_cubit.dart';
import 'package:intl/intl.dart'; // Package để format ngày tháng
// ========================================================================

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện của bạn'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(icon: Icon(Icons.bookmark_added), text: 'Sách đã lưu'),
            Tab(icon: Icon(Icons.mic_external_on), text: 'Sách của tôi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SavedBooksTabView(),
          // ======================= THAY ĐỔI: WRAP MyBooksTabView TRONG BLOCPROVIDER =======================
          // Cung cấp LibraryCubit cho tab "Sách của tôi".
          // Cubit sẽ được tạo và gọi fetchUserDocuments() ngay khi người dùng chuyển đến tab này.
          _MyBooksTabContainer(),
          // ==============================================================================================
        ],
      ),
    );
  }
}

// Widget container để cung cấp Bloc, giúp tách biệt logic
class _MyBooksTabContainer extends StatelessWidget {
  const _MyBooksTabContainer();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<LibraryCubit>()..fetchUserDocuments(),
      child: const MyBooksTabView(),
    );
  }
}

class SavedBooksTabView extends StatelessWidget {
  const SavedBooksTabView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Tích hợp Bloc để lấy danh sách sách đã lưu từ user_library

    // Giao diện tạm thời khi chưa có dữ liệu
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

// ======================= THAY ĐỔI: CẬP NHẬT TOÀN BỘ MyBooksTabView =======================
class MyBooksTabView extends StatelessWidget {
  const MyBooksTabView({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng BlocBuilder để lắng nghe state từ LibraryCubit và rebuild UI
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        // ---- Trạng thái đang tải ----
        if (state is LibraryLoading || state is LibraryInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        // ---- Trạng thái có lỗi ----
        if (state is LibraryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lỗi: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<LibraryCubit>().fetchUserDocuments(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        // ---- Trạng thái tải thành công ----
        if (state is LibraryLoaded) {
          // Trường hợp không có tài liệu nào
          if (state.myDocuments.isEmpty) {
            return const _EmptyMyBooksView();
          }

          // Hiển thị danh sách tài liệu
          return RefreshIndicator(
            onRefresh: () async {
              // Khi người dùng kéo để làm mới, gọi lại hàm fetch
              await context.read<LibraryCubit>().fetchUserDocuments();
            },
            child: ListView.builder(
              itemCount: state.myDocuments.length,
              itemBuilder: (context, index) {
                final doc = state.myDocuments[index];
                return _MyBookListItem(document: doc);
              },
            ),
          );
        }

        // Trạng thái mặc định (hiếm khi xảy ra)
        return const SizedBox.shrink();
      },
    );
  }
}
// =======================================================================================

// Widget hiển thị khi danh sách "Sách của tôi" rỗng
class _EmptyMyBooksView extends StatelessWidget {
  const _EmptyMyBooksView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Bạn chưa tạo sách nói nào',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy qua tab "Tạo" để bắt đầu chuyển đổi văn bản của bạn thành sách nói.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget hiển thị cho từng item trong danh sách "Sách của tôi"
class _MyBookListItem extends StatelessWidget {
  final PersonalDocumentEntity document;

  const _MyBookListItem({required this.document});

  // Helper để lấy màu và icon cho từng status
  (Color, IconData) _getStatusAppearance(ProcessingStatus status) {
    switch (status) {
      case ProcessingStatus.pending:
        return (Colors.orange, Icons.hourglass_top);
      case ProcessingStatus.processing:
        return (Colors.blue, Icons.sync);
      case ProcessingStatus.completed:
        return (Colors.green, Icons.check_circle);
      case ProcessingStatus.error:
        return (Colors.red, Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusIcon) = _getStatusAppearance(document.status);
    final isCompleted = document.status == ProcessingStatus.completed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: ListTile(
        leading: Icon(
          Icons.history_edu,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          document.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Tạo lúc: ${DateFormat('dd/MM/yyyy, HH:mm').format(document.createdAt)}',
        ),
        trailing: Chip(
          avatar: Icon(statusIcon, color: Colors.white, size: 16),
          label: Text(
            document.status.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          backgroundColor: statusColor,
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        ),
        onTap: isCompleted
            ? () {
                // TODO: Điều hướng đến PlayerPage khi sách đã hoàn thành
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sẽ phát sách: ${document.title}')),
                );
              }
            : null, // Vô hiệu hóa onTap nếu chưa hoàn thành
      ),
    );
  }
}
