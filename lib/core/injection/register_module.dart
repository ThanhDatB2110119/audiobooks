import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio();

   @preResolve
  Future<Supabase> get supabase async => await Supabase.initialize(
       url: 'https://hlajxecxlkegmeacnveg.supabase.co', 
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhsYWp4ZWN4bGtlZ21lYWNudmVnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzMDQwNDYsImV4cCI6MjA3NTg4MDA0Nn0.9SehXZiEekN1xxVO2Q48QSaYj4qLw4XEMCPcvcF-U7U",
  ); // <-- THAY BẰNG KEY CỦA BẠN
    

  // Injectable sẽ biết cách lấy SupabaseClient từ instance Supabase ở trên.
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  // Cung cấp instance của GoogleSignIn với cấu hình serverClientId.
  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn(
        // DÁN WEB CLIENT ID BẠN LẤY TỪ GOOGLE CLOUD CONSOLE VÀO ĐÂY
        serverClientId: '432156197463-ketob3jpn2lnqes1pp5lgmetoq5g95ti.apps.googleusercontent.com', // <-- CLIENT ID CỦA BẠN
      );
}
