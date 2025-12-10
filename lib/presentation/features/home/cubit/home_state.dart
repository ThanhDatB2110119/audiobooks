import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/domain/entities/category_entity.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
   final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final List<BookEntity> books;
  const HomeLoaded(this.books, this.categories, this.selectedCategoryId);
  @override
  List<Object> get props => [books, categories, selectedCategoryId ?? ''];
HomeLoaded copyWith({
    List<BookEntity>? books,
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
  }) {
    return HomeLoaded(
      books ?? this.books,
      categories ?? this.categories,
      // Không dùng ?? ở đây, để có thể set về null
      selectedCategoryId,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object> get props => [message];
}