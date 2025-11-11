import 'package:audiobooks/core/error/exceptions.dart';
import 'package:audiobooks/data/models/book_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> getBooks({String? categoryId});

  Future<BookModel> getBookById(String id);
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
      // ignore: avoid_print
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
}
