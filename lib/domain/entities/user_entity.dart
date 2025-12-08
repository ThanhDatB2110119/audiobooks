import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? name;

  const UserEntity({required this.id, required this.email, this.name});


factory UserEntity.fromSupabaseUser(User supabaseUser) {
    return UserEntity(
      id: supabaseUser.id,
      email: supabaseUser.email,
      // Lấy tên từ user_metadata nếu có
      name: supabaseUser.userMetadata?['name'] as String?,
    );
  }
  @override
  List<Object?> get props => [id, email, name];
}
