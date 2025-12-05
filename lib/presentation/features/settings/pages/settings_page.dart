// presentation/features/settings/pages/settings_page.dart

import 'package:audiobooks/presentation/features/settings/cubit/settings_state.dart';
import 'package:audiobooks/presentation/features/settings/widgets/user_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:audiobooks/presentation/features/auth/widgets/sign_out_button.dart';
import 'package:audiobooks/presentation/features/settings/cubit/settings_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<SettingsCubit>()..loadUserProfile(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Cài đặt')),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading || state is SettingsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SettingsError) {
              return Center(child: Text('Lỗi: ${state.message}'));
            }
            if (state is SettingsLoaded) {
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
                    subtitle: Text(profile.preferredVoice ?? 'Mặc định'),
                    onTap: () {
                      _showVoiceSelector(context, profile.preferredVoice);
                    },
                  ),

                  // Nút chỉnh sửa hồ sơ (sẽ làm sau)
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Chỉnh sửa hồ sơ'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final result = await context.push<bool>(
                        '/settings/profile-edit',
                        extra: state.userProfile,
                      );
                      if (result == true && context.mounted) {
                        context.read<SettingsCubit>().loadUserProfile();
                      }
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

  // Hàm hiển thị bottom sheet chọn giọng đọc
  void _showVoiceSelector(BuildContext context, String? currentVoice) {
    // Lấy Cubit từ context
    final settingsCubit = context.read<SettingsCubit>();

    // Danh sách các giọng đọc. Key là tên hiển thị, Value là ID mà Google TTS yêu cầu.
    final Map<String, String> voiceOptions = {
      'Giọng Nữ Miền Bắc (Chuẩn)': 'vi-VN-Standard-A',
      'Giọng Nam Miền Bắc (Chuẩn)': 'vi-VN-Standard-B',
      'Giọng Nữ Miền Nam (Chuẩn)': 'vi-VN-Standard-C',
      'Giọng Nam Miền Nam (Chuẩn)': 'vi-VN-Standard-D',
      'Giọng Nữ Cao Cấp (Wavenet)': 'vi-VN-Wavenet-A',
      'Giọng Nam Cao Cấp (Wavenet)': 'vi-VN-Wavenet-B',
    };

    // ======================= THAY ĐỔI: SỬ DỤNG BLOCBUILDER BÊN TRONG BOTTOMSHEET =======================
    // Điều này đảm bảo rằng mỗi khi state thay đổi (sau khi chọn giọng mới),
    // bottom sheet sẽ được rebuild lại với giá trị `groupValue` chính xác,
    // ngay cả khi nó chưa được đóng.
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return BlocBuilder<SettingsCubit, SettingsState>(
          // Chỉ định cubit đã được cung cấp ở trên
          bloc: settingsCubit,
          builder: (context, state) {
            // Lấy giá trị `preferredVoice` mới nhất từ state
            final String? activeVoice = (state is SettingsLoaded)
                ? state.userProfile.preferredVoice
                : currentVoice;

            return ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Text(
                    'Chọn giọng đọc',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                // Tạo các RadioListTile từ map
                ...voiceOptions.entries.map((entry) {
                  final displayName = entry.key;
                  final voiceId = entry.value;

                  return RadioListTile<String>(
                    title: Text(displayName),
                    // `value` là giá trị riêng của nút radio này
                    value: voiceId,
                    // `groupValue` là giá trị hiện tại của cả nhóm
                    // ignore: deprecated_member_use
                    groupValue: activeVoice,
                    // ignore: deprecated_member_use
                    onChanged: (newValue) {
                      if (newValue != null) {
                        // Gọi cubit để cập nhật giọng đọc
                        settingsCubit.updatePreferredVoice(newValue);
                        // Thêm một độ trễ nhỏ trước khi đóng để người dùng thấy được lựa chọn của mình
                        Future.delayed(const Duration(milliseconds: 250), () {
                          // ignore: use_build_context_synchronously
                          Navigator.of(sheetContext).pop();
                        });
                      }
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  );
                }),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }
}
