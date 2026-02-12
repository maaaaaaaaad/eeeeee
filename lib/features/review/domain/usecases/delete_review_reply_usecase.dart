import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/review/domain/repositories/review_repository.dart';

class DeleteReviewReplyUseCase
    extends UseCase<Either<Failure, void>, DeleteReviewReplyParams> {
  final ReviewRepository repository;

  DeleteReviewReplyUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteReviewReplyParams params) {
    return repository.deleteReviewReply(
      shopId: params.shopId,
      reviewId: params.reviewId,
    );
  }
}

class DeleteReviewReplyParams extends Equatable {
  final String shopId;
  final String reviewId;

  const DeleteReviewReplyParams({
    required this.shopId,
    required this.reviewId,
  });

  @override
  List<Object?> get props => [shopId, reviewId];
}
