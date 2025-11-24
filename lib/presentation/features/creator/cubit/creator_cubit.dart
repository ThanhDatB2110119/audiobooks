// presentation/features/creator/cubit/creator_cubit.dart

import 'package:audiobooks/domain/usecases/create_document_from_text_usecase.dart';
import 'package:audiobooks/presentation/features/creator/cubit/creator_state.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreatorCubit extends Cubit<CreatorState> {
  final CreateDocumentFromTextUsecase createDocumentFromTextUsecase;
  // ... inject các usecase khác sau này

  CreatorCubit(this.createDocumentFromTextUsecase) : super(CreatorInitial());

  Future<void> createFromText(String text) async {
    emit(CreatorLoading()); // Báo cho UI biết là đang xử lý

    final result = await createDocumentFromTextUsecase(text);

    result.fold(
      (failure) => emit(CreatorError(failure.message)), // Xử lý lỗi
      (_) => emit(CreatorSuccess("Yêu cầu của bạn đã được gửi đi và đang được xử lý!")), // Báo thành công
    );
  }
}