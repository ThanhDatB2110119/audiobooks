// presentation/features/settings/cubit/profile_edit_cubit.dart

import 'dart:developer';
import 'dart:io';

import 'package:audiobooks/domain/entities/user_profile_entity.dart';
import 'package:audiobooks/domain/usecases/upload_avatar_usecase.dart';
import 'package:audiobooks/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:audiobooks/presentation/features/settings/cubit/profile_edit_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

@injectable
class ProfileEditCubit extends Cubit<ProfileEditState> {
  // final UpdateUserProfileUsecase _updateUserProfileUsecase;
  final AuthCubit _authCubit;
  final UploadAvatarUsecase _uploadAvatarUsecase;

  ProfileEditCubit(this._authCubit, this._uploadAvatarUsecase)
    : super(const ProfileEditState());

  void init() {
    final authState = _authCubit.state;
    if (authState is AuthAuthenticated) {
      emit(
        state.copyWith(
          status: ProfileEditStatus.initial,
          userProfile: authState.userProfile,
        ),
      );
    } else {
      // Xử lý trường hợp không tìm thấy profile (hiếm khi xảy ra)
      emit(
        state.copyWith(
          status: ProfileEditStatus.error,
          errorMessage: 'Không tìm thấy thông tin người dùng.',
        ),
      );
    }
  }

  void avatarSelected(File imageFile) {
    emit(state.copyWith(selectedAvatar: imageFile));
  }

  Future<File?> _compressImage(File file) async {
    try {
      // Đọc file ảnh vào bộ nhớ
      final image = img.decodeImage(await file.readAsBytes());
      if (image == null) return null;

      // Thay đổi kích thước ảnh, giữ nguyên tỷ lệ, với chiều rộng tối đa là 512px
      final resizedImage = img.copyResize(image, width: 512);

      // Lấy thư mục tạm để lưu file đã nén
      final tempDir = await getTemporaryDirectory();
      final compressedFilePath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = File(compressedFilePath);

      // Ghi dữ liệu ảnh đã nén (định dạng JPG với chất lượng 85%) vào file mới
      await compressedFile.writeAsBytes(
        img.encodeJpg(resizedImage, quality: 85),
      );

      return compressedFile;
    } catch (e) {
      log("Error compressing image: $e");
      return null;
    }
  }

  Future<void> saveChanges(String newFullName) async {
    final authState = _authCubit.state;
    if (authState is! AuthAuthenticated) {
      emit(
        state.copyWith(
          status: ProfileEditStatus.error,
          errorMessage: "Người dùng không hợp lệ",
        ),
      );
      return;
    }
    emit(state.copyWith(status: ProfileEditStatus.loading));

    String? newAvatarUrl = state.userProfile?.avatarUrl;

    // 1. Nếu có ảnh mới được chọn, upload nó lên
    if (state.selectedAvatar != null) {
      log("Compressing image...");
      final compressedImageFile = await _compressImage(state.selectedAvatar!);
      if (compressedImageFile == null) {
        emit(
          state.copyWith(
            status: ProfileEditStatus.error,
            errorMessage: "Không thể xử lý ảnh.",
          ),
        );
        return;
      }
      log("Image compressed successfully.");

      // 2. Upload ảnh đã nén
      final uploadResult = await _uploadAvatarUsecase(compressedImageFile);
      
      // ignore: avoid_print
      print('Upload Avatar Result: ${uploadResult.isRight()}');
      final success = uploadResult.fold(
        (failure) {
          emit(
            state.copyWith(
              status: ProfileEditStatus.error,
              errorMessage: failure.message,
            ),
          );
          return false;
        },
        (url) {
          newAvatarUrl = url;
          return true;
        },
      );
      if (!success) return; // Dừng lại nếu upload lỗi
    }

    // 2. Tạo đối tượng profile đã cập nhật
    final updatedProfile = UserProfileEntity(
      id: state.userProfile!.id,
      fullName: newFullName,
      avatarUrl: newAvatarUrl,
      preferredVoice: state.userProfile!.preferredVoice, // Giữ nguyên giọng đọc
    );
    final result = await _authCubit.updateUserProfile(updatedProfile);

    // Dựa vào kết quả để emit state cho ProfileEditPage
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileEditStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: ProfileEditStatus.success,
          userProfile: updatedProfile,
        ),
      ),
    );
  }
}
  // 3. Gọi usecase để cập nhật profile trong database
  //   final updateResult = await _updateUserProfileUsecase(updatedProfile);
  //   print('Update Profile Result: ${updateResult.isRight()}');
  //   updateResult.fold(
  //     (failure) {
  //       print('Update Profile FAILED: ${failure.message}');
  //       emit(
  //         state.copyWith(
  //           status: ProfileEditStatus.error,
  //           errorMessage: failure.message,
  //         ),
  //       );
  //     },
  //     (_) {
  //       emit(
  //         state.copyWith(
  //           status: ProfileEditStatus.success,
  //           userProfile: updatedProfile,
  //         ),
  //       );
  //     },
  //   );
  // }

  //   Future<File?> _compressImage(File file) async {
  //   try {
  //     // Đọc file ảnh vào bộ nhớ
  //     final image = img.decodeImage(await file.readAsBytes());
  //     if (image == null) return null;

  //     // Thay đổi kích thước ảnh, giữ nguyên tỷ lệ, với chiều rộng tối đa là 512px
  //     final resizedImage = img.copyResize(image, width: 512);

  //     // Lấy thư mục tạm để lưu file đã nén
  //     final tempDir = await getTemporaryDirectory();
  //     final compressedFilePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
  //     final compressedFile = File(compressedFilePath);

  //     // Ghi dữ liệu ảnh đã nén (định dạng JPG với chất lượng 85%) vào file mới
  //     await compressedFile.writeAsBytes(img.encodeJpg(resizedImage, quality: 85));

  //     return compressedFile;
  //   } catch (e) {
  //     print("Error compressing image: $e");
  //     return null;
  //   }
  // }

