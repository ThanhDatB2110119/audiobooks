import 'package:audiobooks/presentation/bloc/auth_bloc/auth_bloc.dart';
// import 'package:audiobooks/presentation/features/home/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Giả sử bạn có flutter_svg trong pubspec.yaml để hiển thị icon Google
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     // Sử dụng BlocConsumer để vừa lắng nghe thay đổi (listener) vừa xây dựng lại UI (builder)
//     return BlocConsumer<AuthCubit, AuthState>(
//       // listener: Dùng để thực hiện các hành động một lần như hiển thị SnackBar, điều hướng.
//       // Nó không build lại widget.
//       listener: (context, state) {
//         state.whenOrNull(
//           // Khi có lỗi, hiển thị một SnackBar
//           error: (message) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           },
//           // Lưu ý: Việc điều hướng khi đăng nhập thành công đã được AuthWrapper
//           // trong main.dart xử lý. Chúng ta không cần xử lý ở đây để tránh xung đột.
//         );
//       },
//       // builder: Dùng để xây dựng lại UI dựa trên trạng thái hiện tại của BLoC.
//       builder: (context, state) {
//         // Kiểm tra xem có đang ở trạng thái loading hay không
//         final isLoading = state.maybeWhen(
//           loading: () => true,
//           orElse: () => false,
//         );

//         return Scaffold(
//           // Đặt màu nền ở đây để phù hợp với theme của bạn nếu cần
//           // backgroundColor: Colors.black, 
//           body: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               child: Column(
//                 children: [
//                   // PHẦN CHÍNH Ở GIỮA
//                   Expanded(
//                     child: Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const SizedBox(height: 40),
//                           Text(
//                             'Chia sẻ khoảnh khắc hằng ngày cùng với người thân và bạn bè.',
//                             textAlign: TextAlign.center,
//                             style: theme.textTheme.titleLarge?.copyWith(
//                               // Đổi màu để dễ nhìn hơn trên nền sáng mặc định
//                               color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 60),
//                           SizedBox(
//                             width: double.infinity,
//                             height: 50,
//                             // Nếu đang loading, hiển thị vòng tròn tiến trình.
//                             // Nếu không, hiển thị nút đăng nhập.
//                             child: isLoading
//                                 ? const Center(child: CircularProgressIndicator())
//                                 : OutlinedButton.icon(
//                                     // Khi nhấn nút, gọi sự kiện đăng nhập từ AuthCubit
//                                     onPressed: () {
//                                       context.read<AuthCubit>().signInWithGoogle();
//                                     },
//                                     icon: SvgPicture.asset(
//                                       'assets/icons/google icon.svg', // Đảm bảo bạn có file này trong thư mục assets
//                                       height: 24,
//                                     ),
//                                     label: const Text('Tiếp tục với Google'),
//                                     style: OutlinedButton.styleFrom(
//                                       backgroundColor: Colors.white,
//                                       foregroundColor: Colors.black87,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                       side: const BorderSide(color: Colors.grey),
//                                     ),
//                                   ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // PHẦN CHÂN TRANG (Giữ nguyên)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 20.0),
//                     child: RichText(
//                       textAlign: TextAlign.center,
//                       text: TextSpan(
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: (theme.brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.7),
//                           fontSize: 12,
//                         ),
//                         children: [
//                           const TextSpan(text: 'Bằng cách đăng ký, bạn đồng ý với '),
//                           TextSpan(
//                             text: 'Điều khoản',
//                             style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
//                           ),
//                           const TextSpan(text: ', '),
//                           TextSpan(
//                             text: 'Chính sách riêng tư',
//                             style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
//                           ),
//                           const TextSpan(text: ' và '),
//                           TextSpan(
//                             text: 'Sử dụng cookie',
//                             style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
//                           ),
//                           const TextSpan(text: ' của chúng tôi.'),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // THAY ĐỔI 2: Sử dụng BlocConsumer<AuthBloc, AuthState>
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          // KHI THÀNH CÔNG: Hiển thị SnackBar chào mừng và/hoặc điều hướng
          authenticated: (user) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome, ${user.name ?? user.email}!'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/home');
          },
          // KHI LỖI: Hiển thị SnackBar lỗi
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

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
                                    // THAY ĐỔI 3: Gửi một Event thay vì gọi một hàm
                                    onPressed: () {
                                      context.read<AuthBloc>().add(const AuthEvent.googleSignInRequested());
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
                      // ... phần RichText của bạn (không thay đổi) ...
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