part of 'auth_bloc.dart';

// @freezed
// class AuthState with _$AuthState {
//   const factory AuthState.initial() = _Initial;
//   const factory AuthState.loading() = _Loading;
//   const factory AuthState.authenticated(String userId) = _Authenticated;
//   const factory AuthState.unauthenticated() = _Unauthenticated;
//   const factory AuthState.error(String message) = _Error;
// }
@freezed
class AuthState with _$AuthState {
  // Trạng thái ban đầu, chưa biết đăng nhập hay chưa
  const factory AuthState.initial() = _Initial;
  
  // Trạng thái đang xử lý (ví dụ: đang đăng nhập)
  const factory AuthState.loading() = _Loading;

  // Trạng thái đã đăng nhập thành công, chứa thông tin UserEntity
  const factory AuthState.authenticated({required UserEntity user}) = _Authenticated;
  
  // Trạng thái chưa đăng nhập
  const factory AuthState.unauthenticated() = _Unauthenticated;

  // Trạng thái có lỗi, chứa thông điệp lỗi
  const factory AuthState.error({required String message}) = _Error;
}
