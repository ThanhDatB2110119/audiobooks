// lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'package:audiobooks/core/error/exceptions.dart';
import 'package:audiobooks/domain/entities/user_entity.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  // THAY ĐỔI 1: Yêu cầu trả về UserEntity thay vì AuthResponse.
  Future<UserEntity> signInWithGoogle();
  Future<void> signOut();
  // Bỏ currentUserSession vì không còn dùng.
}

@LazySingleton(as: AuthRemoteDataSource) // Giữ lại nếu bạn dùng injectable
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  final GoogleSignIn googleSignIn;

  // THAY ĐỔI 2: Sử dụng Dependency Injection để nhận các client.
  // Điều này giúp việc kiểm thử (testing) dễ dàng hơn.
  AuthRemoteDataSourceImpl({required this.supabaseClient, required this.googleSignIn});

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      // 1. Lấy thông tin xác thực từ Google
      // Phương thức signIn() được khuyến nghị hơn authenticate().
      final googleUser = await googleSignIn.signIn();
      
      // THAY ĐỔI 3: Xử lý trường hợp người dùng hủy đăng nhập.
      // ignore: dead_code, unnecessary_null_comparison
      if (googleUser == null) {
        throw ServerException('Google sign in was cancelled by the user.');
      }
      
      final googleAuth =  await googleUser.authentication;
      final accessToken = googleAuth.accessToken; // SỬA LỖI 4: Lấy đúng accessToken
      final idToken = googleAuth.idToken;

      // THAY ĐỔI 5: Ném ServerException với thông báo lỗi rõ ràng.
      // if (accessToken == null) {
      //   throw ServerException('No Access Token found from Google Sign In.');
      // }
      if (idToken == null) {
        throw ServerException('No ID Token found from Google Sign In.');
      }

      // 2. Dùng idToken để đăng nhập vào Supabase
      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken, // accessToken không bắt buộc với Google trên mobile
      );

      if (response.user == null) {
        throw ServerException('Sign in with Google failed on Supabase.');
      }
      
      // THAY ĐỔI 6: Chuyển đổi từ supabase.User sang UserEntity.
      final user = response.user!;
      return UserEntity(
        id: user.id,
        email: user.email ?? '', // Cung cấp giá trị mặc định nếu email có thể null
        name: user.userMetadata?['full_name'] ?? user.userMetadata?['name'],
      );

    } on ServerException {
      rethrow; // Ném lại ServerException để Repository bắt.
    } catch (e) {
      // Bắt tất cả các lỗi khác và gói chúng vào ServerException.
      throw ServerException('An error occurred during Google sign in: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException('Error during sign out: ${e.toString()}');
    }
  }
}


