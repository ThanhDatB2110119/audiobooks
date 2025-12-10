// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookModel _$BookModelFromJson(Map<String, dynamic> json) => BookModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  author: json['author'] as String,
  description: json['description'] as String,
  coverImageUrl: json['coverImageUrl'] as String,
  categoryId: (json['categoryId'] as num).toInt(),
  categoryName: json['categoryName'] as String,
  parts: (json['parts'] as List<dynamic>)
      .map((e) => BookPartModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BookModelToJson(BookModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'author': instance.author,
  'description': instance.description,
  'coverImageUrl': instance.coverImageUrl,
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'parts': instance.parts.map((e) => e.toJson()).toList(),
};
