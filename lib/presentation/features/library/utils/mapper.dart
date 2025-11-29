import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/domain/entities/personal_document_entity.dart';

extension PersonalDocumentMapper on PersonalDocumentEntity {
  /// Chuyển đổi một PersonalDocumentEntity thành một BookEntity.
  BookEntity toBookEntity() {
    return BookEntity(
      id: int.tryParse(id) ?? 0,
      title: title,
      // Personal document không có tác giả, ta dùng một placeholder
      author: 'Tài liệu cá nhân',
      // Dùng description từ AI nếu có
      description: (this as dynamic).description ?? 'Không có mô tả.',
      // Personal document không có ảnh bìa, dùng một placeholder.
      // Chúng ta sẽ xử lý placeholder này trong PlayerPage để hiển thị icon.
      coverImageUrl:
          'assets/images/sachNoiCaNhan.png', // Hoặc một URL không tồn tại
      // Các trường này không áp dụng cho personal document
      categoryId: 0,
      categoryName: 'Cá nhân',
      // Đây là trường quan trọng nhất
      audioUrl: generatedAudioUrl ?? '',
    );
  }
}
