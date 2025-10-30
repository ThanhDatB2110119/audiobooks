import 'package:equatable/equatable.dart';

class BookEntity extends Equatable {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverImageUrl;
  final String categoryId;

  const BookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImageUrl,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    author,
    description,
    coverImageUrl,
    categoryId,
  ];
}
