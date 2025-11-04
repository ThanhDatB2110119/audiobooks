import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

/// Hiển thị một dialog custom với trường nhập liệu văn bản dài.
///
/// [context] là BuildContext của màn hình gọi nó.
/// [title] là tiêu đề của dialog.
/// [initialText] là văn bản ban đầu (nếu có) để điền vào trường nhập liệu.
/// [onConfirm] là một callback function sẽ được gọi với văn bản đã nhập khi người dùng nhấn nút xác nhận.
/// [confirmButtonText] là văn bản cho nút xác nhận.
/// [cancelButtonText] là văn bản cho nút hủy.
Future<void> showTextInputDialog({
  required BuildContext context,
  required String title,
  String? initialText,
  required Function(String text) onConfirm,
  String confirmButtonText = 'Xác nhận',
  String cancelButtonText = 'Hủy',
}) async {
  // Key để truy cập vào State của Widget con, từ đó lấy được controller và form key
  final GlobalKey<_TextInputDialogBodyState> dialogBodyKey =
      GlobalKey<_TextInputDialogBodyState>();

  return AwesomeDialog(
    context: context,
    dialogType: DialogType.noHeader,
    animType: AnimType.bottomSlide,
    title: title,
    // Body giờ đây là một StatefulWidget để quản lý vòng đời của chính nó
    body: _TextInputDialogBody(
      key: dialogBodyKey, // <-- Gán key
      initialText: initialText,
    ),
    btnOkText: confirmButtonText,
    btnCancelText: cancelButtonText,
    btnCancelOnPress: () {},
    btnOkOnPress: () {
      // Dùng key để truy cập vào State và gọi hàm validate
      final state = dialogBodyKey.currentState;
      if (state != null && state.validate()) {
        // Lấy text từ controller thông qua state và gọi callback
        onConfirm(state.textController.text);
      }
    },
    // Không cần onDismissCallback nữa vì StatefulWidget sẽ tự động dispose controller
  ).show();
}

// =======================================================================
// TẠO MỘT STATEFULWIDGET RIÊNG ĐỂ QUẢN LÝ CONTROLLER VÀ FORM
// =======================================================================
class _TextInputDialogBody extends StatefulWidget {
  final String? initialText;

  const _TextInputDialogBody({super.key, this.initialText});

  @override
  State<_TextInputDialogBody> createState() => _TextInputDialogBodyState();
}

class _TextInputDialogBodyState extends State<_TextInputDialogBody> {
  // Controller và Form Key giờ được quản lý bên trong State
  late final TextEditingController textController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller ở initState
    textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    // Hủy controller ở dispose. Flutter sẽ gọi hàm này vào đúng thời điểm
    // khi widget bị gỡ khỏi cây, đảm bảo không có lỗi xảy ra.
    textController.dispose();
    super.dispose();
  }

  // Một phương thức để widget bên ngoài có thể gọi validate
  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: TextFormField(
          controller: textController,
          maxLines: 5,
          minLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập nội dung của bạn tại đây...',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng không để trống trường này';
            }
            return null;
          },
        ),
      ),
    );
  }
}
