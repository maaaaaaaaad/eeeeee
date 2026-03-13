import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/repositories/beautishop_repository.dart';

class CheckRegNumUseCase extends UseCase<Either<Failure, void>, String> {
  final BeautishopRepository repository;

  CheckRegNumUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String regNum) {
    return repository.checkRegNum(regNum);
  }
}
