// presentation/features/book_details/cubit/book_details_cubit.dart



import 'package:audiobooks/domain/usecases/get_book_details_usecase.dart';
import 'package:audiobooks/presentation/features/book_detail/cubit/book_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class BookDetailsCubit extends Cubit<BookDetailsState> {
  final GetBookDetailsUsecase getBookDetailsUsecase;

  BookDetailsCubit(this.getBookDetailsUsecase) : super(BookDetailsInitial());

  Future<void> fetchBookDetails(String id) async {
    emit(BookDetailsLoading());
    final failureOrBook = await getBookDetailsUsecase(id);
    failureOrBook.fold(
      (failure) => emit(const BookDetailsError('Không thể tải chi tiết sách.')),
      (book) => emit(BookDetailsLoaded(book)),
    );
  }
}