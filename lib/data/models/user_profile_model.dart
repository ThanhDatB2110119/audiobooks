// data/models/user_profile_model.dart

import 'package:audiobooks/domain/entities/user_profile_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_profile_model.g.dart';

@JsonSerializable(explicitToJson: true)
// ======================= THAY ĐỔI 1: SỬ DỤNG `implements` THAY VÌ `extends` =======================
class UserProfileModel implements UserProfileEntity {
// ==============================================================================================

  // ======================= THAY ĐỔI 2: KHAI BÁO CÁC TRƯỜNG VỚI `@override` VÀ `@JsonKey` =======================
  // Vì `implements`, chúng ta BẮT BUỘC phải định nghĩa lại tất cả các trường có trong UserProfileEntity.
  // Điều này cho phép chúng ta tự do thêm annotation.
  
  @override
  final String id;
  
  @override
  @JsonKey(name: 'full_name')
  final String? fullName;

  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  @override
  @JsonKey(name: 'preferred_voice')
  final String? preferredVoice;
  // ======================================================================================================

  // Constructor không cần gọi `super` nữa
  const UserProfileModel({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.preferredVoice,
  });

  // ======================= THAY ĐỔI 3: GHI ĐÈ `props` VÀ `stringify` =======================
  // Vì không còn kế thừa từ Equatable, chúng ta phải tự ghi đè `props`
  @override
  List<Object?> get props => [id, fullName, avatarUrl, preferredVoice];

  // Và cả thuộc tính `stringify` (thường là true)
  @override
  bool? get stringify => true;
  // ======================================================================================

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => _$UserProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);
  
  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      fullName: entity.fullName,
      avatarUrl: entity.avatarUrl,
      preferredVoice: entity.preferredVoice,
    );
  }
}