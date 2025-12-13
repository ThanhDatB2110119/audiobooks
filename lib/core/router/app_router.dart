import 'dart:async';

import 'package:audiobooks/core/injection/injection_container.dart' as di;
import 'package:audiobooks/core/utils/logger.dart';
import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/domain/entities/user_profile_entity.dart';
import 'package:audiobooks/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:audiobooks/presentation/features/auth/pages/login_page.dart';
import 'package:audiobooks/presentation/features/book_detail/pages/book_details_page.dart';
import 'package:audiobooks/presentation/features/creator/pages/creator_page.dart';
import 'package:audiobooks/presentation/features/library/pages/library_page.dart';
import 'package:audiobooks/presentation/features/player/pages/player_page.dart';
import 'package:audiobooks/presentation/features/search/pages/search_page.dart';
import 'package:audiobooks/presentation/features/settings/pages/profile_edit_page.dart';
import 'package:audiobooks/presentation/features/settings/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:audiobooks/presentation/features/home/pages/home_page.dart';
import 'package:audiobooks/presentation/shell/main_shell.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

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

      GoRoute(
        path: '/player',
        name: 'player',
        builder: (context, state) {
          // Lấy object `book` được truyền qua tham số `extra` khi gọi `context.push`.
          // Đây là cách để truyền các đối tượng phức tạp mà không cần đưa lên URL.
          return const PlayerPage();
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

                routes: [
                  GoRoute(
                    // Path sẽ là '/home/details/:bookId'
                    path:
                        'details/:bookId', // `details/:bookId` là phần nối tiếp của `/home`
                    name: 'bookDetails',
                    builder: (context, state) {
                      // Lấy tham số `bookId` từ URL
                      final String? bookId = state.pathParameters['bookId'];
                      final extraData = state.extra as Map<String, dynamic>?;
                      // Kiểm tra null để đảm bảo an toàn
                      if (bookId == null ||
                          extraData == null ||
                          extraData['books'] == null ||
                          extraData['index'] == null) {
                        return const Scaffold(
                          body: Center(
                            child: Text('Lỗi: Thiếu thông tin sách.'),
                          ),
                        );
                      }

                      appLogger.i(
                        'Điều hướng tới trang Chi tiết sách với ID: $bookId',
                      );
                      return BookDetailsPage(
                        bookId: bookId,
                        books: extraData['books'] as List<BookEntity>,
                        currentIndex: extraData['index'] as int,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'search',
                    name: 'search',
                    builder: (context, state) => const SearchPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/creator',
                name: 'creator',
                builder: (context, state) {
                  appLogger.i('Điều hướng tới trang Creator');
                  return const CreatorPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                name: 'library',
                builder: (context, state) {
                  appLogger.i('Điều hướng tới trang Library');
                  return const LibraryPageContainer();
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) {
                  appLogger.i('Điều hướng tới trang Settings');
                  return const SettingsPage();
                },
                routes: [
                  GoRoute(
                    path: 'profile-edit', // URL sẽ là /settings/profile-edit
                    name: 'profileEdit',
                    builder: (context, state) {
                      // Lấy profile hiện tại từ extra để trang edit có dữ liệu ban đầu
                     return const ProfileEditPage();

                    },
                  ),
                ],
              ),
            ],
          ),
          //... các branch khác
        ],
      ),
    ],

    // Luồng lắng nghe sự thay đổi trạng thái
    refreshListenable: GoRouterRefreshStream(di.getIt<AuthCubit>().stream),

    // Hàm redirect sẽ chạy mỗi khi có một yêu cầu điều hướng mới
    redirect: (BuildContext context, GoRouterState state) {
      // Lấy trạng thái xác thực từ BLoC
      final authState = context.read<AuthCubit>().state;
      final location = state.matchedLocation;

      appLogger.i(
        'redirect: Trạng thái xác thực: $authState, Địa chỉ hiện tại: $location',
      );

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
      appLogger.i(
        'GoRouterRefreshStream nhận sự kiện mới, thông báo listeners',
      );
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



// CẬP NHẬT MỚI CHO SPLASH SCREEN VÀ CÁC ROUTE CON


// class AppRouter {
//   static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

//   static GoRouter get router => _router;

//   static final GoRouter _router = GoRouter(
//     navigatorKey: _rootNavigatorKey,
//     // THAY ĐỔI 1: Bắt đầu từ Splash Screen
//     initialLocation: '/',
//     routes: [
//       // Route cho Splash Screen
//       GoRoute(
//         path: '/',
//         name: 'splash',
//         builder: (context, state) {
//           appLogger.i('Điều hướng tới trang Splash');
//           return const SplashPage();
//         },
//       ),

//       // Route cho Login Screen (nằm ngoài shell)
//       GoRoute(
//         path: '/login',
//         name: 'login',
//         builder: (context, state) {
//           appLogger.i('Điều hướng tới trang Đăng nhập');
//           return const LoginPage();
//         },
//       ),

//       // THAY ĐỔI 2: Cập nhật các branch cho StatefulShellRoute
//       StatefulShellRoute.indexedStack(
//         builder: (context, state, navigationShell) {
//           appLogger.i('Tạo MainShell với navigationShell');
//           return MainShell(navigationShell: navigationShell);
//         },
//         branches: [
//           // Branch 1: Home và các sub-route
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/home',
//                 name: 'home',
//                 builder: (context, state) => const HomePage(),
//                 // Các route con của Home
//                 routes: [
//                   GoRoute(
//                     // Path với tham số bookId
//                     path: 'details/:bookId',
//                     name: 'bookDetails',
//                     builder: (context, state) {
//                       final bookId = state.pathParameters['bookId']!;
//                       return BookDetailsPage(bookId: bookId);
//                     },
//                   ),
//                   GoRoute(
//                     path: 'search',
//                     name: 'search',
//                     builder: (context, state) => const SearchPage(),
//                   ),
//                 ],
//               ),
//             ],
//           ),

//           // Branch 2: Creator
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/creator',
//                 name: 'creator',
//                 builder: (context, state) => const CreatorPage(),
//               ),
//             ],
//           ),
          
//           // Branch 3: Library
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: '/library',
          //       name: 'library',
          //       builder: (context, state) => const LibraryPage(),
          //     ),
          //   ],
          // ),

//           // Branch 4: Settings và các sub-route
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/settings',
//                 name: 'settings',
//                 builder: (context, state) => const SettingsPage(),
//                 routes: [
//                    GoRoute(
//                     path: 'profile',
//                     name: 'profileEdit',
//                     builder: (context, state) => const ProfileEditPage(),
//                   ),
//                 ]
//               ),
//             ],
//           ),
//         ],
//       ),
//     ],

//     refreshListenable: GoRouterRefreshStream(
//       di.getIt<AuthCubit>().stream,
//     ),

//     // THAY ĐỔI 3: Cập nhật logic redirect để xử lý Splash Screen
//     redirect: (BuildContext context, GoRouterState state) {
//       final authState = context.read<AuthCubit>().state;
//       final location = state.matchedLocation;

//       appLogger.i('redirect: AuthState: $authState, Location: $location');

//       final isLoading = authState is AuthLoading || authState is AuthInitial;
//       if (isLoading) {
//         // Nếu đang tải, cứ ở yên tại Splash Screen
//         return location == '/' ? null : '/';
//       }

//       final isLoggedIn = authState is AuthAuthenticated;
//       final isAtSplash = location == '/';
//       final isAtLogin = location == '/login';
      
//       // Nếu chưa đăng nhập và không ở trang Login -> chuyển về Login.
//       // Splash screen sẽ tự động chuyển hướng khi trạng thái auth thay đổi.
//       if (!isLoggedIn && !isAtLogin) {
//         return '/login';
//       }

//       // Nếu đã đăng nhập và đang ở trang Login hoặc Splash -> chuyển vào Home.
//       if (isLoggedIn && (isAtLogin || isAtSplash)) {
//         return '/home';
//       }

//       // Các trường hợp khác giữ nguyên.
//       return null;
//     },
//   );
// }

// // Giữ nguyên class này
// class GoRouterRefreshStream extends ChangeNotifier {
//   late final StreamSubscription<dynamic> _subscription;

//   GoRouterRefreshStream(Stream<dynamic> stream) {
//     appLogger.i('Khởi tạo GoRouterRefreshStream');
//     notifyListeners();
//     _subscription = stream.asBroadcastStream().listen((_) {
//       appLogger.i('GoRouterRefreshStream nhận sự kiện mới, thông báo listeners');
//       notifyListeners();
//     });
//   }

//   @override
//   void dispose() {
//     appLogger.i('Hủy GoRouterRefreshStream');
//     _subscription.cancel();
//     super.dispose();
//   }
// }