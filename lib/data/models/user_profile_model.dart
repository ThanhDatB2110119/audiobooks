// data/models/user_profile_model.dart



import 'package:audiobooks/domain/entities/user_profile_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_profile_model.g.dart'; // Chạy build_runner để tạo file này

@JsonSerializable()
class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    super.fullName,
    super.avatarUrl,
    super.preferredVoice,
  });

  // Chuyển đổi từ JSON (dữ liệu nhận từ Supabase)
  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  // Chuyển đổi sang JSON (để gửi lên Supabase khi update)
  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  // Hàm helper để chuyển đổi từ một Entity (đối tượng logic) sang Model (đối tượng dữ liệu)
  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      fullName: entity.fullName,
      avatarUrl: entity.avatarUrl,
      preferredVoice: entity.preferredVoice,
    );
  }
}