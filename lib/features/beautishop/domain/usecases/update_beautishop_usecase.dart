import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/update_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/repositories/beautishop_repository.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

class UpdateBeautishopUseCase
    extends UseCase<Either<Failure, BeautyShop>, UpdateShopParams> {
  final BeautishopRepository repository;

  UpdateBeautishopUseCase(this.repository);

  @override
  Future<Either<Failure, BeautyShop>> call(UpdateShopParams params) {
    return repository.updateShop(params);
  }
}
