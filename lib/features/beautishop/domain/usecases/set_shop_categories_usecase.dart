import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/repositories/beautishop_repository.dart';

class SetShopCategoriesUseCase
    extends UseCase<Either<Failure, void>, SetShopCategoriesParams> {
  final BeautishopRepository repository;

  SetShopCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SetShopCategoriesParams params) {
    return repository.setShopCategories(params.shopId, params.categoryIds);
  }
}

class SetShopCategoriesParams extends Equatable {
  final String shopId;
  final List<String> categoryIds;

  const SetShopCategoriesParams({
    required this.shopId,
    required this.categoryIds,
  });

  @override
  List<Object?> get props => [shopId, categoryIds];
}
