import 'package:audiobooks/core/error/exceptions.dart';
import 'package:audiobooks/data/models/book_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> getBooks({String? categoryId});

  Future<BookModel> getBookById(String id);
  Future<bool> isBookSaved(String bookId);
  Future<void> addBookToLibrary(String bookId);
  Future<void> removeBookFromLibrary(String bookId);
  Future<List<BookModel>> getSavedBooks();
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
   
      print('========== SUPABASE ERROR ==========');
      print('Message: ${e.message}');
      print('Code: ${e.code}');
      print('Details: ${e.details}');
      print('Hint: ${e.hint}');
      print('StackTrace: $stackTrace');
      print('====================================');
      throw ServerException('Failed to fetch books: ${e.message}');
    } catch (e, stackTrace) {
      print('========== UNEXPECTED ERROR ==========');
      print('Error: $e');
      print('Type: ${e.runtimeType}');
      print('StackTrace: $stackTrace');
      print('======================================');
      throw ServerException('Failed to fetch books: $e');
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
      // ignore: avoid_print
      print('========== SUPABASE ERROR ==========');
      print('Message: ${e.message}');
      print('Code: ${e.code}');
      print('Details: ${e.details}');
      print('Hint: ${e.hint}');
      print('StackTrace: $stackTrace');
      print('====================================');
      throw ServerException('Failed to fetch book: ${e.message}');
    } catch (e, stackTrace) {
      print('========== UNEXPECTED ERROR ==========');
      print('Error: $e');
      print('Type: ${e.runtimeType}');
      print('StackTrace: $stackTrace');
      print('======================================');
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
    await supabaseClient.from('user_library').insert({'user_id': user.id, 'book_id': bookId});
  }

  @override
  Future<void> removeBookFromLibrary(String bookId) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw ServerException( 'User not authenticated');
    await supabaseClient.from('user_library').delete().match({'user_id': user.id, 'book_id': bookId});
  }

  @override
  Future<List<BookModel>> getSavedBooks() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return [];
    
    // Query JOIN mạnh mẽ của Supabase
    final response = await supabaseClient
        .from('user_library')
        .select('books(*, categories(name))') // Lấy tất cả thông tin từ bảng books liên quan
        .eq('user_id', user.id);

    return (response as List)
        .map((item) => BookModel.fromJson(item['books']))
        .toList();
  }
}
