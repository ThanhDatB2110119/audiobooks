
import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/personal_document_entity.dart';
import 'package:dartz/dartz.dart';

abstract class PersonalDocumentRepository {
  // Phương thức cũ (nếu có)
  Future<Either<Failure, List<PersonalDocumentEntity>>> getUserDocuments();

  // ======================= THÊM HỢP ĐỒNG MỚI TẠI ĐÂY =======================
  /// Tạo một tài liệu sách nói từ một chuỗi văn bản.
  /// Trả về void nếu thành công, hoặc Failure nếu thất bại.
  Future<Either<Failure, void>> createDocumentFromText(String text);
  // ========================================================================
}