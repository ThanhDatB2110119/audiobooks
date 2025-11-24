import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/repositories/personal_document_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CreateDocumentFromTextUsecase {
  final PersonalDocumentRepository repository;

  CreateDocumentFromTextUsecase(this.repository);

  Future<Either<Failure, void>> call(String text) async {
    if (text.trim().isEmpty) {
      return Left(ServerFailure('Văn bản không được để trống.'));
    }
    return await repository.createDocumentFromText(text);
  }
}
