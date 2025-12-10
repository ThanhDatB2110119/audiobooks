import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/domain/repositories/book_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetAllBooksUsecase {
  final BookRepository repository;

  GetAllBooksUsecase(this.repository);

  Future<Either<Failure, List<BookEntity>>> call({String? categoryId}) async {
    // Truyền categoryId xuống cho repository.
    return await repository.getBooks(categoryId: categoryId);
  }
}

class GetAllBooksParams {
  final String? categoryId;
  GetAllBooksParams({this.categoryId});
}
