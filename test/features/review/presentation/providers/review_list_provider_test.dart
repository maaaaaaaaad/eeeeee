import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/review/domain/entities/paged_shop_reviews.dart';
import 'package:mobile_owner/features/review/domain/entities/shop_review.dart';
import 'package:mobile_owner/features/review/domain/usecases/get_shop_reviews_usecase.dart';
import 'package:mobile_owner/features/review/presentation/providers/review_list_provider.dart';
import 'package:mobile_owner/features/review/presentation/providers/review_provider.dart';

class MockGetShopReviewsUseCase extends Mock
    implements GetShopReviewsUseCase {}

void main() {
  late MockGetShopReviewsUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetShopReviewsUseCase();
  });

  setUpAll(() {
    registerFallbackValue(const GetShopReviewsParams(shopId: ''));
  });

  final reviews = [
    ShopReview(
      id: 'r-1',
      shopId: 'shop-1',
      memberId: 'member-1',
      authorName: '홍길동',
      rating: 5,
      content: '좋아요',
      images: [],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    ShopReview(
      id: 'r-2',
      shopId: 'shop-1',
      memberId: 'member-2',
      rating: 3,
      images: [],
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
    ),
  ];

  final pagedReviews = PagedShopReviews(
    items: reviews,
    hasNext: true,
    totalElements: 42,
  );

  final lastPageReviews = PagedShopReviews(
    items: [reviews[0]],
    hasNext: false,
    totalElements: 42,
  );

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getShopReviewsUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
  }

  group('ReviewListNotifier', () {
    test('initial state should be initial status', () {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(pagedReviews));

      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(reviewListNotifierProvider('shop-1'));
      expect(state.status, ReviewListStatus.initial);
      expect(state.reviews, isEmpty);
      expect(state.hasNext, false);
      expect(state.currentPage, 0);
      expect(state.totalElements, 0);
      expect(state.sortType, ReviewSortType.latestFirst);
    });

    test('should load reviews successfully', () async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(pagedReviews));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reviewListNotifierProvider('shop-1').notifier);
      await notifier.loadReviews();

      final state = container.read(reviewListNotifierProvider('shop-1'));
      expect(state.status, ReviewListStatus.loaded);
      expect(state.reviews.length, 2);
      expect(state.hasNext, true);
      expect(state.totalElements, 42);
    });

    test('should call usecase with correct params', () async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(pagedReviews));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reviewListNotifierProvider('shop-1').notifier);
      await notifier.loadReviews();

      verify(() => mockUseCase(const GetShopReviewsParams(
            shopId: 'shop-1',
            page: 0,
            size: 20,
            sort: 'createdAt,desc',
          ))).called(1);
    });

    test('should handle load failure', () async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => const Left(ServerFailure('리뷰 로드 실패')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reviewListNotifierProvider('shop-1').notifier);
      await notifier.loadReviews();

      final state = container.read(reviewListNotifierProvider('shop-1'));
      expect(state.status, ReviewListStatus.error);
      expect(state.errorMessage, '리뷰 로드 실패');
    });

    test('should load more reviews and append', () async {
      when(() => mockUseCase(const GetShopReviewsParams(
            shopId: 'shop-1',
            page: 0,
            size: 20,
            sort: 'createdAt,desc',
          ))).thenAnswer((_) async => Right(pagedReviews));

      when(() => mockUseCase(const GetShopReviewsParams(
            shopId: 'shop-1',
            page: 1,
            size: 20,
            sort: 'createdAt,desc',
          ))).thenAnswer((_) async => Right(lastPageReviews));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reviewListNotifierProvider('shop-1').notifier);
      await notifier.loadReviews();
      await notifier.loadMore();

      final state = container.read(reviewListNotifierProvider('shop-1'));
      expect(state.reviews.length, 3);
      expect(state.hasNext, false);
      expect(state.currentPage, 1);
    });

    test('should not load more when hasNext is false', () async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(lastPageReviews));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reviewListNotifierProvider('shop-1').notifier);
      await notifier.loadReviews();
      await notifier.loadMore();

      verify(() => mockUseCase(any())).called(1);
    });

    test('should not load more when already loading', () async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(pagedReviews));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reviewListNotifierProvider('shop-1').notifier);
      await notifier.loadReviews();

      when(() => mockUseCase(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return Right(lastPageReviews);
      });

      notifier.loadMore();
      await notifier.loadMore();

      verify(() => mockUseCase(const GetShopReviewsParams(
            shopId: 'shop-1',
            page: 1,
            size: 20,
            sort: 'createdAt,desc',
          ))).called(1);
    });

    test('should change sort and reload', () async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(pagedReviews));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reviewListNotifierProvider('shop-1').notifier);
      await notifier.loadReviews();
      await notifier.changeSort(ReviewSortType.highestRating);

      final state = container.read(reviewListNotifierProvider('shop-1'));
      expect(state.sortType, ReviewSortType.highestRating);
      expect(state.currentPage, 0);

      verify(() => mockUseCase(const GetShopReviewsParams(
            shopId: 'shop-1',
            page: 0,
            size: 20,
            sort: 'rating,desc',
          ))).called(1);
    });

    test('should handle load more failure without losing existing data',
        () async {
      when(() => mockUseCase(const GetShopReviewsParams(
            shopId: 'shop-1',
            page: 0,
            size: 20,
            sort: 'createdAt,desc',
          ))).thenAnswer((_) async => Right(pagedReviews));

      when(() => mockUseCase(const GetShopReviewsParams(
            shopId: 'shop-1',
            page: 1,
            size: 20,
            sort: 'createdAt,desc',
          ))).thenAnswer((_) async => const Left(ServerFailure('네트워크 오류')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(reviewListNotifierProvider('shop-1').notifier);
      await notifier.loadReviews();
      await notifier.loadMore();

      final state = container.read(reviewListNotifierProvider('shop-1'));
      expect(state.reviews.length, 2);
      expect(state.status, ReviewListStatus.error);
    });
  });
}
