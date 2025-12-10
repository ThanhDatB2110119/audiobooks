
import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/domain/entities/book_part_entity.dart';
import 'package:dartz/dartz.dart';

abstract class BookRepository {
  // Lấy tất cả sách hoặc sách theo thể loại
  Future<Either<Failure, List<BookEntity>>> getBooks({String? categoryId});

  Future<Either<Failure, BookEntity>> getBookById(int id);
   Future<Either<Failure, List<BookPartEntity>>> getBookParts(String bookId);
  Future<Either<Failure, bool>> isBookSaved(String bookId);
  Future<Either<Failure, void>> addBookToLibrary(String bookId);
  Future<Either<Failure, void>> removeBookFromLibrary(String bookId);
  Future<Either<Failure, List<BookEntity>>> getSavedBooks();
}
