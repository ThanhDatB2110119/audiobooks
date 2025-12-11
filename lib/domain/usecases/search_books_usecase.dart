// domain/usecases/search_books_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

@lazySingleton
class SearchBooksUsecase {
  final BookRepository repository;

  SearchBooksUsecase(this.repository);

  Future<Either<Failure, List<BookEntity>>> call(String query) async {
    if (query.trim().isEmpty) {
      // Trả về danh sách rỗng nếu query trống
      return const Right([]);
    }
    return await repository.searchBooks(query);
  }
}