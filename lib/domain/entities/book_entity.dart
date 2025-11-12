import 'package:equatable/equatable.dart';

class BookEntity extends Equatable {
  final int id;
  final String title;
  final String author;
  final String description;
  final String coverImageUrl;
  final int categoryId;
  final String categoryName;
  final String audioUrl;

  const BookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.audioUrl,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    author,
    description,
    coverImageUrl,
    categoryId,
    categoryName,
    audioUrl,
  ];
}
