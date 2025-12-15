// presentation/features/creator/cubit/creator_cubit.dart

import 'dart:async';
import 'dart:io';
import 'package:audiobooks/domain/entities/personal_document_entity.dart';
import 'package:audiobooks/domain/usecases/create_document_from_file_usecase.dart';
import 'package:audiobooks/domain/usecases/create_document_from_text_usecase.dart';
import 'package:audiobooks/domain/usecases/create_document_from_url_usecase.dart';
import 'package:audiobooks/domain/usecases/delete_document_usecase.dart';
import 'package:audiobooks/domain/usecases/get_user_documents_usecase.dart';
import 'package:audiobooks/presentation/features/creator/cubit/creator_state.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@injectable
class CreatorCubit extends Cubit<CreatorState> {
  final CreateDocumentFromTextUsecase createDocumentFromTextUsecase;
  final CreateDocumentFromFileUsecase createDocumentFromFileUsecase;
  final CreateDocumentFromUrlUsecase createDocumentFromUrlUsecase;
  final GetUserDocumentsUsecase _getUserDocumentsUsecase;
  final DeleteDocumentUsecase _deleteDocumentUsecase;
  final SupabaseClient _supabaseClient;
  StreamSubscription? _realtimeSubscription;
  // ... inject các usecase khác sau này

  CreatorCubit(
    this.createDocumentFromTextUsecase,
    this.createDocumentFromFileUsecase,
    this.createDocumentFromUrlUsecase,
    this._getUserDocumentsUsecase,
    this._supabaseClient,
    this._deleteDocumentUsecase,
  ) : super(CreatorInitial()) {
    fetchMostRecentDocument();
    // ======================= THAY ĐỔI LOGIC LẮNG NGHE =======================
    _listenToDocumentChanges();
  }

  Future<void> createFromText(String text) async {
    emit(CreatorLoading()); // Báo cho UI biết là đang xử lý

    final result = await createDocumentFromTextUsecase(text);

    result.fold(
      (failure) => emit(CreatorError(failure.message)), // Xử lý lỗi
      (_) {
        emit(
          CreatorSuccess("Yêu cầu của bạn đã được gửi đi và đang được xử lý!"),
        );
        fetchMostRecentDocument();
      }, // Báo thành công
    );
  }

  Future<void> deleteDocument(PersonalDocumentEntity document) async {
    final result = await _deleteDocumentUsecase(document);
    result.fold(
      (failure) {
        emit(CreatorError(failure.message));
        // Sau khi báo lỗi, fetch lại để đảm bảo UI đồng bộ
        fetchMostRecentDocument();
      },
      (_) {
        // Xóa thành công, không cần làm gì.
        // Realtime sẽ tự động trigger `fetchMostRecentDocument` để cập nhật UI.
        // Hoặc chúng ta có thể chủ động cập nhật để có phản hồi nhanh hơn:
        emit(const CreatorLoaded(mostRecentDocument: null)); // Tạm thời xóa khỏi UI
        fetchMostRecentDocument(); // Fetch lại để lấy sách gần nhất (nếu còn)
      },
    );
  }

  void _listenToDocumentChanges() {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    _realtimeSubscription = _supabaseClient
        .from('personal_documents') // 1. Chỉ định bảng
        .stream(
          primaryKey: ['id'],
        ) // 2. Lấy stream dữ liệu, chỉ định khóa chính
        .eq('user_id', userId) // 3. Lọc theo user_id
        .listen((List<Map<String, dynamic>> data) {
          // 4. `listen` sẽ trả về toàn bộ danh sách đã được lọc mỗi khi có thay đổi
          // ignore: avoid_print
          print(
            '--- CreatorCubit received Realtime Stream Update! Refetching... ---',
          );
          // Vì stream đã trả về dữ liệu mới, chúng ta có thể gọi lại fetch,
          // hoặc tối ưu hơn là trực tiếp xử lý `data` trả về.
          // Để đơn giản, chúng ta sẽ vẫn gọi fetch.
          fetchMostRecentDocument();
        });
        
  }

  Future<void> createFromFile(File file) async {
    emit(CreatorLoading());
    final result = await createDocumentFromFileUsecase(file);
    result.fold((failure) => emit(CreatorError(failure.message)), (_) {
      emit(CreatorSuccess("File của bạn đã được gửi đi và đang được xử lý!"));
      fetchMostRecentDocument();
    });
  }

  Future<void> fetchMostRecentDocument() async {
    final result = await _getUserDocumentsUsecase();
    result.fold((failure) => emit(CreatorError(failure.message)), (documents) {
      if (documents.isEmpty) {
        emit(const CreatorLoaded(mostRecentDocument: null));
      } else {
        // Danh sách đã được sắp xếp theo ngày tạo mới nhất từ DataSource
        emit(CreatorLoaded(mostRecentDocument: documents.first));
      }
    });
  }

  Future<void> createFromUrl(String url) async {
    emit(CreatorLoading());
    final result = await createDocumentFromUrlUsecase(url);
    result.fold((failure) => emit(CreatorError(failure.message)), (_) {
      emit(CreatorSuccess("Link của bạn đã được gửi đi và đang được xử lý!"));
      fetchMostRecentDocument();
    });
  }

  @override
  Future<void> close() {
    // ======================= HỦY SUBSCRIPTION MỚI =======================
    _realtimeSubscription?.cancel();
    // ====================================================================
    return super.close();
  }
}
