// 
// Path: domain/repositories/personal_document_repository.dart

import 'dart:io'; // Cần thiết để làm việc với File
import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/personal_document_entity.dart';
import 'package:dartz/dartz.dart';


/// Repository để quản lý các tài liệu cá nhân do người dùng tạo ra.
/// Nó định nghĩa hợp đồng cho việc tạo, truy xuất và xóa các tài liệu này.
abstract class PersonalDocumentRepository {
  /// Tạo một sách nói từ một file do người dùng cung cấp (PDF, TXT, DOCX, ...).
  ///
  /// [file]: Đối tượng File được chọn bởi người dùng.
  /// [title]: Tiêu đề cho sách nói sẽ được tạo.
  /// [summarize]: Cờ boolean để cho biết có nên tóm tắt nội dung trước khi chuyển thành giọng nói hay không.
  ///
  /// Trả về [PersonalDocumentEntity] vừa được tạo nếu thành công,
  /// hoặc [Failure] nếu có lỗi xảy ra.
  Future<Either<Failure, PersonalDocumentEntity>> createDocumentFromFile({
    required File file,
    required String title,
    bool summarize = false,
  });

  /// Tạo một sách nói từ một URL trang web.
  ///
  /// [url]: Chuỗi URL của trang web cần xử lý.
  /// [title]: Tiêu đề cho sách nói sẽ được tạo.
  /// [summarize]: Cờ boolean để cho biết có nên tóm tắt nội dung trước khi chuyển thành giọng nói hay không.
  ///
  /// Trả về [PersonalDocumentEntity] vừa được tạo nếu thành công,
  /// hoặc [Failure] nếu có lỗi xảy ra.
  Future<Either<Failure, PersonalDocumentEntity>> createDocumentFromUrl({
    required String url,
    required String title,
    bool summarize = false,
  });

  /// Lấy danh sách tất cả các tài liệu cá nhân của người dùng hiện tại.
  ///
  /// Trả về một danh sách các [PersonalDocumentEntity] nếu thành công,
  /// hoặc [Failure] nếu có lỗi.
  Future<Either<Failure, List<PersonalDocumentEntity>>> getUserDocuments();

  /// Xóa một tài liệu cá nhân dựa trên ID của nó.
  ///
  /// [documentId]: ID của tài liệu cần xóa.
  ///
  /// Trả về [void] nếu xóa thành công, hoặc [Failure] nếu có lỗi.
  Future<Either<Failure, void>> deleteDocument(String documentId);
}