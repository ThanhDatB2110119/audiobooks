import 'dart:async';

import 'package:audiobooks/core/injection/injection_container.dart' as di;
import 'package:audiobooks/core/utils/logger.dart';
import 'package:audiobooks/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:audiobooks/presentation/features/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:audiobooks/presentation/features/home/pages/home_page.dart';
import 'package:audiobooks/presentation/shell/main_shell.dart';


class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  // Tạo router như một static getter để có thể truy cập context
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          appLogger.i('Điều hướng tới trang Đăng nhập');
          return const LoginPage();
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          appLogger.i('Tạo MainShell với navigationShell');
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) {
                  appLogger.i('Điều hướng tới trang Home');
                  return const HomePage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/page2',
                name: 'page2',
                builder: (context, state) {
                  appLogger.i('Điều hướng tới trang Page 2');
                  return Scaffold(
                    appBar: AppBar(title: const Text('Page 2')),
                    body: const Center(child: Text('Welcome to Page 2!')),
                  );
                },
              ),
            ],
          ),
          //... các branch khác
        ],
      ),
    ],

    // Luồng lắng nghe sự thay đổi trạng thái
    refreshListenable: GoRouterRefreshStream(
      di.getIt<AuthCubit>().stream,
    ),

    // Hàm redirect sẽ chạy mỗi khi có một yêu cầu điều hướng mới
    redirect: (BuildContext context, GoRouterState state) {
      // Lấy trạng thái xác thực từ BLoC
      final authState = context.read<AuthCubit>().state;
      final location = state.matchedLocation;

      appLogger.i('redirect: Trạng thái xác thực: $authState, Địa chỉ hiện tại: $location');

      // Kiểm tra các trường hợp:
      // 1. Nếu đang loading hoặc initial, không làm gì cả, chờ trạng thái tiếp theo.
      final isLoading = authState is AuthLoading || authState is AuthInitial;
      if (isLoading) {
        appLogger.i('Đang tải hoặc trạng thái khởi tạo, không chuyển hướng');
        return null; // Không chuyển hướng khi đang tải
      }

      // 2. Kiểm tra người dùng đã đăng nhập chưa
      final isLoggedIn = authState is AuthAuthenticated;

      // 3. Kiểm tra xem người dùng có đang ở trang login không
      final isLoggingIn = location == '/login';

      // Logic điều hướng:
      // - Nếu chưa đăng nhập VÀ không ở trang login -> chuyển về trang login.
      if (!isLoggedIn && !isLoggingIn) {
        appLogger.i('Chưa đăng nhập, chuyển hướng về trang Đăng nhập');
        return '/login';
      }

      // - Nếu đã đăng nhập VÀ đang ở trang login -> chuyển vào trang home.
      if (isLoggedIn && isLoggingIn) {
        appLogger.i('Đã đăng nhập, chuyển hướng về trang Home');
        return '/home';
      }

      // 4. Trong mọi trường hợp khác, không cần chuyển hướng.
      appLogger.i('Không cần chuyển hướng');
      return null;
    },
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    appLogger.i('Khởi tạo GoRouterRefreshStream');
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      appLogger.i('GoRouterRefreshStream nhận sự kiện mới, thông báo listeners');
      notifyListeners();
    });
  }

  @override
  void dispose() {
    appLogger.i('Hủy GoRouterRefreshStream');
    _subscription.cancel();
    super.dispose();
  }
}