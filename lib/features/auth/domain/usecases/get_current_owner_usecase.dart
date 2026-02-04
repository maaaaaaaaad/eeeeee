import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/auth/domain/entities/owner.dart';
import 'package:mobile_owner/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentOwnerUseCase extends UseCase<Either<Failure, Owner>, NoParams> {
  final AuthRepository repository;

  GetCurrentOwnerUseCase(this.repository);

  @override
  Future<Either<Failure, Owner>> call(NoParams params) {
    return repository.getCurrentOwner();
  }
}
