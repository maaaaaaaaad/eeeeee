import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/repositories/beautishop_repository.dart';

class DeleteBeautishopUseCase extends UseCase<Either<Failure, void>, String> {
  final BeautishopRepository repository;

  DeleteBeautishopUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String shopId) {
    return repository.deleteShop(shopId);
  }
}
