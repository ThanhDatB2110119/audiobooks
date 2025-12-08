import 'package:audiobooks/domain/entities/user_entity.dart';
import 'package:audiobooks/domain/usecases/google_sign_in_usecase.dart';
import 'package:audiobooks/domain/usecases/google_sign_out_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final GoogleSignInUseCase _googleSignInUseCase;
  final GoogleSignOutUseCase _googleSignOutUseCase;
  AuthCubit(this._googleSignInUseCase, this._googleSignOutUseCase)
    : super(AuthInitial()) {
    _checkInitialSession();
  }

  Future<void> googleSignInRequested() async {
    emit(AuthLoading());

    final result = await _googleSignInUseCase();

    result.fold((failure) => emit(AuthUnauthenticated()), (user) {
      // Trên mobile, user object sẽ có dữ liệu
      // Trên web, nó có thể là rỗng, ta sẽ dựa vào auth state listener
      // để chuyển sang trạng thái authenticated sau.
      // Để đơn giản, ta có thể kiểm tra nếu user id không rỗng thì coi là thành công.
      if (user.id.isNotEmpty) {
        emit(AuthAuthenticated(user));
      }
      // Nếu không, ta có thể giữ state loading hoặc chuyển về unauthenticated,
      // chờ listener xử lý.
      else {
        // Trên web, quá trình redirect đã bắt đầu, giữ loading hoặc chờ listener
        // Không emit gì ở đây nếu ta có listener riêng
      }
    });
  }

  void _checkInitialSession() {
    final currentSession = Supabase.instance.client.auth.currentSession;

    if (currentSession != null) {
      print('--- Session restored. User is authenticated. ---');

      // ======================= SỬA LỖI TẠI ĐÂY =======================
      // 1. Lấy đối tượng User của Supabase
      final supabaseUser = currentSession.user;
      // 2. Chuyển đổi nó thành UserEntity của chúng ta
      final userEntity = UserEntity.fromSupabaseUser(supabaseUser);
      // 3. Truyền UserEntity vào state
      emit(AuthAuthenticated(userEntity));
      // ===============================================================
    } else {
      print('--- No active session. User is unauthenticated. ---');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signOutRequested() async {
    emit(AuthLoading()); // Chuyển sang trạng thái loading

    final result = await _googleSignOutUseCase();

    result.fold(
      (failure) {
        // Nếu đăng xuất thất bại, có thể hiển thị lỗi
        // nhưng vẫn giữ người dùng ở trạng thái đăng nhập.
        // Hoặc đơn giản là chuyển về unauthenticated với thông báo lỗi.
        emit(AuthUnauthenticated());
      },
      (_) {
        // Nếu đăng xuất thành công, chuyển sang trạng thái unauthenticated
        emit(AuthUnauthenticated());
      },
    );
  }
}
