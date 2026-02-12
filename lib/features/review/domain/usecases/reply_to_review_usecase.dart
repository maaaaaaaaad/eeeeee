import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/review/domain/repositories/review_repository.dart';

class ReplyToReviewUseCase
    extends UseCase<Either<Failure, void>, ReplyToReviewParams> {
  final ReviewRepository repository;

  ReplyToReviewUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ReplyToReviewParams params) {
    return repository.replyToReview(
      shopId: params.shopId,
      reviewId: params.reviewId,
      content: params.content,
    );
  }
}

class ReplyToReviewParams extends Equatable {
  final String shopId;
  final String reviewId;
  final String content;

  const ReplyToReviewParams({
    required this.shopId,
    required this.reviewId,
    required this.content,
  });

  @override
  List<Object?> get props => [shopId, reviewId, content];
}
