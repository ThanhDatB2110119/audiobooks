import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/domain/repositories/book_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetAllBooksUsecase {
  final BookRepository repository;

  GetAllBooksUsecase(this.repository);

  Future<Either<Failure, List<BookEntity>>> call() async {
    return await repository.getBooks();
  }
}