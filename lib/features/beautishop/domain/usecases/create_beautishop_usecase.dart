import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/repositories/beautishop_repository.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

class CreateBeautishopUseCase
    extends UseCase<Either<Failure, BeautyShop>, CreateShopParams> {
  final BeautishopRepository repository;

  CreateBeautishopUseCase(this.repository);

  @override
  Future<Either<Failure, BeautyShop>> call(CreateShopParams params) {
    return repository.createShop(params);
  }
}
