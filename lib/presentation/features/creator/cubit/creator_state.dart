// presentation/features/creator/cubit/creator_state.dart

import 'package:equatable/equatable.dart';

// Đánh dấu lớp là abstract để nó không thể được khởi tạo trực tiếp,
// chỉ các lớp con của nó mới có thể.
abstract class CreatorState extends Equatable {
  const CreatorState();

  @override
  List<Object> get props => [];
}

/// Trạng thái ban đầu của màn hình Creator.
/// Khi màn hình vừa được mở và chưa có hành động nào xảy ra.
class CreatorInitial extends CreatorState {}

/// Trạng thái đang xử lý.
/// Ví dụ: đang upload file text, đang gửi yêu cầu tạo document...
/// UI có thể hiển thị một CircularProgressIndicator hoặc vô hiệu hóa các nút bấm.
class CreatorLoading extends CreatorState {}

/// Trạng thái thành công.
/// Khi yêu cầu tạo sách nói đã được gửi đi thành công.
/// Chúng ta có thể dùng `message` để hiển thị một thông báo cho người dùng
/// (ví dụ: trong một SnackBar hoặc Dialog).
class CreatorSuccess extends CreatorState {
  final String message;

  const CreatorSuccess(this.message);

  @override
  List<Object> get props => [message];
}

/// Trạng thái lỗi.
/// Khi có lỗi xảy ra trong quá trình tạo sách nói (ví dụ: mất mạng, lỗi server...).
/// `message` sẽ chứa thông tin lỗi để hiển thị cho người dùng.
class CreatorError extends CreatorState {
  final String message;

  const CreatorError(this.message);

  @override
  List<Object> get props => [message];
}
