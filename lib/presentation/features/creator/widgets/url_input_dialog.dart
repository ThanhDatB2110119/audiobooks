import 'package:flutter/material.dart';

/// Hiển thị một dialog có trường nhập liệu.
///
/// Trả về một `Future<String?>`.
/// - Nếu người dùng nhấn nút xác nhận, Future sẽ hoàn thành với giá trị text đã nhập.
/// - Nếu người dùng nhấn nút hủy hoặc đóng dialog, Future sẽ hoàn thành với giá trị `null`.
///
/// [context]: BuildContext của widget gọi dialog.
/// [title]: Tiêu đề của dialog.
/// [hintText]: Gợi ý cho trường nhập liệu.
/// [confirmButtonText]: Văn bản cho nút xác nhận (mặc định là 'Xác nhận').
/// [cancelButtonText]: Văn bản cho nút hủy (mặc định là 'Hủy').
/// [initialValue]: Giá trị ban đầu cho trường nhập liệu.
Future<String?> showInputDialog({
  required BuildContext context,
  required String title,
  String? hintText,
  String confirmButtonText = 'Xác nhận',
  String cancelButtonText = 'Hủy',
  String initialValue = '',
}) {
  return showDialog<String?>(
    context: context,
    // Ngăn người dùng đóng dialog bằng cách nhấn ra ngoài
    barrierDismissible: false, 
    builder: (BuildContext context) {
      // Sử dụng một StatefulWidget riêng để quản lý TextEditingController
      return _InputDialogContent(
        title: title,
        hintText: hintText,
        confirmButtonText: confirmButtonText,
        cancelButtonText: cancelButtonText,
        initialValue: initialValue,
      );
    },
  );
}

// Widget nội bộ để quản lý state (TextEditingController)
class _InputDialogContent extends StatefulWidget {
  final String title;
  final String? hintText;
  final String confirmButtonText;
  final String cancelButtonText;
  final String initialValue;

  const _InputDialogContent({
    required this.title,
    this.hintText,
    required this.confirmButtonText,
    required this.cancelButtonText,
    required this.initialValue,
  });

  @override
  State<_InputDialogContent> createState() => _InputDialogContentState();
}

class _InputDialogContentState extends State<_InputDialogContent> {
  // Controller để lấy và quản lý text từ TextField
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    // Rất quan trọng: Phải dispose controller để tránh rò rỉ bộ nhớ!
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _textController,
        decoration: InputDecoration(hintText: widget.hintText),
        autofocus: true, // Tự động focus vào trường nhập liệu khi dialog mở ra
      ),
      actions: <Widget>[
        // Nút Hủy
        TextButton(
          child: Text(widget.cancelButtonText),
          onPressed: () {
            // Đóng dialog và trả về null
            Navigator.of(context).pop(null);
          },
        ),
        // Nút Xác nhận
        ElevatedButton(
          child: Text(widget.confirmButtonText),
          onPressed: () {
            // Đóng dialog và trả về giá trị của text controller
            Navigator.of(context).pop(_textController.text);
          },
        ),
      ],
    );
  }
}