// domain/usecases/get_user_documents_usecase.dart

import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/personal_document_entity.dart';
import 'package:audiobooks/domain/repositories/personal_document_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetUserDocumentsUsecase {
  final PersonalDocumentRepository repository;

  GetUserDocumentsUsecase(this.repository);

  Future<Either<Failure, List<PersonalDocumentEntity>>> call() async {
    return await repository.getUserDocuments();
  }
}