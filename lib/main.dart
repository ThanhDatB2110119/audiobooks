import 'package:flutter/material.dart';
import 'package:audiobooks/app.dart';
import 'package:audiobooks/core/injection/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();

  runApp(const MyApp());
}
