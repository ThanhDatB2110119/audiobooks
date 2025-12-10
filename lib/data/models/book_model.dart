
import 'package:audiobooks/data/models/book_part_model.dart';
import 'package:audiobooks/domain/entities/book_entity.dart';
// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';
part 'book_model.g.dart';

// Annotation này vẫn cần thiết cho hàm toJson
@JsonSerializable(explicitToJson: true)
class BookModel extends BookEntity {

  @override
  final List<BookPartModel> parts;
  // Constructor được viết lại để rõ ràng hơn, nhưng về cơ bản vẫn giống của bạn
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.description,
    required super.coverImageUrl,
    required super.categoryId,
    required super.categoryName,
     required this.parts,
  }) : super(
          parts: parts ,
          audioUrl: null,
        );
  // ========================================================================
  // THAY ĐỔI QUAN TRỌNG NHẤT: VIẾT LẠI HOÀN TOÀN factory fromJson
  // Chúng ta sẽ không dùng _$BookModelFromJson nữa.
  // ========================================================================
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      // Lấy các giá trị từ cấp cao nhất của JSON
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String? ?? 'Không rõ', // Thêm xử lý null
      description: json['description'] as String? ?? '', // Thêm xử lý null
      coverImageUrl: json['cover_image_url'] as String,
      categoryId: json['category_id'] as int,
      categoryName: (json['categories'] as Map<String, dynamic>?)?['name'] as String? ?? 'Không rõ',
      parts: const []
    );
  }


factory BookModel.fromEntity(BookEntity entity) {
    return BookModel(
      id: entity.id,
      title: entity.title,
      author: entity.author,
      description: entity.description,
      coverImageUrl: entity.coverImageUrl,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      parts: entity.parts!.map((part) => BookPartModel( // Chuyển đổi
        id: part.id,
        bookId: part.bookId,
        partNumber: part.partNumber,
        title: part.title,
        audioUrl: part.audioUrl,
        durationSeconds: part.durationSeconds,
      )).toList(),
    );
  }
  // Hàm toJson vẫn sử dụng code được tạo tự động để tiện cho việc gửi dữ liệu đi sau này
  Map<String, dynamic> toJson() => _$BookModelToJson(this);
}
