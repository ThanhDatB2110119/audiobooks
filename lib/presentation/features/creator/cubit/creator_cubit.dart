// presentation/features/creator/cubit/creator_cubit.dart

import 'dart:io';

import 'package:audiobooks/domain/usecases/create_document_from_file_usecase.dart';
import 'package:audiobooks/domain/usecases/create_document_from_text_usecase.dart';
import 'package:audiobooks/presentation/features/creator/cubit/creator_state.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreatorCubit extends Cubit<CreatorState> {
  final CreateDocumentFromTextUsecase createDocumentFromTextUsecase;
  final CreateDocumentFromFileUsecase createDocumentFromFileUsecase;
  // ... inject các usecase khác sau này

  CreatorCubit(this.createDocumentFromTextUsecase, this.createDocumentFromFileUsecase) : super(CreatorInitial());

  Future<void> createFromText(String text) async {
    emit(CreatorLoading()); // Báo cho UI biết là đang xử lý

    final result = await createDocumentFromTextUsecase(text);

    result.fold(
      (failure) => emit(CreatorError(failure.message)), // Xử lý lỗi
      (_) => emit(CreatorSuccess("Yêu cầu của bạn đã được gửi đi và đang được xử lý!")), // Báo thành công
    );
  }
  Future<void> createFromFile(File file) async {
    emit(CreatorLoading());
    final result = await createDocumentFromFileUsecase(file);
    result.fold(
      (failure) => emit(CreatorError(failure.message)),
      (_) => emit(CreatorSuccess("File của bạn đã được gửi đi và đang được xử lý!")),
    );
  }
}