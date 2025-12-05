import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/repositories/book_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RemoveBookFromLibraryUsecase {
  final BookRepository repository;
  RemoveBookFromLibraryUsecase(this.repository);
  Future<Either<Failure, void>> call(String bookId) => repository.removeBookFromLibrary(bookId);
}