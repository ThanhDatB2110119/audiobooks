// import 'package:audiobooks/domain/entities/book_entity.dart';
// // ignore: depend_on_referenced_packages
// import 'package:json_annotation/json_annotation.dart';
// part 'book_model.g.dart';

// @JsonSerializable(createToJson: true)
// class BookModel extends BookEntity {
//   const BookModel({
//     required super.id,
//     required super.title,
//     required super.author,
//     required super.description,
//     // ignore: invalid_annotation_target
//     @JsonKey(name: 'cover_image_url') required super.coverImageUrl,
//     // ignore: invalid_annotation_target
//     @JsonKey(name: 'category_id') required super.categoryId,
//     required super.categoryName,
//   });

//   factory BookModel.fromJson(Map<String, dynamic> json) =>
//       _$BookModelFromJson(json);

//   Map<String, dynamic> toJson() => _$BookModelToJson(this);
// }

// data/models/book_model.dart

import 'package:audiobooks/domain/entities/book_entity.dart';
// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';
part 'book_model.g.dart';

// Annotation này vẫn cần thiết cho hàm toJson
@JsonSerializable(createFactory: false, explicitToJson: true)
class BookModel extends BookEntity {
  // Constructor được viết lại để rõ ràng hơn, nhưng về cơ bản vẫn giống của bạn
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.description,
    required super.coverImageUrl,
    required super.categoryId,
    required super.categoryName,
    required super.audioUrl,
  });

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

      // Lấy tên thể loại từ object lồng nhau 'categories'
      // (json['categories'] as Map<String, dynamic>?)?['name']
      //   -> Truy cập vào object 'categories'
      //   -> Dấu `?` để tránh lỗi nếu 'categories' là null
      //   -> Lấy giá trị của key 'name'
      // ?? 'Không rõ'
      //   -> Nếu kết quả cuối cùng là null, gán giá trị mặc định là 'Không rõ'
      categoryName:
          (json['categories'] as Map<String, dynamic>?)?['name'] as String? ??
          'Không rõ',
      audioUrl: json['content_text_url'] as String? ?? 'Null',
    );
  }

  // Hàm toJson vẫn sử dụng code được tạo tự động để tiện cho việc gửi dữ liệu đi sau này
  Map<String, dynamic> toJson() => _$BookModelToJson(this);
}
