
import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:dartz/dartz.dart';

abstract class BookRepository {
  // Lấy tất cả sách hoặc sách theo thể loại
  Future<Either<Failure, List<BookEntity>>> getBooks({String? categoryId});
}
