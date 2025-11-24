// presentation/features/library/cubit/library_cubit.dart

import 'package:audiobooks/domain/usecases/get_user_documents_usecase.dart';
import 'package:audiobooks/presentation/features/library/cubit/library_state.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class LibraryCubit extends Cubit<LibraryState> {
  final GetUserDocumentsUsecase _getUserDocumentsUsecase;

  LibraryCubit(this._getUserDocumentsUsecase) : super(LibraryInitial());

  Future<void> fetchUserDocuments() async {
    emit(LibraryLoading());

    final result = await _getUserDocumentsUsecase();

    result.fold(
      (failure) => emit(LibraryError(failure.message)),
      (documents) => emit(LibraryLoaded(myDocuments: documents)),
    );
  }
}
