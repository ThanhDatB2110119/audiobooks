// presentation/features/library/cubit/library_cubit.dart

import 'dart:async';

import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/core/event/library_events.dart';
import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/domain/entities/personal_document_entity.dart';
import 'package:audiobooks/domain/usecases/add_book_to_library_usecase.dart';
import 'package:audiobooks/domain/usecases/delete_document_usecase.dart';
import 'package:audiobooks/domain/usecases/get_saved_books_usecase.dart';
import 'package:audiobooks/domain/usecases/get_user_documents_usecase.dart';
import 'package:audiobooks/domain/usecases/remove_book_from_library_usecase.dart';
import 'package:audiobooks/presentation/features/library/cubit/library_state.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@injectable
class LibraryCubit extends Cubit<LibraryState> {
  final GetUserDocumentsUsecase _getUserDocumentsUsecase;
  final DeleteDocumentUsecase _deleteDocumentUsecase;
  final GetSavedBooksUsecase _getSavedBooksUsecase;
  final RemoveBookFromLibraryUsecase _removeBookFromLibraryUsecase;
  final AddBookToLibraryUsecase _addBookToLibraryUsecase;
  final LibraryEventBus _libraryEventBus;
  StreamSubscription? _libraryEventsSubscription;
  final SupabaseClient _supabaseClient;
  RealtimeChannel? _realtimeChannel;

  LibraryCubit(
    this._getUserDocumentsUsecase,
    this._deleteDocumentUsecase,
    this._getSavedBooksUsecase,
    this._removeBookFromLibraryUsecase,
    this._addBookToLibraryUsecase,
    this._libraryEventBus,
    this._supabaseClient,
  ) : super(LibraryInitial()) {
    _listenToDocumentChanges();
     _listenToLibraryEvents();
  }

  void _listenToDocumentChanges() {
    // Lấy user ID để chỉ lắng nghe thay đổi của chính người dùng này
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    _realtimeChannel = _supabaseClient
        .channel('public:personal_documents') // Chỉ cần tên bảng
        .onPostgresChanges(
          event: PostgresChangeEvent.all, // Tương đương với '*'
          schema: 'public',
          table: 'personal_documents',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          // Callback bây giờ nhận một PostgresChangePayload
          callback: (payload) {
            print(
              '--- Realtime Update Detected! Payload: ${payload.newRecord} ---',
            );
            // Khi có thay đổi, gọi lại hàm fetch dữ liệu
            fetchAllLibraryContent();
          },
        )
        .subscribe(); // Hàm subscribe() bây giờ được gọi ở cuối
  }

 void _listenToLibraryEvents() {
    _libraryEventsSubscription = _libraryEventBus.stream.listen((_) {
      print('--- Library Event Bus fired! Refetching all content... ---');
      // Khi nhận được sự kiện, gọi hàm fetch
      fetchAllLibraryContent();
    });
  }

