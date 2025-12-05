import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/repositories/book_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CheckBookSavedStatusUsecase {
  final BookRepository repository;
  CheckBookSavedStatusUsecase(this.repository);
  Future<Either<Failure, bool>> call(String bookId) => repository.isBookSaved(bookId);
}