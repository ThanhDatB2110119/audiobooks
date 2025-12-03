// data/repositories/personal_document_repository_impl.dart

import 'dart:io';

import 'package:audiobooks/core/error/exceptions.dart';
import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/data/datasources/personal_document_remote_data_source.dart';
import 'package:audiobooks/domain/entities/personal_document_entity.dart';
import 'package:audiobooks/domain/repositories/personal_document_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PersonalDocumentRepository)
class PersonalDocumentRepositoryImpl implements PersonalDocumentRepository {
  final PersonalDocumentRemoteDataSource remoteDataSource;

  PersonalDocumentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<PersonalDocumentEntity>>>
  getUserDocuments() async {
    try {
      final documents = await remoteDataSource.getUserDocuments();
      return Right(documents);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ======================= TRIỂN KHAI PHƯƠNG THỨC MỚI TẠI ĐÂY =======================
  @override
  Future<Either<Failure, void>> createDocumentFromText(String text) async {
    try {
      await remoteDataSource.createDocumentFromText(text);
      return const Right(null); // Trả về Right(null) để báo hiệu thành công
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> createDocumentFromFile(File file) async {
    try {
      await remoteDataSource.createDocumentFromFile(file);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(
    PersonalDocumentEntity document,
  ) async {
    try {
      await remoteDataSource.deleteDocument(document);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> createDocumentFromUrl(String url) async {
    try {
      await remoteDataSource.createDocumentFromUrl(url);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ===============================================================================
}
