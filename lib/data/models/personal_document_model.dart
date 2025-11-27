// data/models/personal_document_model.dart

import 'package:audiobooks/domain/entities/personal_document_entity.dart';
import 'package:json_annotation/json_annotation.dart';

// Giả sử bạn đang dùng json_serializable
// Nếu không, bạn cần tự viết fromJson và toJson
part 'personal_document_model.g.dart';

@JsonSerializable(createFactory: false) 
// ========================================================================
class PersonalDocumentModel extends PersonalDocumentEntity {
  const PersonalDocumentModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.sourceType,
    required super.originalSource,
    super.extractedTextUrl,
    super.generatedAudioUrl,
    super.description,
    required super.status,
    required super.createdAt,
  });

  // ======================= THAY ĐỔI 2: VIẾT LẠI HOÀN TOÀN HÀM fromJson =======================
  // Chúng ta sẽ tự định nghĩa cách parse JSON, xử lý null và các kiểu enum.
  factory PersonalDocumentModel.fromJson(Map<String, dynamic> json) {
    return PersonalDocumentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      
      // Xử lý null an toàn cho các trường String?
      extractedTextUrl: json['extracted_text_url'] as String?,
      generatedAudioUrl: json['generated_audio_url'] as String?,
      description: json['description'] as String?,
      
      // Xử lý an toàn cho trường originalSource, nếu null thì trả về chuỗi rỗng
      originalSource: json['original_source'] as String? ?? '',

      // Xử lý enum từ chuỗi String
      sourceType: SourceType.values.firstWhere(
        (e) => e.name == json['source_type'],
        orElse: () => SourceType.file, // Giá trị mặc định nếu không khớp
      ),
      status: ProcessingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProcessingStatus.error, // Giá trị mặc định nếu không khớp
      ),

      // Parse ngày tháng
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  // =========================================================================================

  // Giữ nguyên hàm toJson. Build_runner sẽ tạo nó dựa trên constructor.
  Map<String, dynamic> toJson() => _$PersonalDocumentModelToJson(this);
}