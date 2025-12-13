// presentation/features/settings/pages/profile_edit_page.dart

import 'dart:io';
import 'package:audiobooks/presentation/features/settings/cubit/profile_edit_state.dart';
import 'package:audiobooks/presentation/features/settings/widgets/user_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audiobooks/domain/entities/user_profile_entity.dart';
import 'package:audiobooks/presentation/features/settings/cubit/profile_edit_cubit.dart';

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng một key riêng cho form để truy cập sau này
    final formKey = GlobalKey<FormState>();
    // Dùng một controller cục bộ
    final nameController = TextEditingController();

    return BlocProvider(
      create: (context) => GetIt.instance<ProfileEditCubit>()..init(),
      child: BlocConsumer<ProfileEditCubit, ProfileEditState>(
        // `listenWhen` ngăn listener chạy khi chỉ thay đổi ảnh (tránh lỗi không cần thiết)
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == ProfileEditStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật hồ sơ thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop(true);
          }
          if (state.status == ProfileEditStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        // `buildWhen` chỉ rebuild UI khi profile thay đổi, không rebuild khi status thay đổi
        buildWhen: (previous, current) =>
            previous.userProfile != current.userProfile ||
            previous.selectedAvatar != current.selectedAvatar,
        builder: (context, state) {
          final cubit = context.read<ProfileEditCubit>();

          // Gán giá trị ban đầu cho controller
          if (nameController.text.isEmpty &&
              state.userProfile?.fullName != null) {
            nameController.text = state.userProfile!.fullName!;
          }

          ImageProvider? backgroundImage;
          if (state.selectedAvatar != null) {
            backgroundImage = FileImage(state.selectedAvatar!);
          } else if (state.userProfile?.avatarUrl != null &&
              state.userProfile!.avatarUrl!.isNotEmpty) {
            backgroundImage = NetworkImage(state.userProfile!.avatarUrl!);
          }

          // Xử lý trạng thái ban đầu hoặc lỗi
          if (state.status == ProfileEditStatus.initial &&
              state.userProfile == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.status == ProfileEditStatus.error &&
              state.userProfile == null) {
            return Scaffold(
              body: Center(child: Text('Lỗi: ${state.errorMessage}')),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Chỉnh sửa hồ sơ'),
              actions: [
                // Chỉ hiển thị loading indicator bằng cách lắng nghe status
                BlocBuilder<ProfileEditCubit, ProfileEditState>(
                  buildWhen: (previous, current) =>
                      previous.status != current.status,
                  builder: (context, state) {
                    if (state.status == ProfileEditStatus.loading) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    return IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => cubit.saveChanges(nameController.text),
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          cubit.avatarSelected(File(image.path));
                        }
                      },
                      child: Stack(
                        children: [
                          UserProfileAvatar(
                            radius: 60,
                            imageFile: state.selectedAvatar,
                            imageUrl: state.userProfile?.avatarUrl,
                            imageProvider: backgroundImage,
                          ),
                          Transform.translate(
                            offset: const Offset(80, 80),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              child: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên hiển thị',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
//   @override
//   State<ProfileEditPage> createState() => _ProfileEditPageState();
// }

// class _ProfileEditPageState extends State<ProfileEditPage> {
//   late final TextEditingController _nameController;
//   final _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(
//       text: widget.initialProfile.fullName,
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage(ProfileEditCubit cubit) async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       cubit.avatarSelected(File(image.path));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           GetIt.instance<ProfileEditCubit>()..init(widget.initialProfile),
//       child: BlocConsumer<ProfileEditCubit, ProfileEditState>(
//         listener: (context, state) {
//           if (state.status == ProfileEditStatus.success) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Cập nhật hồ sơ thành công!'),
//                 backgroundColor: Colors.green,
//               ),
//             );
//             // Quay lại trang settings sau khi thành công
//             context.pop(true);
//           }
//           if (state.status == ProfileEditStatus.error) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Lỗi: ${state.errorMessage}'),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           final cubit = context.read<ProfileEditCubit>();
//           final isLoading = state.status == ProfileEditStatus.loading;

//           if (state.selectedAvatar != null) {
//           } else if (state.userProfile?.avatarUrl != null &&
//               state.userProfile!.avatarUrl!.isNotEmpty) {}

//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Chỉnh sửa hồ sơ'),
//               actions: [
//                 if (isLoading)
//                   const Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: CircularProgressIndicator(),
//                   )
//                 else
//                   IconButton(
//                     icon: const Icon(Icons.check),
//                     onPressed: () => cubit.saveChanges(_nameController.text),
//                   ),
//               ],
//             ),
//             body: SingleChildScrollView(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 children: [
//                   UserProfileAvatar(
//                     radius: 60,
//                     imageFile: state.selectedAvatar,
//                     imageUrl: state.userProfile?.avatarUrl,
//                     onTap: () => _pickImage(cubit),
//                   ),
//                   // Thêm icon chỉnh sửa bên ngoài nếu muốn
//                   Transform.translate(
//                     offset: const Offset(40, -40),
//                     child: CircleAvatar(
//                       radius: 18,
//                       backgroundColor: Theme.of(context).colorScheme.primary,
//                       child: const Icon(
//                         Icons.edit,
//                         size: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   // const SizedBox(height: 32),
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(
//                       labelText: 'Tên hiển thị',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
