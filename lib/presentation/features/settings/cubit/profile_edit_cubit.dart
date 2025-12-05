// presentation/features/settings/cubit/profile_edit_cubit.dart

import 'dart:io';

import 'package:audiobooks/domain/entities/user_profile_entity.dart';
import 'package:audiobooks/domain/usecases/update_user_profile_usecase.dart';
import 'package:audiobooks/domain/usecases/upload_avatar_usecase.dart';
import 'package:audiobooks/presentation/features/settings/cubit/profile_edit_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileEditCubit extends Cubit<ProfileEditState> {
  final UpdateUserProfileUsecase _updateUserProfileUsecase;
  final UploadAvatarUsecase _uploadAvatarUsecase;

  ProfileEditCubit(this._updateUserProfileUsecase, this._uploadAvatarUsecase)
    : super(const ProfileEditState());

  void init(UserProfileEntity profile) {
    emit(state.copyWith(userProfile: profile));
  }

  void avatarSelected(File imageFile) {
    emit(state.copyWith(selectedAvatar: imageFile));
  }

  Future<void> saveChanges(String newFullName) async {
    emit(state.copyWith(status: ProfileEditStatus.loading));

    String? newAvatarUrl = state.userProfile?.avatarUrl;

    // 1. Nếu có ảnh mới được chọn, upload nó lên
    if (state.selectedAvatar != null) {
      final uploadResult = await _uploadAvatarUsecase(state.selectedAvatar!);
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

      // 3. Gọi usecase để cập nhật profile trong database
      final updateResult = await _updateUserProfileUsecase(updatedProfile);
      print('Update Profile Result: ${updateResult.isRight()}');
      updateResult.fold(
        (failure) {
          print('Update Profile FAILED: ${failure.message}');
          emit(
            state.copyWith(
              status: ProfileEditStatus.error,
              errorMessage: failure.message,
            ),
          );
        },
        (_) {
          emit(
            state.copyWith(
              status: ProfileEditStatus.success,
              userProfile: updatedProfile,
            ),
          );
        },
      );
    }
  }