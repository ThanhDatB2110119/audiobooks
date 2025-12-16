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
        title: 'Audiobooks',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
    // ==============================================================================================
  }
}
