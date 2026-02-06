import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/auth/domain/entities/owner.dart';
import 'package:mobile_owner/features/home/domain/repositories/home_repository.dart';

class GetMyProfileUseCase extends UseCase<Either<Failure, Owner>, NoParams> {
  final HomeRepository repository;

  GetMyProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Owner>> call(NoParams params) {
    return repository.getMyProfile();
  }
}
