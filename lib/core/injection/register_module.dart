// ignore_for_file: invalid_annotation_target

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:just_audio/just_audio.dart';

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
  @factory
  AudioPlayer get audioPlayer => AudioPlayer();
}