  Future<void> deleteDocument(PersonalDocumentEntity document) async {
    // Lấy state hiện tại để có thể giữ lại danh sách trong khi chờ đợi
    final currentState = state;
    if (currentState is! LibraryLoaded) return; // Chỉ xóa khi đã có danh sách

    // 1. Lạc quan: Xóa item khỏi UI ngay lập tức để có phản hồi nhanh
    // Tạo một danh sách mới không chứa document cần xóa
    final optimisticList = List<PersonalDocumentEntity>.from(
      currentState.myDocuments,
    )..removeWhere((d) => d.id == document.id);

    // Cập nhật UI ngay với danh sách đã được lọc
    emit(
      LibraryLoaded(
        myDocuments: optimisticList,
        savedBooks: currentState.savedBooks,
      ),
    );

    // 2. Gọi API để xóa trên backend
    final result = await _deleteDocumentUsecase(document);

    result.fold(
      (failure) {
        // 3a. Nếu xóa thất bại:
        // - Hiển thị lỗi
        emit(LibraryError(failure.message));
        // - Khôi phục lại danh sách ban đầu để người dùng biết là đã thất bại
        emit(currentState);
      },
      (_) {
        // 3b. Nếu xóa thành công:
        // - Phát ra state thành công để hiển thị SnackBar
        emit(
          LibraryActionSuccess(
            message: 'Đã xóa thành công!',
            currentDocuments: optimisticList,
            currentSavedBooks: currentState.savedBooks, // Truyền danh sách mới
          ),
        );
        // - Giữ nguyên state LibraryLoaded với danh sách đã được lọc
        emit(
          LibraryLoaded(
            myDocuments: optimisticList,
            savedBooks: currentState.savedBooks,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    // Rất quan trọng: Hủy subscription khi Cubit bị đóng để tránh rò rỉ bộ nhớ
    if (_realtimeChannel != null) {
      _supabaseClient.removeChannel(_realtimeChannel!);
    }
    _libraryEventsSubscription?.cancel();
    print('--- Realtime Channel Removed ---');
    return super.close();
  }

  // Future<void> fetchUserDocuments() async {
  //   if (state is! LibraryLoaded) {
  //     emit(LibraryLoading());
  //   }

  //   final result = await _getUserDocumentsUsecase();

  //   result.fold(
  //     (failure) => emit(LibraryError(failure.message)),
  //     (documents) => emit(LibraryLoaded(myDocuments: documents)),
  //   );
  // }

  Future<void> fetchAllLibraryContent() async {
    if (state is! LibraryLoaded) {
      emit(LibraryLoading());
    }

    // Lấy cả hai danh sách song song
    final results = await Future.wait([
      _getUserDocumentsUsecase(),
      _getSavedBooksUsecase(),
    ]);
    if (isClosed) return;
    final myDocsResult =
        results[0] as Either<Failure, List<PersonalDocumentEntity>>;
    final savedBooksResult = results[1] as Either<Failure, List<BookEntity>>;

    // Xử lý kết quả
    myDocsResult.fold((failure) { if (!isClosed) emit(LibraryError(failure.message));
    },
     (myDocs,) {
      savedBooksResult.fold(
        (failure) { if (!isClosed) {
          emit(
          LibraryLoaded(myDocuments: myDocs, savedBooks: []));
        } 
          }, // Tạm thời trả về rỗng nếu lỗi
        (savedBooks) {
          if (!isClosed) {
            emit(LibraryLoaded(myDocuments: myDocs, savedBooks: savedBooks));
          }
        },
      );
    });
  }

  Future<void> removeSavedBook(BookEntity bookToRemove) async {
    final currentState = state;
    if (currentState is! LibraryLoaded) return;

    // 1. Lạc quan: Xóa sách khỏi danh sách UI ngay lập tức
    final optimisticList = List<BookEntity>.from(currentState.savedBooks)
      ..removeWhere((book) => book.id == bookToRemove.id);

    // Cập nhật UI với danh sách mới
    emit(LibraryLoaded(
      myDocuments: currentState.myDocuments,
      savedBooks: optimisticList,
    ));

    // 2. Gửi yêu cầu xóa đến backend
    final result = await _removeBookFromLibraryUsecase(bookToRemove.id.toString());

    result.fold(
      (failure) {
        // 3a. Nếu xóa thất bại:
        // - Hiển thị lỗi (BlocListener sẽ bắt)
        emit(LibraryError(failure.message));
        // - Khôi phục lại state cũ hoàn toàn
        emit(currentState);
      },
      (_) {
        // 3b. Nếu xóa thành công, phát ra state để hiển thị SnackBar
        emit(LibraryActionSuccess(
          message: 'Đã bỏ lưu "${bookToRemove.title}"',
          currentDocuments: currentState.myDocuments,
          currentSavedBooks: optimisticList,
          // Thêm một callback "Hoàn tác"
          undoAction: () => addSavedBook(bookToRemove),
        ));
        // Giữ nguyên state Loaded với danh sách đã cập nhật
        emit(LibraryLoaded(
            myDocuments: currentState.myDocuments, savedBooks: optimisticList));
      },
    );
  }

  /// (Hàm hỗ trợ cho Hoàn tác) Thêm lại một cuốn sách đã bỏ lưu
  Future<void> addSavedBook(BookEntity bookToAdd) async {
    final currentState = state;
    if (currentState is! LibraryLoaded) return;

    // Lạc quan: Thêm lại sách vào UI
    final optimisticList = List<BookEntity>.from(currentState.savedBooks)..add(bookToAdd);
    // Có thể sắp xếp lại danh sách ở đây nếu cần
    
    emit(LibraryLoaded(myDocuments: currentState.myDocuments, savedBooks: optimisticList));
    
    // Gọi API để thêm lại sách vào DB
    await _addBookToLibraryUsecase(bookToAdd.id.toString());
    // Không cần xử lý lỗi phức tạp cho hành động hoàn tác
  }
}
