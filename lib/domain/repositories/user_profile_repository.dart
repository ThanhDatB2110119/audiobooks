//
// Path: domain/repositories/user_profile_repository.dart

import 'dart:io';

import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/user_profile_entity.dart';
import 'package:dartz/dartz.dart';

/// Repository để quản lý thông tin hồ sơ và cài đặt của người dùng.
/// Nó tách biệt với AuthRepository, tập trung vào dữ liệu trong bảng 'profiles'.
abstract class UserProfileRepository {
  /// Lấy thông tin hồ sơ của người dùng đang đăng nhập.
  ///
  /// Thông tin này bao gồm tên, avatar, và các cài đặt cá nhân như giọng đọc yêu thích.
  ///
  /// Trả về [UserProfileEntity] nếu thành công,
  /// hoặc [Failure] nếu không tìm thấy hoặc có lỗi.
  Future<Either<Failure, UserProfileEntity>> getUserProfile();

  /// Cập nhật giọng đọc yêu thích cho người dùng hiện tại.
  ///
  /// [voiceId]: Một chuỗi định danh cho giọng đọc được chọn (ví dụ: 'google-vi-female-a').
  ///
  /// Trả về [void] nếu cập nhật thành công, hoặc [Failure] nếu có lỗi.
  // Future<Either<Failure, void>> updatePreferredVoice(String voiceId);

  /// Cập nhật các thông tin khác của hồ sơ người dùng.
  ///
  /// [fullName]: Tên đầy đủ mới của người dùng (tùy chọn).
  /// [avatarUrl]: URL ảnh đại diện mới (tùy chọn).
  ///
  /// Trả về [UserProfileEntity] đã được cập nhật nếu thành công, hoặc [Failure] nếu có lỗi.
  Future<Either<Failure, void>> updateUserProfile(UserProfileEntity profile);
  Future<Either<Failure, String>> uploadAvatar(File imageFile);
}
