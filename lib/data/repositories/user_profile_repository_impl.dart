// data/repositories/user_profile_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:audiobooks/core/error/exceptions.dart';
import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/data/models/user_profile_model.dart';
import 'package:audiobooks/domain/entities/user_profile_entity.dart';
import 'package:audiobooks/domain/repositories/user_profile_repository.dart';
import 'package:audiobooks/data/datasources/user_profile_remote_data_source.dart';

@LazySingleton(as: UserProfileRepository)
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;

  UserProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile() async {
    try {
      final userProfileModel = await remoteDataSource.getUserProfile();
      return Right(userProfileModel); // Model cũng là Entity nhờ kế thừa
    } on ServerException catch (e) {
      return Left(ServerFailure( e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(UserProfileEntity profile) async {
    try {
      final profileModel = UserProfileModel.fromEntity(profile);
      await remoteDataSource.updateUserProfile(profileModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure( e.message));
    }
  }
}