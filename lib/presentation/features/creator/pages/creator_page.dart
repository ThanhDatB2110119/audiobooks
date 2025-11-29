// presentation/features/creator/pages/creator_page.dart

import 'package:audiobooks/presentation/features/creator/cubit/creator_cubit.dart';
import 'package:audiobooks/presentation/features/creator/cubit/creator_state.dart';
import 'package:audiobooks/presentation/features/creator/widgets/file_picker_dialog.dart';
import 'package:audiobooks/presentation/features/creator/widgets/text_input_dialog.dart';
import 'package:audiobooks/presentation/features/creator/widgets/url_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
//test
class CreatorPage extends StatelessWidget {
  const CreatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<CreatorCubit>(),
      child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(150.0),
            child: AppBar(
              backgroundColor: Colors.blue,
              title: const Text('Tạo sách nói cá nhân'),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 190,
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
                                // Nút Nhập link
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showInputDialog(
                                      context: builderContext,
                                      title: 'Nhập link tài liệu',
                                      hintText: 'Nhập URL tại đây',
                                      confirmButtonText: 'Xác nhận',
                                      cancelButtonText: 'Hủy',
                                      initialValue: '',
                                    );
                                  },
                                  icon: const FaIcon(
                                    FontAwesomeIcons.link,
                                    color: Colors.black,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.9,
                                    ),
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
                                // Nút Chọn file
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showUploadFileDialog(builderContext).then((
                                      selectedFile,
                                    ) {
                                      if (selectedFile != null) {}
                                    });
                                  },
                                  icon: const FaIcon(
                                    FontAwesomeIcons.folderOpen,
                                    color: Colors.black,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.9,
                                    ),
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
                                    backgroundColor: Colors.white.withOpacity(
                                      0.9,
                                    ),
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
                                // Nút Khung 4
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const FaIcon(
                                    FontAwesomeIcons.textSlash,
                                    color: Colors.black,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.9,
                                    ),
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
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
