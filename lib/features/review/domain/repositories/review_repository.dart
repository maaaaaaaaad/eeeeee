import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/review/domain/entities/paged_shop_reviews.dart';

abstract class ReviewRepository {
  Future<Either<Failure, PagedShopReviews>> getShopReviews({
    required String shopId,
    required int page,
    required int size,
    required String sort,
  });
}
