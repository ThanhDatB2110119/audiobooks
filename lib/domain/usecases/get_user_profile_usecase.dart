// domain/usecases/get_user_profile_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/user_profile_entity.dart';
import 'package:audiobooks/domain/repositories/user_profile_repository.dart';

@lazySingleton
class GetUserProfileUsecase {
  final UserProfileRepository repository;

  GetUserProfileUsecase(this.repository);

  /// Gọi use case này để lấy thông tin hồ sơ của người dùng đang đăng nhập.
  Future<Either<Failure, UserProfileEntity>> call() async {
    return await repository.getUserProfile();
  }
}