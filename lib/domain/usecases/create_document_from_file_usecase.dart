import 'dart:io';

import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/repositories/personal_document_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CreateDocumentFromFileUsecase {
  final PersonalDocumentRepository repository;

  CreateDocumentFromFileUsecase(this.repository);

  Future<Either<Failure, void>> call(File file) async {
    // Có thể thêm logic kiểm tra kích thước file ở đây nếu muốn
    return await repository.createDocumentFromFile(file);
  }
}