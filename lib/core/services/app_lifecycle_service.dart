// core/services/app_lifecycle_service.dart

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart'; // <-- Thêm import
import 'package:injectable/injectable.dart';

@lazySingleton
class AppLifecycleService {
  final GoRouter _router; // Inject GoRouter
  late final AppLifecycleListener _listener;

  AppLifecycleService(this._router) {
    _listener = AppLifecycleListener(
      onResume: _onResume,
    );
  }

  /// Khi ứng dụng quay lại từ nền (sau khi đăng nhập Google xong)
  void _onResume() {
    print('--- App Resumed. Forcing GoRouter to re-evaluate routes. ---');
    
    // "Làm mới" GoRouter. Lệnh này sẽ buộc GoRouter chạy lại hàm redirect.
    // Đây là một cách "chính thống" để thông báo cho router về sự thay đổi
    // trạng thái bên ngoài mà `refreshListenable` có thể đã bỏ lỡ.
    _router.refresh(); 
  }
  
  void dispose() {
    _listener.dispose();
  }
}