// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$PersonalDocumentModelToJson(
  PersonalDocumentModel instance,
) => <String, dynamic>{
  'stringify': instance.stringify,
  'hashCode': instance.hashCode,
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'sourceType': _$SourceTypeEnumMap[instance.sourceType]!,
  'originalSource': instance.originalSource,
  'extractedTextUrl': instance.extractedTextUrl,
  'generatedAudioUrl': instance.generatedAudioUrl,
  'description': instance.description,
  'status': _$ProcessingStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'props': instance.props,
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
