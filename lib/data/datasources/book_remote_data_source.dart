import 'package:audiobooks/core/error/exceptions.dart';
import 'package:audiobooks/data/models/book_model.dart';
import 'package:audiobooks/data/models/book_part_model.dart';
import 'package:audiobooks/data/models/category_model.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> getBooks({String? categoryId});
  Future<List<CategoryModel>> getCategories();
  Future<BookModel> getBookById(String id);
  Future<bool> isBookSaved(String bookId);
  Future<List<BookPartModel>> getBookParts(String bookId);
  Future<void> addBookToLibrary(String bookId);
  Future<void> removeBookFromLibrary(String bookId);
  Future<List<BookModel>> getSavedBooks();
  Future<List<BookModel>> searchBooks(String query);
}

@LazySingleton(as: BookRemoteDataSource)
class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final SupabaseClient supabaseClient;

  BookRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<BookModel>> getBooks({String? categoryId}) async {
    try {
      // Xây dựng query
      var query = supabaseClient.from('books').select('*, categories(name)');
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query;

      return (response as List)
          .map((bookJson) => BookModel.fromJson(bookJson))
          .toList();
    } on PostgrestException catch (e, stackTrace) {
      debugPrint('========== SUPABASE ERROR ==========');
      debugPrint('Message: ${e.message}');
      debugPrint('Code: ${e.code}');
      debugPrint('Details: ${e.details}');
      debugPrint('Hint: ${e.hint}');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('====================================');
      throw ServerException('Failed to fetch books: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('========== UNEXPECTED ERROR ==========');
      debugPrint('Error: $e');
      debugPrint('Type: ${e.runtimeType}');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('======================================');
      throw ServerException('Failed to fetch books: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await supabaseClient
          .from('categories')
          .select()
          .order('name', ascending: true); // Sắp xếp theo tên

      return (response as List)
          .map((data) => CategoryModel.fromJson(data))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      // Supabase sử dụng 'plfts' (Postgres Full Text Search)
      // `(title,author)`: tìm trong cả 2 cột title và author
      // `'${query.trim()}:*'` : tìm kiếm các từ bắt đầu bằng query (prefix search)
      final response = await supabaseClient
          .from('books')
          .select('*, categories(name)')
          .textSearch(
            'fts',
            "'${query.trim()}:*'",
          ); // Giả sử cột fts đã được tạo

      return (response as List)
          .map((data) => BookModel.fromJson(data))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BookPartModel>> getBookParts(String bookId) async {
    try {
      final response = await supabaseClient
          .from('book_parts')
          .select()
          .eq('book_id', bookId)
          .order('part_number', ascending: true);
      return (response as List)
          .map((data) => BookPartModel.fromJson(data))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BookModel> getBookById(String id) async {
    try {
      final response = await supabaseClient
          .from('books')
          .select('*, categories(name)')
          .eq('id', id)
          .single();

      return BookModel.fromJson(response);
    } on PostgrestException catch (e, stackTrace) {
      debugPrint('========== SUPABASE ERROR ==========');
      debugPrint('Message: ${e.message}');
      debugPrint('Code: ${e.code}');
      debugPrint('Details: ${e.details}');
      debugPrint('Hint: ${e.hint}');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('====================================');
      throw ServerException('Failed to fetch book: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('========== UNEXPECTED ERROR ==========');
      debugPrint('Error: $e');
      debugPrint('Type: ${e.runtimeType}');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('======================================');
      throw ServerException('Failed to fetch book: $e');
    }
  }

  @override
  Future<bool> isBookSaved(String bookId) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return false;
    final response = await supabaseClient
        .from('user_library')
        .select('book_id')
        .eq('user_id', user.id)
        .eq('book_id', bookId)
        .limit(1);
    return response.isNotEmpty;
  }

  @override
  Future<void> addBookToLibrary(String bookId) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw ServerException('User not authenticated');
    await supabaseClient.from('user_library').insert({
      'user_id': user.id,
      'book_id': bookId,
    });
  }

  @override
  Future<void> removeBookFromLibrary(String bookId) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw ServerException('User not authenticated');
    await supabaseClient.from('user_library').delete().match({
      'user_id': user.id,
      'book_id': bookId,
    });
  }

  @override
  Future<List<BookModel>> getSavedBooks() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return [];

    // Query JOIN mạnh mẽ của Supabase
    final response = await supabaseClient
        .from('user_library')
        .select(
          'books(*, categories(name))',
        ) // Lấy tất cả thông tin từ bảng books liên quan
        .eq('user_id', user.id);

    return (response as List)
        .map((item) => BookModel.fromJson(item['books']))
        .toList();
  }
}
