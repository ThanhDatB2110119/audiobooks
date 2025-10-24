import 'package:audiobooks/domain/entities/user_entity.dart';
import 'package:audiobooks/domain/usecases/google_sign_in_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

@injectable // Hoặc @factory
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // BLoC phụ thuộc vào Use Cases, không phải Repository
  final GoogleSignInUseCase _googleSignInUseCase;
  // final SignOutUseCase _signOutUseCase; // Sẽ thêm sau

  AuthBloc(this._googleSignInUseCase) : super(const AuthState.initial()) {
    on<_GoogleSignInRequested>(_onGoogleSignInRequested);
    // on<_SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onGoogleSignInRequested(
    _GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    // 1. Chuyển sang trạng thái loading
    emit(const AuthState.loading());

    // 2. Gọi Use Case
    final result = await _googleSignInUseCase(); // Use Case trả về Either

    // 3. Xử lý kết quả từ Either bằng `fold`
    result.fold(
      // Trường hợp bên Trái (Left), là Failure
      (failure) => emit(AuthState.error(message: failure.message)),
      // Trường hợp bên Phải (Right), là dữ liệu thành công (UserEntity)
      (user) => emit(AuthState.authenticated(user: user)),
    );
  }

  /*
  // Đây là cách bạn sẽ implement signOut
  Future<void> _onSignOutRequested(
    _SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _signOutUseCase();
    result.fold(
      (failure) => emit(AuthState.error(message: failure.message)),
      (_) => emit(const AuthState.unauthenticated()), // thành công thì về unauthenticated
    );
  }
  */
}
