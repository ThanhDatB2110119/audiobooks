import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/domain/entities/mock_books.dart';
import 'package:audiobooks/domain/repositories/book_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

abstract class Env {
  static const dev = 'dev';
  static const prod = 'prod';
}

@LazySingleton(as: BookRepository, env: [Env.dev]) // <-- Dòng quan trọng
class MockBookRepositoryImpl implements BookRepository {
  @override
  Future<Either<Failure, List<BookEntity>>> getBooks({String? categoryId}) async {
    // Giả lập một chút độ trễ mạng
    await Future.delayed(const Duration(seconds: 1));
    
    // Trả về dữ liệu giả
    return Right(mockBooks);
  }

  @override
  Future<Either<Failure, BookEntity>> getBookById(int id) async {
    // Giả lập độ trễ mạng
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Tìm cuốn sách đầu tiên trong danh sách mock có id trùng khớp
      final book = mockBooks.firstWhere((book) => book.id == id);
      return Right(book);
    } catch (e) {
      // Nếu không tìm thấy sách, trả về một lỗi
      return Left(ServerFailure('Book with id $id not found'));
    }
  }
}