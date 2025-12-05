import 'dart:io';

import 'package:audiobooks/domain/entities/user_profile_entity.dart';
import 'package:equatable/equatable.dart';

enum ProfileEditStatus { initial, loading, success, error }

class ProfileEditState extends Equatable {
  final ProfileEditStatus status;
  final UserProfileEntity? userProfile;
  final File? selectedAvatar; // Lưu file ảnh người dùng đã chọn
  final String? errorMessage;

  const ProfileEditState({
    this.status = ProfileEditStatus.initial,
    this.userProfile,
    this.selectedAvatar,
    this.errorMessage,
  });
  
  ProfileEditState copyWith({
    ProfileEditStatus? status,
    UserProfileEntity? userProfile,
    File? selectedAvatar,
    String? errorMessage,
  }) {
    return ProfileEditState(
      status: status ?? this.status,
      userProfile: userProfile ?? this.userProfile,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, userProfile, selectedAvatar, errorMessage];
}