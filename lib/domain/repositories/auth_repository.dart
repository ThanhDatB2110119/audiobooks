// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract class AuthRepository {
  Future<supabase.User?> signInWithGoogle();
  Future<void> signOut();
  supabase.User? get currentUser;
}
