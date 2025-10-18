// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  supabase.User? get currentUser {
    final session = remoteDataSource.currentUserSession;
    if (session != null) {
      return session.user;
    }
    return null;
  }

  @override
  Future<supabase.User?> signInWithGoogle() async {
    try {
      final authResponse = await remoteDataSource.signInWithGoogle();
      return authResponse.user;
    } catch (e) {
      // Bạn có thể xử lý lỗi ở đây hoặc throw để BLoC xử lý
      print(e.toString()); // Log lỗi
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }
}
