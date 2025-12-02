import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/personal_document_entity.dart';
import 'package:audiobooks/domain/repositories/personal_document_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeleteDocumentUsecase {
  final PersonalDocumentRepository repository;

  DeleteDocumentUsecase(this.repository);

  Future<Either<Failure, void>> call(PersonalDocumentEntity document) async {
    return await repository.deleteDocument(document);
  }
}