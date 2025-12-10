// domain/entities/book_part_entity.dart
import 'package:equatable/equatable.dart';

class BookPartEntity extends Equatable {
  final String id;
  final String bookId;
  final int partNumber;
  final String title;
  final String audioUrl;
  final int? durationSeconds;

  const BookPartEntity({
    required this.id,
    required this.bookId,
    required this.partNumber,
    required this.title,
    required this.audioUrl,
    this.durationSeconds,
  });

  @override
  List<Object?> get props => [id, bookId, partNumber, title, audioUrl, durationSeconds];
}