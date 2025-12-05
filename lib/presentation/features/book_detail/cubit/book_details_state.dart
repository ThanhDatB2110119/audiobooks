// presentation/features/book_details/cubit/book_details_state.dart

import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:equatable/equatable.dart';

abstract class BookDetailsState extends Equatable {
  const BookDetailsState();

  @override
  List<Object> get props => [];
}

class BookDetailsInitial extends BookDetailsState {}

class BookDetailsLoading extends BookDetailsState {}

class BookDetailsLoaded extends BookDetailsState {
  final BookEntity book;
  final bool isSaved;
  const BookDetailsLoaded(this.book, {this.isSaved = false});

  @override
  List<Object> get props => [book, isSaved];
  BookDetailsLoaded copyWith({BookEntity? book, bool? isSaved}) {
    return BookDetailsLoaded(
      book ?? this.book,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class BookDetailsError extends BookDetailsState {
  final String message;

  const BookDetailsError(this.message);

  @override
  List<Object> get props => [message];
}
