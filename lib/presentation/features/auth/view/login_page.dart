import 'package:flutter/material.dart';
// Giả sử bạn có flutter_svg trong pubspec.yaml để hiển thị icon Google
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // PHẦN CHÍNH Ở GIỮA
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
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 60),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            // Phần logic đã được loại bỏ, thay bằng một hàm rỗng
                            onPressed: () {
                              print("Nút 'Tiếp tục với Google' được nhấn!");
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // PHẦN CHÂN TRANG
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    children: const [
                      TextSpan(text: 'Bằng cách đăng ký, bạn đồng ý với '),
                      TextSpan(
                        text: 'Điều khoản',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(text: ', '),
                      TextSpan(
                        text: 'Chính sách riêng tư',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(text: ' và '),
                      TextSpan(
                        text: 'Sử dụng cookie',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(text: ' của chúng tôi.'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
