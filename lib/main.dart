import 'package:audiobooks/core/injection/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:audiobooks/app.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  di.configureDependencies();

  // await Supabase.initialize(
  //   url: 'https://hlajxecxlkegmeacnveg.supabase.co', 
  //   anonKey:
  //       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhsYWp4ZWN4bGtlZ21lYWNudmVnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzMDQwNDYsImV4cCI6MjA3NTg4MDA0Nn0.9SehXZiEekN1xxVO2Q48QSaYj4qLw4XEMCPcvcF-U7U",
  // );
  runApp(const MyApp());
}
