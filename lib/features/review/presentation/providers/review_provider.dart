import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_owner/features/review/data/datasources/review_remote_datasource.dart';
import 'package:mobile_owner/features/review/data/repositories/review_repository_impl.dart';
import 'package:mobile_owner/features/review/domain/repositories/review_repository.dart';
import 'package:mobile_owner/features/review/domain/usecases/delete_review_reply_usecase.dart';
import 'package:mobile_owner/features/review/domain/usecases/get_shop_reviews_usecase.dart';
import 'package:mobile_owner/features/review/domain/usecases/reply_to_review_usecase.dart';

final reviewRemoteDataSourceProvider =
    Provider<ReviewRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReviewRemoteDataSourceImpl(apiClient: apiClient);
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final remoteDataSource = ref.watch(reviewRemoteDataSourceProvider);
  return ReviewRepositoryImpl(remoteDataSource: remoteDataSource);
});

final getShopReviewsUseCaseProvider =
    Provider<GetShopReviewsUseCase>((ref) {
  return GetShopReviewsUseCase(ref.watch(reviewRepositoryProvider));
});

final replyToReviewUseCaseProvider =
    Provider<ReplyToReviewUseCase>((ref) {
  return ReplyToReviewUseCase(ref.watch(reviewRepositoryProvider));
});

final deleteReviewReplyUseCaseProvider =
    Provider<DeleteReviewReplyUseCase>((ref) {
  return DeleteReviewReplyUseCase(ref.watch(reviewRepositoryProvider));
});
