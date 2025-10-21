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
import 'package:injectable/injectable.dart' as _i526;

import '../../data/datasources/auth_remote_data_source.dart' as _i716;
import '../../data/repositories/auth_repository_impl.dart' as _i895;
import '../../domain/repositories/auth_repository.dart' as _i1073;
import '../../presentation/bloc/auth_bloc/auth_bloc.dart' as _i125;
import 'register_module.dart' as _i291;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final registerModule = _$RegisterModule();
  gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
  gh.lazySingleton<_i716.AuthRemoteDataSource>(
    () => _i716.AuthRemoteDataSourceImpl(),
  );
  gh.lazySingleton<_i1073.AuthRepository>(
    () => _i895.AuthRepositoryImpl(gh<_i716.AuthRemoteDataSource>()),
  );
  gh.factory<_i125.AuthCubit>(
    () => _i125.AuthCubit(gh<_i1073.AuthRepository>()),
  );
  return getIt;
}

class _$RegisterModule extends _i291.RegisterModule {}
