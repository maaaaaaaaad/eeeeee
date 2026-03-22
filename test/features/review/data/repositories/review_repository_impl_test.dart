import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/review/data/datasources/review_remote_datasource.dart';
import 'package:mobile_owner/features/review/data/models/paged_shop_reviews_model.dart';
import 'package:mobile_owner/features/review/data/models/shop_review_model.dart';
import 'package:mobile_owner/features/review/data/repositories/review_repository_impl.dart';

class MockReviewRemoteDataSource extends Mock
    implements ReviewRemoteDataSource {}

void main() {
  late MockReviewRemoteDataSource mockDataSource;
  late ReviewRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockReviewRemoteDataSource();
    repository = ReviewRepositoryImpl(remoteDataSource: mockDataSource);
  });

  final testModel = PagedShopReviewsModel(
    items: [
      ShopReviewModel(
        id: 'r-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        authorName: '홍길동',
        rating: 5,
        content: '좋아요',
        images: [],
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      ),
    ],
    hasNext: true,
    totalElements: 42,
  );

  group('getShopReviews', () {
    test('should return PagedShopReviews on success', () async {
      when(() => mockDataSource.getShopReviews(
            shopId: 'shop-1',
            page: 0,
            size: 20,
            sort: 'createdAt,desc',
          )).thenAnswer((_) async => testModel);

      final result = await repository.getShopReviews(
        shopId: 'shop-1',
        page: 0,
        size: 20,
        sort: 'createdAt,desc',
      );

      expect(result, Right(testModel));
    });

    test('should return ServerFailure on DioException', () async {
      when(() => mockDataSource.getShopReviews(
            shopId: any(named: 'shopId'),
            page: any(named: 'page'),
            size: any(named: 'size'),
            sort: any(named: 'sort'),
          )).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: ''),
          data: {'code': 'INTERNAL_SERVER_ERROR'},
        ),
      ));

      final result = await repository.getShopReviews(
        shopId: 'shop-1',
        page: 0,
        size: 20,
        sort: 'createdAt,desc',
      );

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요');
        },
        (_) => fail('should be left'),
      );
    });

    test('should return default error message when no message in response',
        () async {
      when(() => mockDataSource.getShopReviews(
            shopId: any(named: 'shopId'),
            page: any(named: 'page'),
            size: any(named: 'size'),
            sort: any(named: 'sort'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
      ));

      final result = await repository.getShopReviews(
        shopId: 'shop-1',
        page: 0,
        size: 20,
        sort: 'createdAt,desc',
      );

      result.fold(
        (failure) => expect(failure.message, '리뷰를 불러올 수 없습니다'),
        (_) => fail('should be left'),
      );
    });
  });

  group('replyToReview', () {
    test('should return Right on success', () async {
      when(() => mockDataSource.replyToReview(
            shopId: 'shop-1',
            reviewId: 'r-1',
            content: '감사합니다!',
          )).thenAnswer((_) async {});

      final result = await repository.replyToReview(
        shopId: 'shop-1',
        reviewId: 'r-1',
        content: '감사합니다!',
      );

      expect(result.isRight(), true);
    });

    test('should return ServerFailure on DioException', () async {
      when(() => mockDataSource.replyToReview(
            shopId: any(named: 'shopId'),
            reviewId: any(named: 'reviewId'),
            content: any(named: 'content'),
          )).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 403,
          requestOptions: RequestOptions(path: ''),
          data: {'code': 'UNAUTHORIZED_REVIEW_ACCESS'},
        ),
      ));

      final result = await repository.replyToReview(
        shopId: 'shop-1',
        reviewId: 'r-1',
        content: '감사합니다!',
      );

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, '해당 리뷰에 대한 권한이 없습니다');
        },
        (_) => fail('should be left'),
      );
    });

    test('should return default message when no message in response',
        () async {
      when(() => mockDataSource.replyToReview(
            shopId: any(named: 'shopId'),
            reviewId: any(named: 'reviewId'),
            content: any(named: 'content'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
      ));

      final result = await repository.replyToReview(
        shopId: 'shop-1',
        reviewId: 'r-1',
        content: '감사합니다!',
      );

      result.fold(
        (failure) => expect(failure.message, '답글을 등록할 수 없습니다'),
        (_) => fail('should be left'),
      );
    });
  });

  group('deleteReviewReply', () {
    test('should return Right on success', () async {
      when(() => mockDataSource.deleteReviewReply(
            shopId: 'shop-1',
            reviewId: 'r-1',
          )).thenAnswer((_) async {});

      final result = await repository.deleteReviewReply(
        shopId: 'shop-1',
        reviewId: 'r-1',
      );

      expect(result.isRight(), true);
    });

    test('should return ServerFailure on DioException', () async {
      when(() => mockDataSource.deleteReviewReply(
            shopId: any(named: 'shopId'),
            reviewId: any(named: 'reviewId'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
      ));

      final result = await repository.deleteReviewReply(
        shopId: 'shop-1',
        reviewId: 'r-1',
      );

      result.fold(
        (failure) => expect(failure.message, '답글을 삭제할 수 없습니다'),
        (_) => fail('should be left'),
      );
    });
  });
}
