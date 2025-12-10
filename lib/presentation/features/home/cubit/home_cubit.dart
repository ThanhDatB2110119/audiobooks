import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/domain/entities/category_entity.dart';
import 'package:audiobooks/domain/usecases/get_all_books_usecase.dart';
import 'package:audiobooks/domain/usecases/get_categories_usecase.dart';
import 'package:audiobooks/presentation/features/home/cubit/home_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final GetAllBooksUsecase _getAllBooksUsecase;
  final GetCategoriesUsecase _getCategoriesUsecase;
  HomeCubit(this._getAllBooksUsecase, this._getCategoriesUsecase)
    : super(HomeInitial());

  Future<void> fetchData() async {
    emit(HomeLoading());
    final results = await Future.wait([
      _getCategoriesUsecase(),
      _getAllBooksUsecase(), // Lấy tất cả sách ban đầu
    ]);

    if (isClosed) return;

    final categoriesResult =
        results[0] as Either<Failure, List<CategoryEntity>>;
    final booksResult = results[1] as Either<Failure, List<BookEntity>>;

    categoriesResult.fold((failure) => emit(HomeError(failure.message)), (
      categories,
    ) {
      booksResult.fold(
        (failure) => emit(HomeError(failure.message)),
        (books) => emit(
          HomeLoaded(
            books,
            categories,
            null, // Ban đầu không chọn thể loại nào
          ),
        ),
      );
    });
  }

  Future<void> filterByCategory(String? categoryId) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    // Cập nhật UI ngay lập tức để chip được chọn, và hiển thị loading cho danh sách sách
    emit(currentState.copyWith(selectedCategoryId: categoryId));
    // Có thể emit một state loading riêng cho sách nếu muốn

    // Gọi API để lấy danh sách sách đã lọc
    final booksResult = await _getAllBooksUsecase(categoryId: categoryId);

    if (isClosed) return;

    booksResult.fold(
      (failure) => emit(HomeError(failure.message)),
      // Cập nhật lại state với danh sách sách mới
      (books) => emit(
        currentState.copyWith(books: books, selectedCategoryId: categoryId),
      ),
    );
  }

  // =====================================================================
}
