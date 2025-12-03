import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/repositories/personal_document_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CreateDocumentFromUrlUsecase {
  final PersonalDocumentRepository repository;

  CreateDocumentFromUrlUsecase(this.repository);

  Future<Either<Failure, void>> call(String url) async {
    // Có thể thêm validation URL ở đây nếu muốn
    return await repository.createDocumentFromUrl(url);
  }
}
