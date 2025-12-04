// presentation/features/settings/pages/settings_page.dart

import 'package:audiobooks/presentation/features/settings/cubit/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:audiobooks/presentation/features/auth/widgets/sign_out_button.dart';
import 'package:audiobooks/presentation/features/settings/cubit/settings_cubit.dart';
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
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        (profile.avatarUrl != null &&
                            profile.avatarUrl!.isNotEmpty)
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child:
                        (profile.avatarUrl == null ||
                            profile.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 50)
                        : null,
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
                    onTap: () {
                      // context.push('/settings/profile-edit');
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
    // Danh sách các giọng đọc. Key là tên hiển thị, Value là ID mà Google TTS yêu cầu.
    final Map<String, String> voiceOptions = {
      'Giọng Nữ Miền Bắc (Chuẩn)': 'vi-VN-Standard-A',
      'Giọng Nam Miền Bắc (Chuẩn)': 'vi-VN-Standard-B',
      'Giọng Nữ Miền Nam (Chuẩn)': 'vi-VN-Standard-C',
      'Giọng Nam Miền Nam (Chuẩn)': 'vi-VN-Standard-D',
      'Giọng Nữ Cao Cấp (Wavenet)': 'vi-VN-Wavenet-A',
      'Giọng Nam Cao Cấp (Wavenet)': 'vi-VN-Wavenet-B',
    };

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Chọn giọng đọc',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...voiceOptions.entries.map((entry) {
              final displayName = entry.key;
              final voiceId = entry.value;
              final currentVoice = voiceId;

              return RadioListTile<String>(
                title: Text(displayName),
                value: voiceId,
                groupValue: currentVoice,
                onChanged: (newValue) {
                  if (newValue != null) {
                    context.read<SettingsCubit>().updatePreferredVoice(
                      newValue,
                    );
                    Navigator.of(sheetContext).pop();
                  }
                },
                activeColor: Theme.of(context).colorScheme.primary,
              );
            }),
          ],
        );
      },
    );
  }
}
