// presentation/features/book_details/cubit/book_details_cubit.dart

import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/core/event/library_events.dart';
import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/domain/entities/book_part_entity.dart';
import 'package:audiobooks/domain/usecases/add_book_to_library_usecase.dart';
import 'package:audiobooks/domain/usecases/check_book_saved_status_usecase.dart';
import 'package:audiobooks/domain/usecases/get_book_details_usecase.dart';
import 'package:audiobooks/domain/usecases/get_book_parts_usecase.dart';
import 'package:audiobooks/domain/usecases/remove_book_from_library_usecase.dart';
import 'package:audiobooks/presentation/features/book_detail/cubit/book_details_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class BookDetailsCubit extends Cubit<BookDetailsState> {
  final GetBookDetailsUsecase getBookDetailsUsecase;
  final CheckBookSavedStatusUsecase _checkBookSavedStatusUsecase;
  final AddBookToLibraryUsecase _addBookToLibraryUsecase;
  final GetBookPartsUsecase _getBookPartsUsecase;
  final RemoveBookFromLibraryUsecase _removeBookFromLibraryUsecase;
  final LibraryEventBus _libraryEventBus;
  BookDetailsCubit(
    this.getBookDetailsUsecase,
    this._checkBookSavedStatusUsecase,
    this._addBookToLibraryUsecase,
    this._removeBookFromLibraryUsecase,
    this._libraryEventBus,
    this._getBookPartsUsecase,
  ) : super(BookDetailsInitial());

  Future<void> fetchBookDetails(String id) async {
    emit(BookDetailsLoading());
    // Lấy thông tin sách và trạng thái lưu song song để nhanh hơn
    final results = await Future.wait([
      getBookDetailsUsecase(id),
      _checkBookSavedStatusUsecase(id),
      _getBookPartsUsecase(id),
    ]);

    if (isClosed) return;
    final bookResult = results[0] as Either<Failure, BookEntity>;
    final isSavedResult = results[1] as Either<Failure, bool>;
    final partsResult = results[2] as Either<Failure, List<BookPartEntity>>;

    await bookResult.fold(
      (failure) async => emit(BookDetailsError(failure.message)),
      (book) async {
        final isSaved = isSavedResult.getOrElse(() => false);
        final parts = partsResult.getOrElse(
          () => [],
        ); // Lấy parts hoặc danh sách rỗng nếu lỗi

        // Gộp thông tin sách và các phần của nó
        final bookWithParts = book.copyWith(parts: parts);
        emit(BookDetailsLoaded(bookWithParts, isSaved: isSaved));
      },
    );
  }

  Future<void> toggleSaveStatus() async {
    final currentState = state;
    if (currentState is! BookDetailsLoaded) return;

    // Lạc quan: Cập nhật UI ngay lập tức
    emit(currentState.copyWith(isSaved: !currentState.isSaved));

    final bookId = currentState.book.id;
    final isCurrentlySaved = currentState.isSaved;

    final Either<Failure, void> result;
    if (isCurrentlySaved) {
      // Nếu UI đang là "đã lưu", nghĩa là hành động là "bỏ lưu"
      result = await _removeBookFromLibraryUsecase(bookId.toString());
    } else {
      // Ngược lại, hành động là "lưu"
      result = await _addBookToLibraryUsecase(bookId.toString());
    }

    // Nếu có lỗi, rollback lại UI
    result.fold(
      (failure) => emit(currentState.copyWith(isSaved: isCurrentlySaved)),
      (_) {
        _libraryEventBus.fireLibraryChanged();
      }, // Thành công, không cần làm gì
    );
  }
}
