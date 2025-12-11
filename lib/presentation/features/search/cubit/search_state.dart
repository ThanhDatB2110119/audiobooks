// presentation/features/search/cubit/search_state.dart


import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:equatable/equatable.dart';

enum SearchStatus { initial, loading, loaded, empty, error }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<BookEntity> results;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.results = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, results, errorMessage];

  SearchState copyWith({
    SearchStatus? status,
    List<BookEntity>? results,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}