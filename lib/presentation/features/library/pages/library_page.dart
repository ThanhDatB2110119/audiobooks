// presentation/features/library/pages/library_page.dart

import 'dart:async';

import 'package:audiobooks/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:audiobooks/presentation/features/library/cubit/library_state.dart';
import 'package:audiobooks/presentation/features/library/widgets/my_books_tab_view.dart';
import 'package:audiobooks/presentation/features/library/widgets/saved_books_tab_view.dart';
import 'package:audiobooks/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
// ======================= THÊM CÁC IMPORT CẦN THIẾT =======================
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:audiobooks/presentation/features/library/cubit/library_cubit.dart';
// ========================================================================

class LibraryPageContainer extends StatelessWidget {
  const LibraryPageContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.instance<LibraryCubit>()..fetchAllLibraryContent(),
      child: const LibraryPage(), // Hiển thị UI chính ở đây
    );
  }
}
// ====================================================================================

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
    // ======================= THAY ĐỔI 2: UI GIỜ NẰM BÊN DƯỚI BLOCPROVIDER =======================
    // Cấu trúc UI giữ nguyên, nhưng bây giờ nó là con của LibraryPageContainer
    // nên mọi widget bên trong đều có thể truy cập LibraryCubit.
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          // preferredSize: const Size.fromHeight(150.0),
          preferredSize: const Size.fromHeight(180.0),
          child: AppBar(
            titleSpacing: 0,
            title: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) =>
                  const CustomAppBar(title: 'Thư viện của bạn'),
            ),
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
        ),
        // ======================= THAY ĐỔI 3: BLOCLISTENER BAO BỌC TABBARVIEW =======================
        // Đặt BlocListener ở đây để lắng nghe state và hiển thị SnackBar.
        body: BlocListener<LibraryCubit, LibraryState>(
          listener: (context, state) {
            if (state is LibraryActionSuccess) {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();

              // Tạo một SnackBar
              final snackBar = SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                // KHÔNG dùng duration ở đây
                action: state.undoAction != null
                    ? SnackBarAction(
                        label: 'Hoàn tác',
                        textColor: Colors.white,
                        onPressed: () {
                          // Khi nhấn hoàn tác, hãy ẩn snackbar ngay
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          state.undoAction!();
                        },
                      )
                    : null,
              );

              // Hiển thị SnackBar và lấy về controller của nó
              final controller = ScaffoldMessenger.of(
                context,
              ).showSnackBar(snackBar);

              // Tạo một Timer để tự động ẩn SnackBar sau 4 giây
              Timer(const Duration(seconds: 4), () {
                // Dùng controller để ẩn chính xác SnackBar này
                controller.close();
              });
            } else if (state is LibraryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: TabBarView(
            controller: _tabController,
            // physics: const NeverScrollableScrollPhysics(),
            children: const [
              // Cả hai widget này giờ đều nằm dưới BlocProvider và có thể truy cập Cubit.
              SavedBooksTabView(),
              MyBooksTabView(),
            ],
          ),
        ),
      ),
    );
    // ==============================================================================================
  }
}


// class SavedBooksTabView extends StatelessWidget {
//   const SavedBooksTabView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Sử dụng BlocBuilder để lắng nghe state từ LibraryCubit.
//     // Lưu ý: LibraryCubit đã được cung cấp bởi _MyBooksTabContainer ở cấp cao hơn,
//     // nên cả hai tab đều có thể truy cập vào cùng một instance Cubit.
//     return BlocBuilder<LibraryCubit, LibraryState>(
//       builder: (context, state) {
//         // ---- Hiển thị loading indicator cho các trạng thái ban đầu ----
//         if (state is LibraryLoading || state is LibraryInitial) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // ---- Xử lý trạng thái tải thành công ----
//         if (state is LibraryLoaded) {
//           // 1. Kiểm tra xem danh sách sách đã lưu có rỗng không
//           if (state.savedBooks.isEmpty) {
//             // Nếu rỗng, hiển thị giao diện "Chưa có sách"
//             return const _EmptySavedBooksView();
//           }

