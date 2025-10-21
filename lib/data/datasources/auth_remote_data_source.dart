// lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> signInWithGoogle();
  Future<void> signOut();
  Session? get currentUserSession;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl(this._supabaseClient, this._googleSignIn);

  @override
  Session? get currentUserSession => _supabaseClient.auth.currentSession;

  @override
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // 1. Bắt đầu quá trình đăng nhập Google
      final googleUser = await _googleSignIn.authenticate();
      

      // 2. Lấy thông tin xác thực (idToken, accessToken)
      final googleAuth =  googleUser.authentication;
      final accessToken = googleAuth.idToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'Không tìm thấy Access Token.';
      }
      if (idToken == null) {
        throw 'Không tìm thấy ID Token.';
      }

      // 3. Đăng nhập vào Supabase bằng thông tin từ Google
      return _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      // Ném lỗi để lớp Repository có thể bắt và xử lý
      throw 'Lỗi khi đăng nhập bằng Google: $e';
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _supabaseClient.auth.signOut();
  }
}