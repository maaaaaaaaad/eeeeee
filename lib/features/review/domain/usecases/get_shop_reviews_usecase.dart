import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/review/domain/entities/paged_shop_reviews.dart';
import 'package:mobile_owner/features/review/domain/repositories/review_repository.dart';

class GetShopReviewsUseCase
    extends UseCase<Either<Failure, PagedShopReviews>, GetShopReviewsParams> {
  final ReviewRepository repository;

  GetShopReviewsUseCase(this.repository);

  @override
  Future<Either<Failure, PagedShopReviews>> call(GetShopReviewsParams params) {
    return repository.getShopReviews(
      shopId: params.shopId,
      page: params.page,
      size: params.size,
      sort: params.sort,
    );
  }
}

class GetShopReviewsParams extends Equatable {
  final String shopId;
  final int page;
  final int size;
  final String sort;

  const GetShopReviewsParams({
    required this.shopId,
    this.page = 0,
    this.size = 20,
    this.sort = 'createdAt,desc',
  });

  @override
  List<Object?> get props => [shopId, page, size, sort];
}
