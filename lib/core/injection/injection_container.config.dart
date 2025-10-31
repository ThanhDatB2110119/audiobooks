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
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../data/datasources/auth_remote_data_source.dart' as _i716;
import '../../data/datasources/book_remote_data_source.dart' as _i971;
import '../../data/repositories/auth_repository_impl.dart' as _i895;
import '../../data/repositories/book_repository_impl.dart' as _i83;
import '../../data/repositories/mock_book_repository_impl.dart' as _i1005;
import '../../domain/repositories/auth_repository.dart' as _i1073;
import '../../domain/repositories/book_repository.dart' as _i135;
import '../../domain/usecases/get_all_books_usecase.dart' as _i813;
import '../../domain/usecases/google_sign_in_usecase.dart' as _i971;
import '../../domain/usecases/google_sign_out_usecase.dart' as _i514;
import '../../presentation/features/auth/cubit/auth_cubit.dart' as _i224;
import '../../presentation/features/home/cubit/home_cubit.dart' as _i900;
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
  gh.lazySingleton<_i971.BookRemoteDataSource>(
    () => _i971.BookRemoteDataSourceImpl(gh<_i454.SupabaseClient>()),
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
  gh.lazySingleton<_i224.AuthCubit>(
    () => _i224.AuthCubit(
      gh<_i971.GoogleSignInUseCase>(),
      gh<_i514.GoogleSignOutUseCase>(),
    ),
  );
  gh.lazySingleton<_i813.GetAllBooksUsecase>(
    () => _i813.GetAllBooksUsecase(gh<_i135.BookRepository>()),
  );
  gh.factory<_i900.HomeCubit>(
    () => _i900.HomeCubit(gh<_i813.GetAllBooksUsecase>()),
  );
  return getIt;
}

class _$RegisterModule extends _i291.RegisterModule {}
