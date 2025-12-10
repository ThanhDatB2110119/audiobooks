// domain/usecases/get_categories_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/book_repository.dart';

@lazySingleton
class GetCategoriesUsecase {
  final BookRepository repository;

  GetCategoriesUsecase(this.repository);

  Future<Either<Failure, List<CategoryEntity>>> call() async {
    return await repository.getCategories();
  }
}