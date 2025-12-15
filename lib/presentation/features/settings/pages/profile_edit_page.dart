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

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // Quản lý controller và cubit trong state của widget
  late final TextEditingController _nameController;
  late final ProfileEditCubit _profileEditCubit;
  final _formKey = GlobalKey<FormState>(); // Dùng key này cho Form

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    // Khởi tạo Cubit và gọi `init` để tải dữ liệu ban đầu
    _profileEditCubit = GetIt.instance<ProfileEditCubit>()..init();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _profileEditCubit.close(); // Tự quản lý việc dọn dẹp Cubit
    super.dispose();
  }

  // Hàm helper để chọn ảnh
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _profileEditCubit.avatarSelected(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cung cấp instance cubit đã có cho cây widget con
    return BlocProvider.value(
      value: _profileEditCubit,
      child: BlocListener<ProfileEditCubit, ProfileEditState>(
        // Luôn lắng nghe để xử lý điều hướng và thông báo
        listener: (context, state) {
          if (state.status == ProfileEditStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật hồ sơ thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            // `context.pop(true)` sẽ trả về `true` cho trang trước đó nếu cần
            if (context.canPop()) {
              context.pop();
            }
          } else if (state.status == ProfileEditStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ProfileEditCubit, ProfileEditState>(
          builder: (context, state) {
            // Cập nhật giá trị của controller chỉ khi cần
            if (_nameController.text != state.userProfile?.fullName &&
                state.userProfile?.fullName != null) {
              _nameController.text = state.userProfile!.fullName!;
            }

            // Xử lý các trạng thái ban đầu hoặc lỗi trước khi build UI chính
            if (state.userProfile == null) {
              if (state.status == ProfileEditStatus.loading ||
                  state.status == ProfileEditStatus.initial) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (state.status == ProfileEditStatus.error) {
                return Scaffold(
                  body: Center(child: Text('Lỗi: ${state.errorMessage}')),
                );
              }
            }

            final isLoading = state.status == ProfileEditStatus.loading;
            ImageProvider? backgroundImage;
            if (state.selectedAvatar != null) {
              backgroundImage = FileImage(state.selectedAvatar!);
            } else if (state.userProfile?.avatarUrl != null &&
                state.userProfile!.avatarUrl!.isNotEmpty) {
              backgroundImage = NetworkImage(state.userProfile!.avatarUrl!);
            }

            // --- UI CHÍNH GIỮ NGUYÊN ---
            return Scaffold(
              appBar: AppBar(
                title: const Text('Chỉnh sửa hồ sơ'),
                actions: [
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () =>
                          _profileEditCubit.saveChanges(_nameController.text),
                    ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Giả sử UserProfileAvatar là một CircleAvatar
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: backgroundImage,
                              child: backgroundImage == null
                                  ? const Icon(Icons.person, size: 60)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
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
                        controller: _nameController,
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
