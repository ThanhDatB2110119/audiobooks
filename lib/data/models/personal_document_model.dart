// data/models/personal_document_model.dart

import 'package:audiobooks/domain/entities/personal_document_entity.dart';
import 'package:json_annotation/json_annotation.dart';

// Giả sử bạn đang dùng json_serializable
// Nếu không, bạn cần tự viết fromJson và toJson
part 'personal_document_model.g.dart';

@JsonSerializable()
class PersonalDocumentModel extends PersonalDocumentEntity {
  const PersonalDocumentModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.sourceType,
    required super.originalSource,
    super.extractedTextUrl,
    super.generatedAudioUrl,
    required super.status,
    required super.createdAt,
  });
  factory PersonalDocumentModel.fromJson(Map<String, dynamic> json) =>
      _$PersonalDocumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalDocumentModelToJson(this);
}
