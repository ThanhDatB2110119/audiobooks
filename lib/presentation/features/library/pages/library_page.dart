import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with SingleTickerProviderStateMixin {
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
        // Đặt TabBar vào `bottom` của AppBar để có hiệu ứng đẹp mắt
        bottom: TabBar(
          controller: _tabController,
          // Sử dụng các thuộc tính của theme để đồng bộ với ứng dụng
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(
              icon: Icon(Icons.bookmark_added),
              text: 'Sách đã lưu',
            ),
            Tab(
              icon: Icon(Icons.mic_external_on),
              text: 'Sách của tôi',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Nội dung cho Tab "Sách đã lưu"
          SavedBooksTabView(),
          
          // Nội dung cho Tab "Sách của tôi"
          // Đây là nơi bạn sẽ tích hợp Bloc để hiển thị danh sách
          MyBooksTabView(),
        ],
      ),
    );
  }
}

// ====================================================================
// Widget riêng cho nội dung Tab "Sách đã lưu"
// ====================================================================
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
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: Colors.grey[400],
            ),
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

// ====================================================================
// Widget riêng cho nội dung Tab "Sách của tôi"
// ====================================================================
class MyBooksTabView extends StatelessWidget {
  const MyBooksTabView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Bọc widget này trong BlocProvider<LibraryCubit>
    // và dùng BlocBuilder để hiển thị các trạng thái (Loading, Loaded, Error)
    
    // Giao diện tạm thời khi chưa có dữ liệu
    // Bạn sẽ thay thế Center này bằng BlocBuilder
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 80,
              color: Colors.grey[400],
            ),
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
    
    // VÍ DỤ: Cấu trúc khi bạn tích hợp Bloc
    /*
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        if (state is LibraryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is LibraryLoaded) {
          if (state.documents.isEmpty) {
            // Hiển thị giao diện "Chưa có sách" ở trên
            return ...
          }
          // Dùng RefreshIndicator và ListView.builder để hiển thị danh sách
          return RefreshIndicator(
            onRefresh: () async {
              context.read<LibraryCubit>().fetchUserDocuments();
            },
            child: ListView.builder(
              itemCount: state.documents.length,
              itemBuilder: (context, index) {
                final doc = state.documents[index];
                // XÂY DỰNG WIDGET CHO TỪNG ITEM Ở ĐÂY
                return ListTile(
                  title: Text(doc.title),
                  subtitle: Text('Tạo lúc: ${doc.createdAt}'),
                  trailing: Chip(label: Text(doc.status.toString())),
                );
              },
            ),
          );
        }
        if (state is LibraryError) {
          return Center(child: Text('Lỗi: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
    */
  }
}