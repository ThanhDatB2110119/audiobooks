// domain/usecases/upload_avatar_usecase.dart
 // Giả sử repo này sẽ xử lý việc upload

import 'dart:io';

import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/repositories/user_profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UploadAvatarUsecase {
  final UserProfileRepository repository;

  UploadAvatarUsecase(this.repository);
  
  /// Upload một file ảnh avatar và trả về URL công khai của nó.
  Future<Either<Failure, String>> call(File imageFile) async {
    return await repository.uploadAvatar(imageFile);
  }
}