// presentation/features/settings/pages/settings_page.dart

import 'package:audiobooks/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:audiobooks/presentation/features/settings/widgets/user_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:audiobooks/presentation/features/auth/widgets/sign_out_button.dart';
import 'package:audiobooks/presentation/features/settings/cubit/settings_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<SettingsCubit>()..loadUserProfile(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Cài đặt')),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              final profile = state.userProfile;
              return ListView(
                children: [
                  const SizedBox(height: 20),
                  // Phần thông tin user
                  Center(
                    child: UserProfileAvatar(
                      radius: 50,
                      imageUrl: profile.avatarUrl,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.fullName ?? 'Chưa có tên',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    // Lấy email từ user của Supabase, không có trong profile
                    GetIt.instance<SupabaseClient>().auth.currentUser?.email ??
                        '',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),

                  // Chức năng chọn giọng đọc
                  ListTile(
                    leading: const Icon(Icons.record_voice_over),
                    title: const Text('Giọng đọc ưa thích'),
                    subtitle: Text(
                      _getVoiceDisplayName(profile.preferredVoice),
                    ), // Dùng hàm helper để hiển thị tên
                    onTap: () {
                      // Truyền context có thể truy cập AuthCubit vào hàm
                      _showVoiceSelector(context, profile.preferredVoice);
                    },
                  ),

                  // Nút chỉnh sửa hồ sơ (sẽ làm sau)
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Chỉnh sửa hồ sơ'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.push('/settings/profile-edit');
                    },
                  ),

                  const Divider(),
                  const SizedBox(height: 40),

                  // Nút đăng xuất
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child:
                        SignOutButton(), // Tái sử dụng widget đăng xuất của bạn
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  String _getVoiceDisplayName(String? voiceId) {
    if (voiceId == null) return 'Mặc định';
    // Tìm key (tên hiển thị) dựa trên value (voiceId)
    return _voiceOptions.entries
        .firstWhere(
          (entry) => entry.value == voiceId,
          orElse: () => const MapEntry('Mặc định', ''),
        )
        .key;
  }

  static const Map<String, String> _voiceOptions = {
    'Giọng Nữ Miền Bắc (Chuẩn)': 'vi-VN-Standard-A',
    'Giọng Nam Miền Bắc (Chuẩn)': 'vi-VN-Standard-B',
    'Giọng Nữ Miền Nam (Chuẩn)': 'vi-VN-Standard-C',
    'Giọng Nam Miền Nam (Chuẩn)': 'vi-VN-Standard-D',
    'Giọng Nữ Cao Cấp (Wavenet)': 'vi-VN-Wavenet-A',
    'Giọng Nam Cao Cấp (Wavenet)': 'vi-VN-Wavenet-B',
  };

  // Hàm hiển thị bottom sheet chọn giọng đọc
  void _showVoiceSelector(BuildContext pageContext, String? currentVoice) {
    // pageContext là context của trang Settings, có thể truy cập AuthCubit

    showModalBottomSheet(
      context: pageContext,
      builder: (sheetContext) {
        // sheetContext là context của bottom sheet

        // Sử dụng BlocBuilder bên trong bottom sheet để nó tự cập nhật
        // khi người dùng chọn một giọng mới.
        return BlocBuilder<AuthCubit, AuthState>(
          // Chỉ build khi state là AuthAuthenticated
          buildWhen: (previous, current) => current is AuthAuthenticated,
          builder: (context, state) {
            // Lấy giá trị groupValue mới nhất từ state
            final String? currentSelectedVoice =
                (state as AuthAuthenticated).userProfile.preferredVoice;

            return ListView(
              shrinkWrap: true,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Chọn giọng đọc',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._voiceOptions.entries.map((entry) {
                  final displayName = entry.key;
                  final voiceId = entry.value;

                  return RadioListTile<String>(
                    title: Text(displayName),
                    value: voiceId,
                    groupValue: currentSelectedVoice, // Dùng giá trị từ state
                    onChanged: (newValue) {
                      if (newValue != null) {
                        // Gọi đến phương thức trong AuthCubit
                        pageContext.read<AuthCubit>().updatePreferredVoice(
                          newValue,
                        );
                        Navigator.of(context).pop();
                        // Không cần pop ở đây, UI sẽ tự cập nhật.
                        // Nếu muốn đóng ngay, có thể thêm Navigator.pop(sheetContext)
                      }
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }
}
