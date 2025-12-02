// data/datasources/personal_document_remote_data_source.dart

import 'dart:io';
import 'package:audiobooks/data/models/personal_document_model.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/exceptions.dart';
import 'package:audiobooks/domain/entities/personal_document_entity.dart';
import 'package:path/path.dart' as p;

abstract class PersonalDocumentRemoteDataSource {
  Future<List<PersonalDocumentModel>> getUserDocuments();
  // ======================= THÊM PHƯƠNG THỨC MỚI TẠI ĐÂY =======================
  Future<void> createDocumentFromText(String text);
  Future<void> createDocumentFromFile(File file);
  Future<void> deleteDocument(PersonalDocumentEntity document);
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
  @override
  Future<void> createDocumentFromFile(File file) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw ServerException('Người dùng chưa đăng nhập');

      // 1. Chuẩn bị tên file và đường dẫn
      final originalFileName = p.basename(file.path);
      final fileExtension = p.extension(file.path);
      final uniqueFileName = '${uuid.v4()}$fileExtension';
      final storagePath = '${user.id}/$uniqueFileName';
      
      // 2. Upload file gốc lên bucket 'personal-files-uploads'
      // **QUAN TRỌNG**: Bạn cần tạo một bucket mới tên là `personal-files-uploads`
      // và thiết lập Policy cho nó giống như cách bạn đã làm với `personal-texts`.
      await supabaseClient.storage.from('personal-files-uploads').upload(
            storagePath,
            file,
          );

      // 3. Lấy URL công khai của file vừa upload
      final fileUrl = supabaseClient.storage.from('personal-files-uploads').getPublicUrl(storagePath);
      
      // 4. Chèn record mới vào bảng `personal_documents`
      final dataToInsert = {
        'user_id': user.id,
        'title': 'Đang xử lý file: $originalFileName',
        'source_type': 'file',
        // Lưu URL của file gốc vào extracted_text_url để server xử lý
        'original_source': originalFileName, 
        'extracted_text_url': fileUrl,
        'status': 'pending',
      };

      await supabaseClient.from('personal_documents').insert(dataToInsert);

    } catch (e) {
      throw ServerException(e.toString());
    }
  }
  @override
  Future<void> deleteDocument(PersonalDocumentEntity document) async {
    try {
      final List<String> pathsToDelete = [];

      // Hàm helper để tách đường dẫn file từ URL đầy đủ
      String? getPathFromUrl(String? url, String bucketName) {
        if (url == null || !url.contains('/$bucketName/')) return null;
        return url.split('/$bucketName/')[1];
      }

      // 1. Lấy đường dẫn của file text/pdf/docx gốc
      final originalFilePath = getPathFromUrl(document.extractedTextUrl, 
          document.sourceType == SourceType.text ? 'personal-texts' : 'personal-files-uploads');
      if (originalFilePath != null) {
        pathsToDelete.add(originalFilePath);
      }
      
      // 2. Lấy đường dẫn của file audio đã tạo
      final audioFilePath = getPathFromUrl(document.generatedAudioUrl, 'personal-audios');
      if (audioFilePath != null) {
        pathsToDelete.add(audioFilePath);
      }

      // 3. Xóa các file trên Storage (nếu có)
      // Chúng ta sẽ xóa file từ cả 3 bucket để đảm bảo an toàn
      if (pathsToDelete.isNotEmpty) {
        print('Deleting files from storage: $pathsToDelete');
        // Supabase cho phép xóa nhiều file cùng lúc trong MỘT bucket
        // Chúng ta cần gọi riêng cho từng loại bucket
        final textPath = pathsToDelete.firstWhere((p) => p.contains('.txt') || p.contains('.pdf') || p.contains('.docx'), orElse: () => '');
        final audioPath = pathsToDelete.firstWhere((p) => p.contains('.mp3'), orElse: () => '');

        if(textPath.isNotEmpty) {
           final bucketName = document.sourceType == SourceType.text ? 'personal-texts' : 'personal-uploads';
           await supabaseClient.storage.from(bucketName).remove([textPath]);
        }
        if(audioPath.isNotEmpty) {
           await supabaseClient.storage.from('personal-audios').remove([audioPath]);
        }
      }

      // 4. Sau khi xóa file thành công, xóa record trong database
      await supabaseClient
          .from('personal_documents')
          .delete()
          .eq('id', document.id);

    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
