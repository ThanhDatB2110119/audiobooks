import 'dart:async';

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
    // Không cần initialLocation nữa, redirect sẽ xử lý
    // initialLocation: '/login',

    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/page2',
                name: 'page2',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: const Text('Page 2')),
                  body: const Center(child: Text('Welcome to Page 2!')),
                ),
              ),
            ],
          ),
          //... các branch khác
        ],
      ),
    ],

    // Luồng lắng nghe sự thay đổi trạng thái
    refreshListenable: GoRouterRefreshStream(
      BlocProvider.of<AuthCubit>(_rootNavigatorKey.currentContext!).stream,
    ),

    // Hàm redirect sẽ chạy mỗi khi có một yêu cầu điều hướng mới
    redirect: (BuildContext context, GoRouterState state) {
      // Lấy trạng thái xác thực từ BLoC
      final authState = context.read<AuthCubit>().state;
      final location = state.matchedLocation;

      // Kiểm tra các trường hợp:
      // 1. Nếu đang loading hoặc initial, không làm gì cả, chờ trạng thái tiếp theo.
      final isLoading = authState is AuthLoading || authState is AuthInitial;
      if (isLoading) return null; // Không chuyển hướng khi đang tải

      // 2. Kiểm tra người dùng đã đăng nhập chưa
      final isLoggedIn = authState is AuthAuthenticated;

      // 3. Kiểm tra xem người dùng có đang ở trang login không
      final isLoggingIn = location == '/login';

      // Logic điều hướng:
      // - Nếu chưa đăng nhập VÀ không ở trang login -> chuyển về trang login.
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // - Nếu đã đăng nhập VÀ đang ở trang login -> chuyển vào trang home.
      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      // 4. Trong mọi trường hợp khác, không cần chuyển hướng.
      return null;
    },
  );
}
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}