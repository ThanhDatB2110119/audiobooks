import 'package:audiobooks/domain/usecases/get_all_books_usecase.dart';
import 'package:audiobooks/presentation/features/home/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final GetAllBooksUsecase getAllBooksUsecase;

  HomeCubit(this.getAllBooksUsecase) : super(HomeInitial());

  Future<void> fetchBooks() async {
    emit(HomeLoading());
    final failureOrBooks = await getAllBooksUsecase();
    failureOrBooks.fold(
      (failure) => emit(HomeError('Failed to fetch books')),
      (books) => emit(HomeLoaded(books)),
    );
  }
}