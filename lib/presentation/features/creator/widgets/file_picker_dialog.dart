import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// Hàm này sẽ hiển thị dialog và trả về một đối tượng [File] nếu người dùng xác nhận,
/// hoặc [null] nếu họ hủy.
Future<File?> showUploadFileDialog(BuildContext context) async {
  return showDialog<File?>(
    context: context,
    barrierDismissible: false, // Người dùng phải nhấn nút để đóng
    builder: (BuildContext dialogContext) {
      // Chúng ta dùng StatefulWidget ở đây để dialog có thể tự quản lý state
      // (cụ thể là file đã được chọn) mà không cần đến Cubit.
      return const _FilePickerDialogContent();
    },
  );
}

class _FilePickerDialogContent extends StatefulWidget {
  const _FilePickerDialogContent();

  @override
  State<_FilePickerDialogContent> createState() =>
      _FilePickerDialogContentState();
}

class _FilePickerDialogContentState extends State<_FilePickerDialogContent> {
  File? _selectedFile;

  // Hàm để mở trình chọn file của hệ thống
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        // Giới hạn các loại file người dùng có thể chọn
        allowedExtensions: ['pdf', 'txt', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        // Cập nhật state để hiển thị tên file đã chọn trên UI
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      } else {
        // Người dùng đã hủy việc chọn file
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi chọn file: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo sách nói từ tài liệu'),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Giúp dialog có kích thước vừa đủ
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nút để chọn file
          OutlinedButton.icon(
            icon: const Icon(Icons.attach_file),
            label: const Text('Chọn file từ thiết bị'),
            onPressed: _pickFile,
          ),
          const SizedBox(height: 16),
          // Hiển thị tên file đã được chọn
          if (_selectedFile != null)
            Text(
              'Đã chọn: ${_selectedFile!.path.split('/').last}', // Chỉ lấy tên file
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            const Text('Chưa có file nào được chọn.'),
        ],
      ),
      actions: <Widget>[
        // Nút Hủy
        TextButton(
          child: const Text('Hủy'),
          onPressed: () {
            // Đóng dialog và trả về null
            Navigator.of(context).pop(null);
          },
        ),
        // Nút Xác nhận
        ElevatedButton(
          // Nút sẽ bị vô hiệu hóa nếu chưa có file nào được chọn
          onPressed: _selectedFile == null
              ? null
              : () {
                  // Đóng dialog và trả về file đã chọn
                  Navigator.of(context).pop(_selectedFile);
                },
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}
