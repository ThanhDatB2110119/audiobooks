import 'package:audiobooks/core/error/exceptions.dart';
import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/data/datasources/book_remote_data_source.dart';
import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/domain/repositories/book_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BookRepository)
class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;

  BookRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<BookEntity>>> getBooks({String? categoryId}) async {
    try {
      final bookModels = await remoteDataSource.getBooks(categoryId: categoryId);
      return Right(bookModels); // Models cũng là Entities nhờ kế thừa
    } on ServerException {
      return Left(ServerFailure('Failed to fetch books from server'));
    }
  }
}