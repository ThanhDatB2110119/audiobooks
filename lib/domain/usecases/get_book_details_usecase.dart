import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/domain/repositories/book_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetBookDetailsUsecase {
  final BookRepository repository;

  GetBookDetailsUsecase(this.repository);

  Future<Either<Failure, BookEntity>> call(String id) async {
    return await repository.getBookById(int.parse(id));
  }
}