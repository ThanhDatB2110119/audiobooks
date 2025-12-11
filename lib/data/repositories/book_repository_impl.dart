import 'package:audiobooks/core/error/exceptions.dart';
import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/data/datasources/book_remote_data_source.dart';
import 'package:audiobooks/data/repositories/mock_book_repository_impl.dart';
import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/domain/entities/book_part_entity.dart';
import 'package:audiobooks/domain/entities/category_entity.dart';
import 'package:audiobooks/domain/repositories/book_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BookRepository, env: [Env.prod])
class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;

  BookRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<BookEntity>>> getBooks({
    String? categoryId,
  }) async {
    try {
      final bookModels = await remoteDataSource.getBooks(
        categoryId: categoryId,
      );
      return Right(bookModels); // Models cũng là Entities nhờ kế thừa
    } on ServerException {
      return Left(ServerFailure('Failed to fetch books from server'));
    }
  }
@override
  Future<Either<Failure, List<BookEntity>>> searchBooks(String query) async {
    try {
      final books = await remoteDataSource.searchBooks(query);
      return Right(books);
    } on ServerException catch (e) {
      return Left(ServerFailure( e.message));
    }
  }
@override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure( e.message));
    }
  }
  @override
  Future<Either<Failure, BookEntity>> getBookById(int id) async {
    try {
      final bookModel = await remoteDataSource.getBookById(id.toString());
      return Right(bookModel);
    } on ServerException {
      return Left(ServerFailure('Failed to fetch book details from server'));
    }
  }

  @override
  Future<Either<Failure, bool>> isBookSaved(String bookId) async {
    try {
      final isSaved = await remoteDataSource.isBookSaved(bookId);
      return Right(isSaved);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addBookToLibrary(String bookId) async {
    try {
      await remoteDataSource.addBookToLibrary(bookId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeBookFromLibrary(String bookId) async {
    try {
      await remoteDataSource.removeBookFromLibrary(bookId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> getSavedBooks() async {
    try {
      final books = await remoteDataSource.getSavedBooks();
      return Right(books);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
@override
  Future<Either<Failure, List<BookPartEntity>>> getBookParts(String bookId) async {
    try {
      final parts = await remoteDataSource.getBookParts(bookId);
      return Right(parts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
