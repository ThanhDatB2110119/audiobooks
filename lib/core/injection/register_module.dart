// ignore_for_file: invalid_annotation_target

import 'package:audiobooks/core/router/app_router.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio();

   @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn(
    // WEB CLIENT ID bạn lấy từ Google Cloud Console
    serverClientId: '259713517157-fqf7486mgfq5vmdufm4hcf89kalot63l.apps.googleusercontent.com',
  );
  @lazySingleton
  AudioPlayer get audioPlayer => AudioPlayer();

  @lazySingleton
  Uuid get uuid => const Uuid();

  @lazySingleton
  GoRouter get goRouter => AppRouter.router;
}
