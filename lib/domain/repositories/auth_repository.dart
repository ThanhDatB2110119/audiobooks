// lib/features/auth/domain/repositories/auth_repository.dart
// import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:dartz/dartz.dart';
import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/user_entity.dart';
// abstract class AuthRepository {
//   Future<supabase.User?> signInWithGoogle();
//   Future<void> signOut();
//   supabase.User? get currentUser;
// }
abstract class AuthRepository {
  
  // THAY ĐỔI 1: Kiểu trả về là Either để xử lý lỗi một cách tường minh.
  // Left(Failure) cho trường hợp lỗi, Right(UserEntity) cho trường hợp thành công.
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  // THAY ĐỔI 2: Kiểu trả về của signOut cũng nên là Either để xử lý lỗi nếu có.
  Future<Either<Failure, void>> signOut();

  // Bỏ 'currentUser' getter vì trạng thái xác thực thường là bất đồng bộ.
  // Chúng ta có thể tạo một use case riêng cho việc này nếu cần, ví dụ:
  // Future<Either<Failure, UserEntity?>> getCurrentUser();
}
