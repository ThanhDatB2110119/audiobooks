// presentation/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/cubit/auth_cubit.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Tự động thêm nút back nếu cần
      automaticallyImplyLeading: false,
      // Đặt title ở giữa
      centerTitle: false,
      backgroundColor: Colors.white54,
      title: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final profile = state.userProfile;
            return Row(
              children: [
                GestureDetector(
                  // Nhấn vào để đi đến trang Settings
                  child: Row(
                    children: [
                      // Ảnh đại diện
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            (profile.avatarUrl != null &&
                                profile.avatarUrl!.isNotEmpty)
                            ? NetworkImage(profile.avatarUrl!)
                            : null,
                        child:
                            (profile.avatarUrl == null ||
                                profile.avatarUrl!.isEmpty)
                            ? const Icon(Icons.person, size: 24)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Tên người dùng
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.black54),
                          ),
                          Text(
                            profile.fullName ?? 'Người dùng',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  // Thêm padding bên trong để text không bị sát viền
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    // Màu nền đỏ
                    color: const Color.fromARGB(
                      255,
                      203,
                      14,
                      0,
                    ), // Hoặc một màu đỏ khác bạn thích
                    // Bo tròn các góc
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }
          // Fallback nếu chưa đăng nhập hoặc đang tải
          return Text(title);
        },
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
