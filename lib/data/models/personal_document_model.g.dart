// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonalDocumentModel _$PersonalDocumentModelFromJson(
  Map<String, dynamic> json,
) => PersonalDocumentModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  title: json['title'] as String,
  sourceType: $enumDecode(_$SourceTypeEnumMap, json['source_type']),
  originalSource: json['original_source'] as String,
  extractedTextUrl: json['extracted_text_url'] as String?,
  generatedAudioUrl: json['generated_audio_url'] as String?,
  status: $enumDecode(_$ProcessingStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PersonalDocumentModelToJson(
  PersonalDocumentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': instance.title,
  'source_type': _$SourceTypeEnumMap[instance.sourceType]!,
  'original_source': instance.originalSource,
  'extracted_text_url': instance.extractedTextUrl,
  'generated_audio_url': instance.generatedAudioUrl,
  'status': _$ProcessingStatusEnumMap[instance.status]!,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$SourceTypeEnumMap = {
  SourceType.file: 'file',
  SourceType.url: 'url',
  SourceType.text: 'text',
};

const _$ProcessingStatusEnumMap = {
  ProcessingStatus.pending: 'pending',
  ProcessingStatus.processing: 'processing',
  ProcessingStatus.completed: 'completed',
  ProcessingStatus.error: 'error',
};
