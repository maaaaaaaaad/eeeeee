import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/repositories/beautishop_repository.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

class GetBeautishopUseCase
    extends UseCase<Either<Failure, BeautyShop>, String> {
  final BeautishopRepository repository;

  GetBeautishopUseCase(this.repository);

  @override
  Future<Either<Failure, BeautyShop>> call(String shopId) {
    return repository.getShop(shopId);
  }
}
