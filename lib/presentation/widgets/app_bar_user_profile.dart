// presentation/widgets/app_bar_user_profile.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/cubit/auth_cubit.dart';

class AppBarUserProfile extends StatelessWidget {
  const AppBarUserProfile({super.key, required String title});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe AuthCubit để lấy thông tin user
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final profile = state.userProfile;
          return GestureDetector(
            // Nhấn vào để đi đến trang Settings
            onTap: () => context.go('/settings'),
            child: Row(
              children: [
                // Ảnh đại diện
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withOpacity(0.3), // Màu nền tạm thời
                  backgroundImage: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 24, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                // Tên người dùng
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chào mừng,',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                    Text(
                      profile.fullName ?? 'Người dùng',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        // Fallback nếu chưa đăng nhập
        return const SizedBox.shrink();
      },
    );
  }
}