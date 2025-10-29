// lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'package:audiobooks/core/error/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> signInWithGoogle();
  Future<void> signOut();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.googleSignIn,
  });

  @override
  Future<AuthResponse> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Đối với Web, Supabase xử lý redirect
        final success = await supabaseClient.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'YOUR_APP_CALLBACK_URL_OR_DEEP_LINK', // Tùy chọn, có thể bỏ qua nếu cấu hình trong Supabase
        );
        if (!success) {
          throw ServerException( 'Google Sign-In for Web failed.');
        }
        // Trên web, sau khi redirect, ta không nhận được AuthResponse ngay lập tức.
        // Ta sẽ lắng nghe auth state change ở tầng presentation.
        // Vì vậy, ta trả về một AuthResponse rỗng để biểu thị quá trình đã bắt đầu.
        return AuthResponse();

      } else {
        // Đối với Mobile (Android/iOS)
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          // Người dùng hủy đăng nhập
          throw ServerException('Google Sign-In cancelled by user.');
        }
        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        if (accessToken == null) {
          throw ServerException('No Access Token found.');
        }
        if (idToken == null) {
          throw ServerException('No ID Token found.');
        }

        return await supabaseClient.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
      }
    } catch (e) {
      // Bắt các lỗi khác và ném ra ServerException
      throw ServerException(e.toString());
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      // Đăng xuất khỏi cả Supabase và Google
      await googleSignIn.signOut();
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException('Failed to sign out: ${e.toString()}');
    }
  }
}


