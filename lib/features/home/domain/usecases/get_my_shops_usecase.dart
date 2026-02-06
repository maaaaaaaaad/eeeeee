import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mobile_owner/features/home/domain/repositories/home_repository.dart';

class GetMyShopsUseCase
    extends UseCase<Either<Failure, List<BeautyShop>>, NoParams> {
  final HomeRepository repository;

  GetMyShopsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BeautyShop>>> call(NoParams params) {
    return repository.getMyShops();
  }
}
