import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/review/domain/repositories/review_repository.dart';
import 'package:mobile_owner/features/review/domain/usecases/delete_review_reply_usecase.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late MockReviewRepository mockRepository;
  late DeleteReviewReplyUseCase useCase;

  setUp(() {
    mockRepository = MockReviewRepository();
    useCase = DeleteReviewReplyUseCase(mockRepository);
  });

  const params = DeleteReviewReplyParams(
    shopId: 'shop-1',
    reviewId: 'review-1',
  );

  test('should call repository deleteReviewReply with correct params',
      () async {
    when(() => mockRepository.deleteReviewReply(
          shopId: 'shop-1',
          reviewId: 'review-1',
        )).thenAnswer((_) async => const Right(null));

    final result = await useCase(params);

    expect(result.isRight(), true);
    verify(() => mockRepository.deleteReviewReply(
          shopId: 'shop-1',
          reviewId: 'review-1',
        )).called(1);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.deleteReviewReply(
          shopId: any(named: 'shopId'),
          reviewId: any(named: 'reviewId'),
        )).thenAnswer((_) async => const Left(ServerFailure('답글 삭제 실패')));

    final result = await useCase(params);

    expect(result.isLeft(), true);
  });
}
