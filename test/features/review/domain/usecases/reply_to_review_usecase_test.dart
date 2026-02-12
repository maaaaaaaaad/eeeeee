import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/review/domain/repositories/review_repository.dart';
import 'package:mobile_owner/features/review/domain/usecases/reply_to_review_usecase.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late MockReviewRepository mockRepository;
  late ReplyToReviewUseCase useCase;

  setUp(() {
    mockRepository = MockReviewRepository();
    useCase = ReplyToReviewUseCase(mockRepository);
  });

  const params = ReplyToReviewParams(
    shopId: 'shop-1',
    reviewId: 'review-1',
    content: '감사합니다!',
  );

  test('should call repository replyToReview with correct params', () async {
    when(() => mockRepository.replyToReview(
          shopId: 'shop-1',
          reviewId: 'review-1',
          content: '감사합니다!',
        )).thenAnswer((_) async => const Right(null));

    final result = await useCase(params);

    expect(result.isRight(), true);
    verify(() => mockRepository.replyToReview(
          shopId: 'shop-1',
          reviewId: 'review-1',
          content: '감사합니다!',
        )).called(1);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.replyToReview(
          shopId: any(named: 'shopId'),
          reviewId: any(named: 'reviewId'),
          content: any(named: 'content'),
        )).thenAnswer((_) async => const Left(ServerFailure('답글 등록 실패')));

    final result = await useCase(params);

    expect(result.isLeft(), true);
  });
}
