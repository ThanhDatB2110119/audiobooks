import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/category_entity.dart';

part 'category_model.g.dart'; // File này sẽ được tạo bởi build_runner

@JsonSerializable(
  createToJson: false,
) // Chúng ta chỉ cần fromJson, không cần toJson
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    String? description,
  }) : super(description: "");

  // Ghi đè fromJson để đảm bảo an toàn kiểu dữ liệu
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(), // Đảm bảo ID luôn là String
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}
