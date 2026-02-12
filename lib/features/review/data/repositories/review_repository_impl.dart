import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/review/data/datasources/review_remote_datasource.dart';
import 'package:mobile_owner/features/review/domain/entities/paged_shop_reviews.dart';
import 'package:mobile_owner/features/review/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _remoteDataSource;

  ReviewRepositoryImpl({required ReviewRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, PagedShopReviews>> getShopReviews({
    required String shopId,
    required int page,
    required int size,
    required String sort,
  }) async {
    try {
      final result = await _remoteDataSource.getShopReviews(
        shopId: shopId,
        page: page,
        size: size,
        sort: sort,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message']?.toString() ?? '리뷰를 불러올 수 없습니다',
      ));
    }
  }
}
