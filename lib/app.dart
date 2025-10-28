import 'package:audiobooks/core/injection/injection_container.dart' as di;
import 'package:audiobooks/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:audiobooks/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<AuthCubit>(),
      child: MaterialApp.router(
        title: 'Audiobooks',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
