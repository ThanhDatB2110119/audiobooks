part of 'auth_bloc.dart';

// @freezed
// class AuthEvent with _$AuthEvent {
//   const factory AuthEvent.started() = _Started;
// }
@freezed
class AuthEvent with _$AuthEvent {
  // Sự kiện yêu cầu đăng nhập bằng Google
  const factory AuthEvent.googleSignInRequested() = _GoogleSignInRequested;

  // Sự kiện yêu cầu đăng xuất
  const factory AuthEvent.signOutRequested() = _SignOutRequested;
  
  // (Tùy chọn) Sự kiện để kiểm tra trạng thái đăng nhập ban đầu
  // const factory AuthEvent.authCheckRequested() = _AuthCheckRequested;
}