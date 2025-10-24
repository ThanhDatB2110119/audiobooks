// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:audiobooks/core/error/exceptions.dart';
import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';


// @LazySingleton(as: AuthRepository)
// class AuthRepositoryImpl implements AuthRepository {
//   final AuthRemoteDataSource remoteDataSource;

//   AuthRepositoryImpl(this.remoteDataSource);

//   @override
//   supabase.User? get currentUser {
//     final session = remoteDataSource.currentUserSession;
//     if (session != null) {
//       return session.user;
//     }
//     return null;
//   }

//   @override
//   Future<supabase.User?> signInWithGoogle() async {
//     try {
//       final authResponse = await remoteDataSource.signInWithGoogle();
//       return authResponse.user;
//     } catch (e) {
//       // Bạn có thể xử lý lỗi ở đây hoặc throw để BLoC xử lý
//       print(e.toString()); // Log lỗi
//       return null;
//     }
//   }

//   @override
//   Future<void> signOut() async {
//     await remoteDataSource.signOut();
//   }
// }
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(AuthRemoteDataSource authRemoteDataSource, {required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      // DataSource sẽ trả về một UserEntity hoặc ném ra ServerException
      final userEntity = await remoteDataSource.signInWithGoogle();
      // Nếu thành công, gói kết quả vào trong Right
      // ignore: unnecessary_cast
      return Right(userEntity as UserEntity); 
    } on ServerException catch (e) {
      // Nếu có lỗi từ server (API, Google Sign In...), gói thông báo lỗi vào trong Left
      return Left(ServerFailure(e.message));
    } catch (e) {
      // Bắt các lỗi không mong muốn khác
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null); // Thành công, không có giá trị trả về
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}
