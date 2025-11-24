// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:just_audio/just_audio.dart' as _i501;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;
import 'package:uuid/uuid.dart' as _i706;

import '../../data/datasources/auth_remote_data_source.dart' as _i716;
import '../../data/datasources/book_remote_data_source.dart' as _i971;
import '../../data/datasources/personal_document_remote_data_source.dart'
    as _i992;
import '../../data/repositories/auth_repository_impl.dart' as _i895;
import '../../data/repositories/book_repository_impl.dart' as _i83;
import '../../data/repositories/mock_book_repository_impl.dart' as _i1005;
import '../../data/repositories/personal_document_repository_impl.dart'
    as _i422;
import '../../domain/repositories/auth_repository.dart' as _i1073;
import '../../domain/repositories/book_repository.dart' as _i135;
import '../../domain/repositories/personal_document_repository.dart' as _i538;
import '../../domain/usecases/create_document_from_text_usecase.dart' as _i631;
import '../../domain/usecases/get_all_books_usecase.dart' as _i813;
import '../../domain/usecases/get_book_details_usecase.dart' as _i494;
import '../../domain/usecases/google_sign_in_usecase.dart' as _i971;
import '../../domain/usecases/google_sign_out_usecase.dart' as _i514;
import '../../presentation/features/auth/cubit/auth_cubit.dart' as _i224;
import '../../presentation/features/book_detail/cubit/book_details_cubit.dart'
    as _i970;
import '../../presentation/features/creator/cubit/creator_cubit.dart' as _i2;
import '../../presentation/features/home/cubit/home_cubit.dart' as _i900;
import '../../presentation/features/player/cubit/player_cubit.dart' as _i949;
import 'register_module.dart' as _i291;

const String _dev = 'dev';
const String _prod = 'prod';

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final registerModule = _$RegisterModule();
  gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
  gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
  gh.lazySingleton<_i116.GoogleSignIn>(() => registerModule.googleSignIn);
  gh.lazySingleton<_i501.AudioPlayer>(() => registerModule.audioPlayer);
  gh.lazySingleton<_i706.Uuid>(() => registerModule.uuid);
  gh.lazySingleton<_i971.BookRemoteDataSource>(
    () => _i971.BookRemoteDataSourceImpl(gh<_i454.SupabaseClient>()),
  );
  gh.lazySingleton<_i992.PersonalDocumentRemoteDataSource>(
    () => _i992.PersonalDocumentRemoteDataSourceImpl(
      gh<_i454.SupabaseClient>(),
      gh<_i706.Uuid>(),
    ),
  );
  gh.lazySingleton<_i716.AuthRemoteDataSource>(
    () => _i716.AuthRemoteDataSourceImpl(
      supabaseClient: gh<_i454.SupabaseClient>(),
      googleSignIn: gh<_i116.GoogleSignIn>(),
    ),
  );
  gh.lazySingleton<_i135.BookRepository>(
    () => _i1005.MockBookRepositoryImpl(),
    registerFor: {_dev},
  );
  gh.lazySingleton<_i1073.AuthRepository>(
    () => _i895.AuthRepositoryImpl(
      remoteDataSource: gh<_i716.AuthRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i538.PersonalDocumentRepository>(
    () => _i422.PersonalDocumentRepositoryImpl(
      gh<_i992.PersonalDocumentRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i971.GoogleSignInUseCase>(
    () => _i971.GoogleSignInUseCase(gh<_i1073.AuthRepository>()),
  );
  gh.lazySingleton<_i514.GoogleSignOutUseCase>(
    () => _i514.GoogleSignOutUseCase(gh<_i1073.AuthRepository>()),
  );
  gh.lazySingleton<_i135.BookRepository>(
    () => _i83.BookRepositoryImpl(gh<_i971.BookRemoteDataSource>()),
    registerFor: {_prod},
  );
  gh.factory<_i949.PlayerCubit>(
    () => _i949.PlayerCubit(gh<_i501.AudioPlayer>()),
  );
  gh.lazySingleton<_i224.AuthCubit>(
    () => _i224.AuthCubit(
      gh<_i971.GoogleSignInUseCase>(),
      gh<_i514.GoogleSignOutUseCase>(),
    ),
  );
  gh.lazySingleton<_i813.GetAllBooksUsecase>(
    () => _i813.GetAllBooksUsecase(gh<_i135.BookRepository>()),
  );
  gh.lazySingleton<_i494.GetBookDetailsUsecase>(
    () => _i494.GetBookDetailsUsecase(gh<_i135.BookRepository>()),
  );
  gh.lazySingleton<_i631.CreateDocumentFromTextUsecase>(
    () => _i631.CreateDocumentFromTextUsecase(
      gh<_i538.PersonalDocumentRepository>(),
    ),
  );
  gh.factory<_i2.CreatorCubit>(
    () => _i2.CreatorCubit(gh<_i631.CreateDocumentFromTextUsecase>()),
  );
  gh.factory<_i970.BookDetailsCubit>(
    () => _i970.BookDetailsCubit(gh<_i494.GetBookDetailsUsecase>()),
  );
  gh.factory<_i900.HomeCubit>(
    () => _i900.HomeCubit(gh<_i813.GetAllBooksUsecase>()),
  );
  return getIt;
}

class _$RegisterModule extends _i291.RegisterModule {}
