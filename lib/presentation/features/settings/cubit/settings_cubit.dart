// presentation/features/settings/cubit/settings_cubit.dart
import 'package:audiobooks/domain/entities/user_profile_entity.dart';
import 'package:audiobooks/domain/usecases/get_user_profile_usecase.dart';
import 'package:audiobooks/domain/usecases/update_user_profile_usecase.dart';
import 'package:audiobooks/presentation/features/settings/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';



@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final GetUserProfileUsecase _getUserProfileUsecase;
  final UpdateUserProfileUsecase _updateUserProfileUsecase;

  SettingsCubit(this._getUserProfileUsecase, this._updateUserProfileUsecase) : super(SettingsInitial());

  Future<void> loadUserProfile() async {
    emit(SettingsLoading());
    final result = await _getUserProfileUsecase();
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (profile) => emit(SettingsLoaded(profile)),
    );
  }

  Future<void> updatePreferredVoice(String voiceName) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    // Tạo một entity mới với giọng đọc đã được cập nhật
    final updatedProfile = UserProfileEntity(
      id: currentState.userProfile.id,
      fullName: currentState.userProfile.fullName,
      avatarUrl: currentState.userProfile.avatarUrl,
      preferredVoice: voiceName,
    );
    
    // Cập nhật UI ngay lập tức để có phản hồi nhanh
    emit(SettingsLoaded(updatedProfile));

    // Gọi API để lưu thay đổi
    final result = await _updateUserProfileUsecase(updatedProfile);
    result.fold(
      (failure) {
        // Nếu lỗi, rollback lại state cũ và báo lỗi
        emit(SettingsLoaded(currentState.userProfile));
        // Có thể emit thêm một state lỗi riêng để hiển thị SnackBar
        // emit(SettingsError('Cập nhật thất bại!'));
      },
      (_) {
        // Cập nhật thành công, không cần làm gì thêm
      },
    );
  }
}