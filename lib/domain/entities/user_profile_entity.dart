// domain/entities/user_profile_entity.dart
import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? preferredVoice;

  const UserProfileEntity({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.preferredVoice,
  });

  @override
  List<Object?> get props => [id, fullName, avatarUrl, preferredVoice];
}