//           // 2. Nếu có dữ liệu, hiển thị danh sách
//           return RefreshIndicator(
//             onRefresh: () async {
//               // Khi người dùng kéo để làm mới, gọi lại hàm fetch tổng
//               await context.read<LibraryCubit>().fetchAllLibraryContent();
//             },
//             child: ListView.builder(
//               padding: const EdgeInsets.all(8.0),
//               itemCount: state.savedBooks.length,
//               itemBuilder: (context, index) {
//                 final book = state.savedBooks[index];
//                 // Sử dụng một widget item được thiết kế riêng
//                 return _SavedBookListItem(
//                   book: book,
//                   allSavedBooks: state.savedBooks,
//                   currentIndex: index,
//                 );
//               },
//             ),
//           );
//         }
        
//         // ---- Xử lý các trạng thái lỗi hoặc không xác định ----
//         // Thường thì lỗi sẽ được xử lý bởi BlocListener ở cấp cao hơn,
//         // nhưng chúng ta có thể thêm một fallback ở đây.
//         return const Center(child: Text('Đã có lỗi xảy ra.'));
//       },
//     );
//   }
// }

// // ======================= THAY ĐỔI: CẬP NHẬT TOÀN BỘ MyBooksTabView =======================
// class MyBooksTabView extends StatelessWidget {
//   const MyBooksTabView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Sử dụng BlocBuilder để lắng nghe state từ LibraryCubit và rebuild UI
//     return BlocBuilder<LibraryCubit, LibraryState>(
//       builder: (context, state) {
//         // ---- Trạng thái đang tải ----
//         if (state is LibraryLoading || state is LibraryInitial) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // ---- Trạng thái có lỗi ----
//         if (state is LibraryError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('Lỗi: ${state.message}'),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () =>
//                       context.read<LibraryCubit>().fetchAllLibraryContent(),
//                   child: const Text('Thử lại'),
//                 ),
//               ],
//             ),
//           );
//         }

//         // ---- Trạng thái tải thành công ----
//         if (state is LibraryLoaded) {
//           // Trường hợp không có tài liệu nào
//           if (state.myDocuments.isEmpty) {
//             return const _EmptyMyBooksView();
//           }

//           // Hiển thị danh sách tài liệu
//           return RefreshIndicator(
//             onRefresh: () async {
//               // Khi người dùng kéo để làm mới, gọi lại hàm fetch
//               await context.read<LibraryCubit>().fetchAllLibraryContent();
//             },
//             child: ListView.builder(
//               itemCount: state.myDocuments.length,
//               itemBuilder: (context, index) {
//                 final doc = state.myDocuments[index];
//                 return _MyBookListItem(
//                   document: doc,
//                   allDocuments: state.myDocuments,
//                   currentIndex: index,
//                 );
//               },
//             ),
//           );
//         }

//         // Trạng thái mặc định (hiếm khi xảy ra)
//         return const SizedBox.shrink();
//       },
//     );
//   }
// }
// // =======================================================================================

