import 'package:audiobooks/core/error/exceptions.dart';
import 'package:audiobooks/data/models/book_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> getBooks({String? categoryId});
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

    } catch (e) {
      // Ghi log lỗi ở đây
      throw ServerException('Failed to fetch books: $e');
    }
  }
}