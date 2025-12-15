import 'package:audiobooks/presentation/features/library/utils/mapper.dart';
import 'package:audiobooks/presentation/features/player/cubit/player_cubit.dart';
import 'package:flutter/material.dart';
// ======================= THÊM CÁC IMPORT CẦN THIẾT =======================
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audiobooks/domain/entities/personal_document_entity.dart';
import 'package:intl/intl.dart';

class MyBookListItem extends StatelessWidget {
  final PersonalDocumentEntity document;
  final List<PersonalDocumentEntity> allDocuments;
  final int currentIndex;
  final Function(PersonalDocumentEntity) onDelete;
  const MyBookListItem({
    super.key,
    required this.document,
    required this.allDocuments,
    required this.currentIndex,
    required this.onDelete,
  });

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
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nút xóa
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              tooltip: 'Xóa sách này',
              onPressed: () async {
                // Hiển thị dialog xác nhận
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xác nhận xóa'),
                    content: Text(
                      'Bạn có chắc chắn muốn xóa "${document.title}" không? Hành động này không thể hoàn tác.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'Xóa',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                // Nếu người dùng xác nhận, gọi cubit để xóa
                if (confirm == true) {
                  // ======================= THAY ĐỔI TẠI ĐÂY =======================
                  // Gọi callback function đã được truyền vào
                  onDelete(document);
                  // ===============================================================
                }
              },
            ),
            // Icon cũ
            Icon(
              Icons.history_edu,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
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
                // 1. Chuyển đổi toàn bộ danh sách PersonalDocumentEntity sang BookEntity
                //    Logic này vẫn cần thiết để tạo playlist cho PlayerCubit.
                final bookEntities = allDocuments
                    .map((doc) => doc.toBookEntity())
                    .toList();

                // 2. Ra lệnh cho PlayerCubit singleton bắt đầu phát playlist này
                context.read<PlayerCubit>().startNewPlaylist(
                  bookEntities,
                  currentIndex,
                );

                // 3. (Tùy chọn) Hiển thị SnackBar xác nhận
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bắt đầu phát sách của bạn...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            : null, // Vô hiệu hóa onTap nếu chưa hoàn thành
      ),
    );
  }
}