// // Widget hiển thị khi danh sách "Sách của tôi" rỗng
// class _EmptyMyBooksView extends StatelessWidget {
//   const _EmptyMyBooksView();

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.cloud_off, size: 80, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             const Text(
//               'Bạn chưa tạo sách nói nào',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Hãy qua tab "Tạo" để bắt đầu chuyển đổi văn bản của bạn thành sách nói.',
//               style: TextStyle(color: Colors.grey[600]),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Widget hiển thị cho từng item trong danh sách "Sách của tôi"
// class _MyBookListItem extends StatelessWidget {
//   final PersonalDocumentEntity document;
//   final List<PersonalDocumentEntity> allDocuments;
//   final int currentIndex;
//   const _MyBookListItem({
//     required this.document,
//     required this.allDocuments,
//     required this.currentIndex,
//   });

//   // Helper để lấy màu và icon cho từng status
//   (Color, IconData) _getStatusAppearance(ProcessingStatus status) {
//     switch (status) {
//       case ProcessingStatus.pending:
//         return (Colors.orange, Icons.hourglass_top);
//       case ProcessingStatus.processing:
//         return (Colors.blue, Icons.sync);
//       case ProcessingStatus.completed:
//         return (Colors.green, Icons.check_circle);
//       case ProcessingStatus.error:
//         return (Colors.red, Icons.error);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final (statusColor, statusIcon) = _getStatusAppearance(document.status);
//     final isCompleted = document.status == ProcessingStatus.completed;

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
//       child: ListTile(
//         leading: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Nút xóa
//             IconButton(
//               icon: Icon(Icons.delete_outline, color: Colors.red[400]),
//               tooltip: 'Xóa sách này',
//               onPressed: () async {
//                 // Hiển thị dialog xác nhận
//                 final confirm = await showDialog<bool>(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: const Text('Xác nhận xóa'),
//                     content: Text(
//                       'Bạn có chắc chắn muốn xóa "${document.title}" không? Hành động này không thể hoàn tác.',
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.of(context).pop(false),
//                         child: const Text('Hủy'),
//                       ),
//                       TextButton(
//                         onPressed: () => Navigator.of(context).pop(true),
//                         child: const Text(
//                           'Xóa',
//                           style: TextStyle(color: Colors.red),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );

//                 // Nếu người dùng xác nhận, gọi cubit để xóa
//                 if (confirm == true) {
//                   context.read<LibraryCubit>().deleteDocument(document);
//                 }
//               },
//             ),
//             // Icon cũ
//             Icon(
//               Icons.history_edu,
//               size: 30,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//           ],
//         ),
//         title: Text(
//           document.title,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           'Tạo lúc: ${DateFormat('dd/MM/yyyy, HH:mm').format(document.createdAt)}',
//         ),
//         trailing: Chip(
//           avatar: Icon(statusIcon, color: Colors.white, size: 16),
//           label: Text(
//             document.status.name.toUpperCase(),
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 10,
//             ),
//           ),
//           backgroundColor: statusColor,
//           padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
//         ),
//         onTap: isCompleted
//             ? () {
//                 // 1. Chuyển đổi toàn bộ danh sách PersonalDocumentEntity sang BookEntity
//                 final bookEntities = allDocuments
//                     .map((doc) => doc.toBookEntity())
//                     .toList();

//                 // 2. Điều hướng đến PlayerPage, truyền vào danh sách đã chuyển đổi và index hiện tại
//                 context.push(
//                   '/player',
//                   extra: {'books': bookEntities, 'index': currentIndex},
//                 );
//                 // TODO: Điều hướng đến PlayerPage khi sách đã hoàn thành
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Sẽ phát sách: ${document.title}')),
//                 );
//               }
//             : null, // Vô hiệu hóa onTap nếu chưa hoàn thành
//       ),
//     );
//   }
// }

// // Widget hiển thị khi danh sách "Sách đã lưu" rỗng
// class _EmptySavedBooksView extends StatelessWidget {
//   const _EmptySavedBooksView();

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.bookmark_border, size: 80, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             const Text(
//               'Chưa có sách nào được lưu',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Những cuốn sách bạn thêm từ Trang chủ sẽ xuất hiện ở đây.',
//               style: TextStyle(color: Colors.grey[600]),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Widget hiển thị cho từng item trong danh sách "Sách đã lưu"
// class _SavedBookListItem extends StatelessWidget {
//   final BookEntity book;
//   final List<BookEntity> allSavedBooks;
//   final int currentIndex;

//   const _SavedBookListItem({
//     required this.book,
//     required this.allSavedBooks,
//     required this.currentIndex,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//         leading: ClipRRect(
//           borderRadius: BorderRadius.circular(4.0),
//           child: Image.network(
//             book.coverImageUrl,
//             width: 50,
//             height: 80,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return const Icon(Icons.book, size: 40);
//             },
//           ),
//         ),
//         title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis,),
//         subtitle: Text(book.author),
//         onTap: () {
//           // Điều hướng đến PlayerPage, truyền vào danh sách sách đã lưu
//           context.push(
//             '/player',
//             extra: {
//               'books': allSavedBooks,
//               'index': currentIndex,
//             },
//           );
//         },
//       ),
//     );
//   }
// }
