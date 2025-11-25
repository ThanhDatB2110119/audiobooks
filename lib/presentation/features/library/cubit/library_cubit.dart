// presentation/features/library/cubit/library_cubit.dart

import 'dart:async';

import 'package:audiobooks/domain/usecases/get_user_documents_usecase.dart';
import 'package:audiobooks/presentation/features/library/cubit/library_state.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@injectable
class LibraryCubit extends Cubit<LibraryState> {
  final GetUserDocumentsUsecase _getUserDocumentsUsecase;
  final SupabaseClient _supabaseClient;
  RealtimeChannel? _realtimeChannel;

  LibraryCubit(this._getUserDocumentsUsecase, this._supabaseClient)
    : super(LibraryInitial()) {
    _listenToDocumentChanges();
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
            fetchUserDocuments();
          },
        )
        .subscribe(); // Hàm subscribe() bây giờ được gọi ở cuối
  }

  @override
  Future<void> close() {
    // Rất quan trọng: Hủy subscription khi Cubit bị đóng để tránh rò rỉ bộ nhớ
    if (_realtimeChannel != null) {
      _supabaseClient.removeChannel(_realtimeChannel!);
      print('--- Realtime Channel Removed ---');
    }
    return super.close();
  }

  Future<void> fetchUserDocuments() async {
    if (state is! LibraryLoaded) {
      emit(LibraryLoading());
    }

    final result = await _getUserDocumentsUsecase();

    result.fold(
      (failure) => emit(LibraryError(failure.message)),
      (documents) => emit(LibraryLoaded(myDocuments: documents)),
    );
  }
}
