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

  const BookDetailsLoaded(this.book);

  @override
  List<Object> get props => [book];
}

class BookDetailsError extends BookDetailsState {
  final String message;

  const BookDetailsError(this.message);

  @override
  List<Object> get props => [message];
}