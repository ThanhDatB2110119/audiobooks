// domain/usecases/get_book_parts_usecase.dart

import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/book_part_entity.dart';
import 'package:audiobooks/domain/repositories/book_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetBookPartsUsecase {
  final BookRepository repository;

  GetBookPartsUsecase(this.repository);

  /// Gọi đến repository để lấy danh sách các phần của một cuốn sách
  /// dựa trên ID của cuốn sách đó.
  Future<Either<Failure, List<BookPartEntity>>> call(String bookId) async {
    // Có thể thêm validation ở đây nếu cần, ví dụ:
    if (bookId.isEmpty) {
      return Left(const ServerFailure( 'Book ID không hợp lệ.'));
    }
    return await repository.getBookParts(bookId);
  }
}