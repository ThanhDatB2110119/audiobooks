import 'package:audiobooks/domain/entities/user_entity.dart';
import 'package:audiobooks/domain/usecases/google_sign_in_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final GoogleSignInUseCase _googleSignInUseCase;
  AuthCubit(this._googleSignInUseCase) : super(AuthInitial());

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

  
}
