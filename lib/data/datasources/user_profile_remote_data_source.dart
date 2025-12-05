// data/datasources/user_profile_remote_data_source.dart

import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audiobooks/core/error/exceptions.dart';
import 'package:audiobooks/data/models/user_profile_model.dart';
import 'package:uuid/uuid.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<void> updateUserProfile(UserProfileModel profile);
  Future<String> uploadAvatar(File imageFile);
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
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      // Tạo tên file duy nhất để tránh ghi đè
      final fileExtension = p.extension(imageFile.path);
      final fileName = '${const Uuid().v4()}$fileExtension';
      final filePath = '${user.id}/$fileName';

      // Upload file lên bucket 'avatars'
      // **QUAN TRỌNG**: Tạo bucket 'avatars' và thiết lập Policy cho phép
      // người dùng upload/update/select file trong thư mục của chính họ.
      // 1. Upload file
      final response = await supabaseClient.storage
          .from('avatars')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // 2. Lấy URL công khai SAU KHI upload hoàn tất
      // `response` chính là đường dẫn đã được upload thành công
      final String publicUrl = supabaseClient.storage
          .from('avatars')
          .getPublicUrl(
            filePath,
          ); // Sử dụng `response` trực tiếp từ kết quả upload
      print('Generated Public Avatar URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
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
      // ignore: avoid_print
      print('Updating profile with data: $dataToUpdate');
      final response = await supabaseClient
          .from('profiles')
          .update(dataToUpdate)
          .eq('id', user.id);
      print('Supabase update response (should be null on success): $response');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
