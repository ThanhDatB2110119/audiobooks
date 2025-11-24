import 'dart:io';

import 'package:audiobooks/presentation/features/creator/cubit/creator_cubit.dart';
import 'package:audiobooks/presentation/features/creator/widgets/file_picker_dialog.dart';
import 'package:audiobooks/presentation/features/creator/widgets/text_input_dialog.dart';
import 'package:audiobooks/presentation/features/creator/widgets/url_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CreatorPage extends StatelessWidget {
  const CreatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold là cấu trúc cơ bản cho một màn hình trong Material Design.
    return SafeArea(
      child: Scaffold(
        // AppBar ở trên cùng của màn hình.
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150.0), // Tăng chiều cao AppBar
          child: AppBar(
            backgroundColor: Colors.blue, // Thêm màu nền xanh cho AppBar
            // Giữ nguyên AppBar của bạn, có thể đổi title cho phù hợp hơn
            title: const Text('Tạo sách nói cá nhân'),
          ),
        ),
        // Body là phần nội dung chính của màn hình.
        body: Center(
          // Center dùng để căn giữa nội dung con của nó.
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // Căn giữa các widget con theo chiều dọc.
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
                                SnackBar(content: Text('Đang xử lý URL: $url')),
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
                            style: TextStyle(fontSize: 14, color: Colors.black),
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
                            style: TextStyle(fontSize: 14, color: Colors.black),
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
                                context.read<CreatorCubit>().createFromText(
                                  submittedText,
                                );
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
                            style: TextStyle(fontSize: 14, color: Colors.black),
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
                            style: TextStyle(fontSize: 14, color: Colors.black),
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
      ),
    );
  }
}
