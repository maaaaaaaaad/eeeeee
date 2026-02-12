import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/review/domain/entities/paged_shop_reviews.dart';
import 'package:mobile_owner/features/review/domain/entities/shop_review.dart';
import 'package:mobile_owner/features/review/domain/usecases/get_shop_reviews_usecase.dart';
import 'package:mobile_owner/features/review/presentation/pages/review_list_page.dart';
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
      createdAt: DateTime(2024, 6, 15),
      updatedAt: DateTime(2024, 6, 15),
    ),
    ShopReview(
      id: 'r-2',
      shopId: 'shop-1',
      memberId: 'member-2',
      authorName: '김영희',
      rating: 3,
      content: '보통이에요',
      images: [],
      createdAt: DateTime(2024, 6, 14),
      updatedAt: DateTime(2024, 6, 14),
    ),
  ];

  final pagedReviews = PagedShopReviews(
    items: reviews,
    hasNext: false,
    totalElements: 2,
  );

  Widget createWidget({
    double averageRating = 4.3,
    int reviewCount = 42,
  }) {
    return ProviderScope(
      overrides: [
        getShopReviewsUseCaseProvider.overrideWithValue(mockUseCase),
      ],
      child: MaterialApp(
        home: ReviewListPage(
          shopId: 'shop-1',
          averageRating: averageRating,
          reviewCount: reviewCount,
        ),
      ),
    );
  }

  group('ReviewListPage', () {
    testWidgets('should display app bar title', (tester) async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(pagedReviews));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('리뷰 관리'), findsOneWidget);
    });

    testWidgets('should display review cards when loaded', (tester) async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(pagedReviews));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('홍**'), findsOneWidget);
      expect(find.text('김**'), findsOneWidget);
    });

    testWidgets('should display stats header', (tester) async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(pagedReviews));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('4.3'), findsOneWidget);
      expect(find.textContaining('42건'), findsOneWidget);
    });

    testWidgets('should display empty message when no reviews', (tester) async {
      when(() => mockUseCase(any())).thenAnswer((_) async =>
          const Right(PagedShopReviews(
              items: [], hasNext: false, totalElements: 0)));

      await tester.pumpWidget(createWidget(
        averageRating: 0.0,
        reviewCount: 0,
      ));
      await tester.pumpAndSettle();

      expect(find.text('아직 리뷰가 없습니다'), findsOneWidget);
    });

    testWidgets('should display error message on failure', (tester) async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => const Left(ServerFailure('리뷰 로드 실패')));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('리뷰 로드 실패'), findsOneWidget);
    });

    testWidgets('should display loading indicator initially', (tester) async {
      final completer = Completer<Either<Failure, PagedShopReviews>>();
      when(() => mockUseCase(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(Right(pagedReviews));
      await tester.pumpAndSettle();
    });
  });
}
