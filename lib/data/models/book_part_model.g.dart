// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_part_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookPartModel _$BookPartModelFromJson(Map<String, dynamic> json) =>
    BookPartModel(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      partNumber: (json['partNumber'] as num).toInt(),
      title: json['title'] as String,
      audioUrl: json['audioUrl'] as String,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BookPartModelToJson(BookPartModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'partNumber': instance.partNumber,
      'title': instance.title,
      'audioUrl': instance.audioUrl,
      'durationSeconds': instance.durationSeconds,
    };
