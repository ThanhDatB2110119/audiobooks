// presentation/features/library/cubit/library_state.dart

import 'dart:ui';

import 'package:audiobooks/domain/entities/book_entity.dart';
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
  final List<BookEntity> savedBooks;
  const LibraryLoaded({required this.myDocuments, required this.savedBooks});

  @override
  List<Object> get props => [myDocuments, savedBooks];
}

class LibraryError extends LibraryState {
  final String message;

  const LibraryError(this.message);

  @override
  List<Object> get props => [message];
}

class LibraryActionSuccess extends LibraryState {
  final String message;
  // Giữ lại danh sách hiện tại để UI không bị gián đoạn
  final List<PersonalDocumentEntity> currentDocuments;
  final List<BookEntity> currentSavedBooks;
  final VoidCallback? undoAction;
  const LibraryActionSuccess({
    required this.message,
    required this.currentDocuments,
    required this.currentSavedBooks,
    this.undoAction,
  });

  @override
  List<Object> get props => [message, currentDocuments, currentSavedBooks];
}
