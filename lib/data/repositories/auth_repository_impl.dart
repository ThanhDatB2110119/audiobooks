// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:audiobooks/core/error/exceptions.dart';
import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      // Trên web, phương thức này có thể không trả về user ngay lập tức.
      // Tuy nhiên, ta vẫn xử lý luồng chung.
      final response = await remoteDataSource.signInWithGoogle();

      // Nếu là mobile, user sẽ có trong response
      if (response.user != null) {
        final user = response.user!;
        // Ánh xạ từ model của Supabase sang UserEntity của domain
        return Right(
          UserEntity(
            id: user.id,
            email: user.email ?? 'No email',
            name: user.userMetadata?['full_name'] ?? 'No name',
          ),
        );
      } else {
        // Trên web, đây là trường hợp bình thường.
        // Ta trả về một UserEntity rỗng để báo hiệu quá trình đã bắt đầu.
        // Việc xác thực thực sự sẽ được xử lý bởi auth state listener.
        return Right(UserEntity(id: '', email: '', name: null));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null); // Trả về Right(null) để báo hiệu thành công
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
