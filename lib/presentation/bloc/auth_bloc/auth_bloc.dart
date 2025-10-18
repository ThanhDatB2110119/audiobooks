import 'package:audiobooks/domain/repositories/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   AuthBloc() : super(_Initial()) {
//     on<AuthEvent>((event, emit) {
//       // TODO: implement event handler
//     });
//   }
// }
// lib/features/auth/presentation/bloc/auth_bloc.dart

// ??
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../domain/repositories/auth_repository.dart';
// import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthState.initial()) {
    // Kiểm tra trạng thái đăng nhập ngay khi khởi tạo
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      emit(AuthState.authenticated(currentUser.id));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        emit(AuthState.authenticated(user.id));
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(const AuthState.loading());
    await _authRepository.signOut();
    emit(const AuthState.unauthenticated());
  }
}
