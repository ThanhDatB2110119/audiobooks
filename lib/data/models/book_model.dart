import 'package:audiobooks/domain/entities/book_entity.dart';
// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';
part 'book_model.g.dart'; 


@JsonSerializable()
class BookModel extends BookEntity {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.description,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'cover_image_url') required super.coverImageUrl,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'category_id') required super.categoryId,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) => _$BookModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookModelToJson(this);
}