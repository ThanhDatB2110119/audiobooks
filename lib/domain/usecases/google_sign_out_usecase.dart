import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart';

@lazySingleton
class GoogleSignOutUseCase {
  final AuthRepository repository;

  GoogleSignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}