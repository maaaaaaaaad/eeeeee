import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/review/domain/entities/paged_shop_reviews.dart';
import 'package:mobile_owner/features/review/domain/entities/shop_review.dart';
import 'package:mobile_owner/features/review/domain/repositories/review_repository.dart';
import 'package:mobile_owner/features/review/domain/usecases/get_shop_reviews_usecase.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late MockReviewRepository mockRepository;
  late GetShopReviewsUseCase useCase;

  setUp(() {
    mockRepository = MockReviewRepository();
    useCase = GetShopReviewsUseCase(mockRepository);
  });

  final pagedReviews = PagedShopReviews(
    items: [
      ShopReview(
        id: 'r-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        rating: 5,
        content: '좋아요',
        images: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    ],
    hasNext: true,
    totalElements: 42,
  );

  const params = GetShopReviewsParams(
    shopId: 'shop-1',
    page: 0,
    size: 20,
    sort: 'createdAt,desc',
  );

  test('should get paged reviews from repository', () async {
    when(() => mockRepository.getShopReviews(
          shopId: 'shop-1',
          page: 0,
          size: 20,
          sort: 'createdAt,desc',
        )).thenAnswer((_) async => Right(pagedReviews));

    final result = await useCase(params);

    expect(result, Right(pagedReviews));
    verify(() => mockRepository.getShopReviews(
          shopId: 'shop-1',
          page: 0,
          size: 20,
          sort: 'createdAt,desc',
        )).called(1);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.getShopReviews(
          shopId: any(named: 'shopId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          sort: any(named: 'sort'),
        )).thenAnswer((_) async => const Left(ServerFailure('리뷰를 불러올 수 없습니다')));

    final result = await useCase(params);

    expect(result.isLeft(), true);
  });

  test('should pass correct params to repository', () async {
    const customParams = GetShopReviewsParams(
      shopId: 'shop-2',
      page: 2,
      size: 10,
      sort: 'rating,desc',
    );

    when(() => mockRepository.getShopReviews(
          shopId: 'shop-2',
          page: 2,
          size: 10,
          sort: 'rating,desc',
        )).thenAnswer((_) async => Right(pagedReviews));

    await useCase(customParams);

    verify(() => mockRepository.getShopReviews(
          shopId: 'shop-2',
          page: 2,
          size: 10,
          sort: 'rating,desc',
        )).called(1);
  });
}
