// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonalDocumentModel _$PersonalDocumentModelFromJson(
  Map<String, dynamic> json,
) => PersonalDocumentModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  sourceType: $enumDecode(_$SourceTypeEnumMap, json['sourceType']),
  originalSource: json['originalSource'] as String,
  extractedTextUrl: json['extractedTextUrl'] as String?,
  generatedAudioUrl: json['generatedAudioUrl'] as String?,
  status: $enumDecode(_$ProcessingStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PersonalDocumentModelToJson(
  PersonalDocumentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'sourceType': _$SourceTypeEnumMap[instance.sourceType]!,
  'originalSource': instance.originalSource,
  'extractedTextUrl': instance.extractedTextUrl,
  'generatedAudioUrl': instance.generatedAudioUrl,
  'status': _$ProcessingStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
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
