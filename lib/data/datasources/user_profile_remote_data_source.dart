// data/datasources/user_profile_remote_data_source.dart

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audiobooks/core/error/exceptions.dart';
import 'package:audiobooks/data/models/user_profile_model.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<void> updateUserProfile(UserProfileModel profile);
}

@LazySingleton(as: UserProfileRemoteDataSource)
class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final SupabaseClient supabaseClient;

  UserProfileRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserProfileModel> getUserProfile() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        print(
          "Warning: Profile not found for user ${user.id}. Returning a default profile.",
        );
        // Tạo một đối tượng Model mặc định với ID của người dùng
        return UserProfileModel(id: user.id);
      }
      return UserProfileModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateUserProfile(UserProfileModel profile) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      // Chuyển model thành một Map JSON
      final dataToUpdate = profile.toJson();

      // Quan trọng: Xóa trường 'id' khỏi map vì chúng ta không cập nhật 'id'
      dataToUpdate.remove('id');

      // Chỉ update các trường có giá trị, không gửi đi các trường null
      // để tránh ghi đè dữ liệu không mong muốn
      dataToUpdate.removeWhere((key, value) => value == null);

      if (dataToUpdate.isEmpty) return; // Không có gì để update

      await supabaseClient
          .from('profiles')
          .update(dataToUpdate)
          .eq('id', user.id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
