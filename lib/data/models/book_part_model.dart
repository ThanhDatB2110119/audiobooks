import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/book_part_entity.dart';

part 'book_part_model.g.dart';

@JsonSerializable(createToJson: true) 
class BookPartModel extends BookPartEntity {
  const BookPartModel({
    required super.id,
    required super.bookId,
     required super.partNumber,
    required super.title,
    required super.audioUrl,
     super.durationSeconds,
  });
  
 factory BookPartModel.fromJson(Map<String, dynamic> json) {
    return BookPartModel(
      id: json['id'].toString(),
      bookId: json['book_id'].toString(),
      partNumber: json['part_number'] as int,
      title: json['title'] as String,
      audioUrl: json['audio_url'] as String,
      durationSeconds: json['duration_seconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() => _$BookPartModelToJson(this);
}