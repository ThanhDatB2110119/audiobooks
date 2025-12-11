// presentation/features/search/cubit/search_cubit.dart

import 'dart:async';
import 'dart:ui';

import 'package:audiobooks/domain/usecases/search_books_usecase.dart';
import 'package:audiobooks/presentation/features/search/cubit/search_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class SearchCubit extends Cubit<SearchState> {
  final SearchBooksUsecase _searchBooksUsecase;
  // Dùng Debouncer để tránh gọi API liên tục khi người dùng đang gõ
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  SearchCubit(this._searchBooksUsecase) : super(const SearchState());

  void search(String query) {
    _debouncer.run(() async {
      if (query.trim().isEmpty) {
        emit(const SearchState(status: SearchStatus.initial));
        return;
      }

      emit(state.copyWith(status: SearchStatus.loading));
      final result = await _searchBooksUsecase(query);

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: SearchStatus.error,
            errorMessage: failure.message,
          ),
        ),
        (books) {
          if (books.isEmpty) {
            emit(state.copyWith(status: SearchStatus.empty));
          } else {
            emit(state.copyWith(status: SearchStatus.loaded, results: books));
          }
        },
      );
    });
  }
}

// Thêm class Debouncer vào cuối file hoặc trong một file utils
class Debouncer {
  final int milliseconds;
  Timer? _timer;
  Debouncer({required this.milliseconds});
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
