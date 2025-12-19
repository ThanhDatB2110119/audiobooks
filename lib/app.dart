// app.dart

import 'package:audiobooks/core/injection/injection_container.dart' as di;
import 'package:audiobooks/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:audiobooks/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';

// ======================= THÊM IMPORT MỚI =======================
import 'package:audiobooks/presentation/features/player/cubit/player_cubit.dart';
// ===============================================================

class MyApp extends StatelessWidget {
  // Giữ nguyên tên widget của bạn
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ======================= THAY ĐỔI TỪ BLOCPROVIDER SANG MULTIBLOCPROVIDER =======================
    // MultiBlocProvider cho phép chúng ta cung cấp nhiều Cubit/Bloc cùng một lúc.
    return MultiBlocProvider(
      providers: [
        // Provider cho AuthCubit (giống như cũ)
        BlocProvider(create: (context) => di.getIt<AuthCubit>()),

        // Provider mới cho PlayerCubit
        BlocProvider(
          create: (context) => di.getIt<PlayerCubit>(),
          // `lazy: false` rất quan trọng. Nó đảm bảo PlayerCubit được tạo ngay khi
          // ứng dụng khởi động. Điều này cần thiết để nó có thể lắng nghe các
          // stream từ AudioPlayer và duy trì trạng thái ngay cả khi PlayerPage chưa được mở.
          lazy: false,
        ),
      ],
      child: MaterialApp.router(
        title: 'Audiobook',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,

        // builder: (context, child) {
        //   return BlocListener<AuthCubit, AuthState>(
        //     listenWhen: (previous, current) {
        //       // Chỉ lắng nghe khi trạng thái xác thực thay đổi (ví dụ: từ unauthenticated -> authenticated)
        //       // hoặc từ authenticated -> unauthenticated.
        //       // Bỏ qua các thay đổi từ authenticated -> authenticated (như khi cập nhật profile).
        //       return (previous is! AuthAuthenticated &&
        //               current is AuthAuthenticated) ||
        //           (previous is AuthAuthenticated &&
        //               current is! AuthAuthenticated);
        //     },
        //     listener: (context, state) {
        //       final router = AppRouter.router;
        //       if (state is AuthAuthenticated) {
        //         // Nếu đã xác thực, đi đến trang home
        //         print(
        //           "--- Auth Listener: Authenticated. Navigating to /home ---",
        //         );
        //         router.go('/home');
        //       } else if (state is AuthUnauthenticated) {
        //         // Nếu chưa xác thực, đi đến trang login
        //         print(
        //           "--- Auth Listener: Unauthenticated. Navigating to /login ---",
        //         );
        //         router.go('/login');
        //       }
        //     },
        //     // `child` ở đây chính là các trang do GoRouter render
        //     child: child,
        //   );
        // },
      ),
    );
    // ==============================================================================================
  }
}
