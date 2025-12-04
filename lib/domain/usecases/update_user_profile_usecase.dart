import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/user_profile_entity.dart';
import 'package:audiobooks/domain/repositories/user_profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UpdateUserProfileUsecase {
  final UserProfileRepository repository;

  UpdateUserProfileUsecase(this.repository);

  Future<Either<Failure, void>> call(UserProfileEntity profile) async {
    return await repository.updateUserProfile(profile);
  }
}