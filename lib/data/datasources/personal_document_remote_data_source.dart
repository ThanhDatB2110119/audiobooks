// data/datasources/personal_document_remote_data_source.dart

import 'dart:io';
import 'package:audiobooks/data/models/personal_document_model.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/exceptions.dart';

abstract class PersonalDocumentRemoteDataSource {
  Future<List<PersonalDocumentModel>> getUserDocuments();
  // ======================= THÊM PHƯƠNG THỨC MỚI TẠI ĐÂY =======================
  Future<void> createDocumentFromText(String text);
  // ===========================================================================
}

@LazySingleton(as: PersonalDocumentRemoteDataSource)
class PersonalDocumentRemoteDataSourceImpl
    implements PersonalDocumentRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Uuid uuid; // Inject Uuid để dễ test

  PersonalDocumentRemoteDataSourceImpl(this.supabaseClient, this.uuid);

  @override
  Future<List<PersonalDocumentModel>> getUserDocuments() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        // Trả về danh sách rỗng nếu người dùng chưa đăng nhập
        return [];
      }

      final response = await supabaseClient
          .from('personal_documents')
          .select()
          .eq('user_id', user.id)
          .order(
            'created_at',
            ascending: false,
          ); // Sắp xếp theo ngày tạo mới nhất

      return (response as List)
          .map((data) => PersonalDocumentModel.fromJson(data))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> createDocumentFromText(String text) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw ServerException('Người dùng chưa đăng nhập');
      }

      // 1. Tạo file tạm thời từ chuỗi text
      final fileName = '${uuid.v4()}.txt';
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(text);

      // 2. Upload file text lên Supabase Storage
      final storagePath = '${user.id}/$fileName';
      await supabaseClient.storage
          .from('personal-texts')
          .upload(
            storagePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // 3. Lấy URL công khai của file vừa upload
      final textUrl = supabaseClient.storage
          .from('personal-texts')
          .getPublicUrl(storagePath);

      // 4. Dọn dẹp file tạm
      await file.delete();

      // 5. Chèn record mới vào bảng `personal_documents`
      // Tại sao lại dùng tiêu đề tạm thời?
      // Vì tiêu đề và mô tả sẽ do AI trên server tạo ra sau.
      // Client chỉ cần khởi tạo yêu cầu.
      final dataToInsert = {
        'user_id': user.id,
        'title': 'Đang xử lý tiêu đề...', // Tiêu đề tạm thời
        'source_type': 'file', // Coi text được dán vào là một loại file
        'original_source': 'Văn bản được dán vào lúc ${DateTime.now()}',
        'extracted_text_url': textUrl,
        'status': 'pending', // Trạng thái chờ xử lý
      };

      await supabaseClient.from('personal_documents').insert(dataToInsert);
    } catch (e) {
      // Ghi log lỗi ở đây
      throw ServerException(e.toString());
    }
  }
}
