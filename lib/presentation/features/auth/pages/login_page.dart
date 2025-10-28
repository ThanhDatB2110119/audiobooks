// import 'package:audiobooks/presentation/features/home/pages/home_page.dart';
import 'package:audiobooks/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Giả sử bạn có flutter_svg trong pubspec.yaml để hiển thị icon Google
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';



class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, ${user.name ?? user.email}!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home');
        }
      },
      builder: (context, state) {
        bool isLoading;
        if (state is AuthLoading) {
          isLoading = true;
        } else {
          isLoading = false;
        }

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            'Chia sẻ khoảnh khắc hằng ngày cùng với người thân và bạn bè.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 60),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : OutlinedButton.icon(
                                    onPressed: () {
                                      context.read<AuthCubit>().googleSignInRequested();
                                    },
                                    icon: SvgPicture.asset(
                                      'assets/icons/google icon.svg',
                                      height: 24,
                                    ),
                                    label: const Text('Tiếp tục với Google'),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black87,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      side: const BorderSide(color: Colors.grey),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: (theme.brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.7),
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(text: 'Bằng cách đăng ký, bạn đồng ý với '),
                          TextSpan(
                            text: 'Điều khoản',
                            style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                          ),
                          const TextSpan(text: ', '),
                          TextSpan(
                            text: 'Chính sách riêng tư',
                            style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                          ),
                          const TextSpan(text: ' và '),
                          TextSpan(
                            text: 'Sử dụng cookie',
                            style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                          ),
                          const TextSpan(text: ' của chúng tôi.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
