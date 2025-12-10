import 'package:audiobooks/domain/entities/book_part_entity.dart';
import 'package:equatable/equatable.dart';

class BookEntity extends Equatable {
  final int id;
  final String title;
  final String author;
  final String description;
  final String coverImageUrl;
  final int categoryId;
  final String categoryName;
  final String? audioUrl;
  final List<BookPartEntity>? parts;


  const BookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImageUrl,
    required this.categoryId,
    required this.categoryName,
    this.audioUrl,
    this.parts = const [],
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
    parts,
  ];
BookEntity copyWith({
    int? id,
    String? title,
    String? author,
    String? description,
    String? coverImageUrl,
    int? categoryId,
    String? categoryName,
    String? audioUrl,
    List<BookPartEntity>? parts,
  }) {
    return BookEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
       audioUrl: audioUrl ?? this.audioUrl,
      parts: parts ?? this.parts, 
    
    );
  }
  
}
