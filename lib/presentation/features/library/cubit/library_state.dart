// presentation/features/library/cubit/library_state.dart

import 'package:audiobooks/domain/entities/personal_document_entity.dart';
import 'package:equatable/equatable.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<PersonalDocumentEntity> myDocuments;
  // Sau này có thể thêm: final List<BookEntity> savedBooks;

  const LibraryLoaded({required this.myDocuments});

  @override
  List<Object> get props => [myDocuments];
}

class LibraryError extends LibraryState {
  final String message;

  const LibraryError(this.message);

  @override
  List<Object> get props => [message];
}
