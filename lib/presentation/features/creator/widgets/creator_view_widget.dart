import 'package:audiobooks/presentation/features/creator/widgets/image_source_selector_button.dart';
import 'package:audiobooks/presentation/features/library/widgets/my_book_list_item.dart';
import 'package:audiobooks/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:audiobooks/presentation/features/creator/cubit/creator_cubit.dart';
import 'package:audiobooks/presentation/features/creator/cubit/creator_state.dart';
import 'package:audiobooks/presentation/features/creator/widgets/file_picker_dialog.dart';
import 'package:audiobooks/presentation/features/creator/widgets/text_input_dialog.dart';
import 'package:audiobooks/presentation/features/creator/widgets/url_input_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CreatorView extends StatefulWidget {
  const CreatorView({super.key});

  @override
  State<CreatorView> createState() => CreatorViewState();
}

class CreatorViewState extends State<CreatorView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          // Đặt chiều cao mong muốn, ví dụ: 120
          preferredSize: const Size.fromHeight(170.0),
          child: AppBar(
            // Dùng FlexibleSpaceBar để nội dung có thể co giãn đẹp mắt
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 0, bottom: 0),
              title: const CustomAppBar(title: 'Tạo sách'),
              background: Container(
                alignment: Alignment.bottomCenter,
                // Dùng màu chủ đạo của theme
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  margin: const EdgeInsets.only(
                    bottom: 12.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  decoration: BoxDecoration(
                    // Màu nền xanh
                    color: const Color.fromARGB(
                      255,
                      251,
                      17,
                      0,
                    ), // Hoặc một màu xanh khác bạn thích
                    // Bo tròn các góc
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Sáng tạo những cuốn sách nói dành riêng cho bạn',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            // Đặt titleSpacing = 0 để FlexibleSpaceBar chiếm toàn bộ không gian
            titleSpacing: 0,
          ),
        ),

        body: Builder(
          builder: (builderContext) {
            // ======================= THAY ĐỔI LOGIC TRONG BLOCLISTENER =======================
            return BlocListener<CreatorCubit, CreatorState>(
              listener: (context, state) {
                // Sử dụng `WidgetsBinding.instance.addPostFrameCallback` để đảm bảo
                // các hành động chỉ được thực hiện SAU KHI frame hiện tại đã được build xong.
                // Điều này tránh được các lỗi liên quan đến Navigator.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // --- Xử lý trạng thái Loading ---
                  if (state is CreatorLoading) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => const PopScope(
                        canPop: false,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  // --- Xử lý trạng thái Success ---
                  else if (state is CreatorSuccess) {
                    // Kiểm tra xem có dialog nào đang mở không trước khi pop
                    if (Navigator.of(context, rootNavigator: true).canPop()) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  // --- Xử lý trạng thái Error ---
                  else if (state is CreatorError) {
                    if (Navigator.of(context, rootNavigator: true).canPop()) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: ${state.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              },
              child: Center(
                // ... Phần còn lại của UI giữ nguyên không thay đổi ...
                // child: Padding(
                // padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.all(5.0),
                      padding: const EdgeInsets.all(5.0),
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
                            // Nút Nhập link
                            ElevatedButton.icon(
                              onPressed: () async {
                                final creatorCubit = builderContext
                                    .read<CreatorCubit>();
                                final String? url = await showInputDialog(
                                  context: context,
                                  title: 'Nhập link tài liệu',
                                  hintText: 'Nhập URL tại đây',
                                  confirmButtonText: 'Xác nhận',
                                  cancelButtonText: 'Hủy',
                                  initialValue: '',
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vui lòng nhập URL';
                                    }
                                    // Kiểm tra xem có phải là một URL hợp lệ không
                                    if (!(Uri.tryParse(value)?.isAbsolute ??
                                        false)) {
                                      return 'URL không hợp lệ';
                                    }
                                    return null;
                                  },
                                );
                                if (!mounted) return;
                                if (url != null && url.isNotEmpty) {
                                  // Gọi Cubit để bắt đầu xử lý
                                  creatorCubit.createFromUrl(url);
                                }
                              },
                              icon: const FaIcon(
                                FontAwesomeIcons.link,
                                color: Colors.black,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                shadowColor: Colors.lightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
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
                            // Nút Chọn file
                            ElevatedButton.icon(
                              onPressed: () {
                                // Lấy instance của CreatorCubit từ context.
                                // Chúng ta lấy nó ra ngoài trước để không phải gọi lại trong .then()
                                final creatorCubit = builderContext
                                    .read<CreatorCubit>();

                                // Gọi dialog của bạn để hiển thị trình chọn file.
                                // Sử dụng .then() để xử lý kết quả trả về một cách bất đồng bộ.
                                final scaffoldMessenger = ScaffoldMessenger.of(
                                  context,
                                );
                                showUploadFileDialog(context).then((
                                  selectedFile,
                                ) {
                                  // Sau khi dialog đóng, callback này sẽ được thực thi.

                                  // Kiểm tra xem người dùng có thực sự chọn một file hay không.
                                  if (selectedFile != null) {
                                    // Nếu có, hãy gọi phương thức createFromFile trên Cubit
                                    // và truyền file đã chọn vào.
                                    creatorCubit.createFromFile(selectedFile);

                                    // Không cần hiển thị SnackBar ở đây nữa, vì BlocListener
                                    // sẽ tự động xử lý việc hiển thị phản hồi (Loading, Success, Error).
                                  } else {
                                    // Người dùng đã nhấn nút "Hủy" hoặc đóng dialog.
                                    // Hiển thị một SnackBar ngắn gọn để thông báo.
                                    if (!mounted) return;
                                    scaffoldMessenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Đã hủy thao tác chọn file.',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                });
                              },
                              icon: const FaIcon(
                                FontAwesomeIcons.folderOpen,
                                color: Colors.black,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.9,
                                ),
                                shadowColor: Colors.lightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
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
                            // Nút Nhập văn bản
                            ElevatedButton.icon(
                              onPressed: () {
                                showTextInputDialog(
                                  context: builderContext,
                                  title: 'Tạo sách nói từ văn bản',
                                  onConfirm: (submittedText) {
                                    builderContext
                                        .read<CreatorCubit>()
                                        .createFromText(submittedText);
                                  },
                                );
                              },
                              icon: const FaIcon(
                                FontAwesomeIcons.bookOpen,
                                color: Colors.black,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.9,
                                ),
                                shadowColor: Colors.lightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
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

                            // Nút chọn ảnh
                            const ImageSourceSelectorButton(),
                          ],
                        ),
                      ),
                    ),

                    const Divider(
                      thickness: 1,
                      color: Colors.lightBlue,
                      indent: 5,
                      endIndent: 5,
                    ),
                    const SizedBox(height: 4),
                    _buildMostRecentSection(),
                  ],
                ),
              ),

              // ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMostRecentSection() {
    return BlocBuilder<CreatorCubit, CreatorState>(
      // Chỉ build lại section này khi state là CreatorLoaded
      buildWhen: (previous, current) => current is CreatorLoaded,
      builder: (context, state) {
        if (state is CreatorLoaded && state.mostRecentDocument != null) {
          final doc = state.mostRecentDocument!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  // Màu nền xanh
                  color: Colors.blue, // Hoặc một màu xanh khác bạn thích
                  // Bo tròn các góc
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  textAlign: TextAlign.center,
                  ' Sách đã tạo gần đây',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Tái sử dụng widget _MyBookListItem từ LibraryPage
              // Điều này đảm bảo giao diện nhất quán
              MyBookListItem(
                document: doc,
                allDocuments: [doc], // Chỉ cần truyền chính nó
                currentIndex: 0,
                onDelete: (documentToDelete) {
                  // Vì widget này nằm trong Builder có context hợp lệ,
                  // chúng ta có thể gọi CreatorCubit một cách an toàn.
                  context.read<CreatorCubit>().deleteDocument(documentToDelete);
                },
              ),
            ],
          );
        }
        // Nếu không có sách nào hoặc state khác, không hiển thị gì
        return const SizedBox.shrink();
      },
    );
  }
}
