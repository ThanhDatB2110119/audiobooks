import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String username;
  final String bio;
  final String avatarUrl;

  const UserProfileEntity({
    required this.id,
    required this.username,
    required this.bio,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, username, bio, avatarUrl];
}