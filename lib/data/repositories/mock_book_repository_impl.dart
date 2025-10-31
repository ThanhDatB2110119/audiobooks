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
}