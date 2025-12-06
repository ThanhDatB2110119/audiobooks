// core/events/library_events.dart

import 'dart:async';

/// Một class singleton để quản lý các sự kiện liên quan đến thư viện.
/// Nó hoạt động như một "tổng đài" thông báo.
class LibraryEventBus {
  // --- Singleton Setup ---
  static final LibraryEventBus _instance = LibraryEventBus._internal();
  factory LibraryEventBus() {
    return _instance;
  }
  LibraryEventBus._internal();
  // -----------------------

  // Tạo một StreamController. `broadcast` cho phép có nhiều người nghe.
  final _controller = StreamController<void>.broadcast();

  /// Stream mà các Cubit khác (như LibraryCubit) sẽ lắng nghe.
  Stream<void> get stream => _controller.stream;

  /// Hàm mà các Cubit khác (như BookDetailsCubit) sẽ gọi để "phát sóng" sự kiện.
  void fireLibraryChanged() {
    _controller.add(null); // Gửi một sự kiện rỗng, chỉ cần biết là có thay đổi.
  }

  /// Nhớ gọi hàm này khi ứng dụng đóng (nếu cần)
  void dispose() {
    _controller.close();
  }
}
