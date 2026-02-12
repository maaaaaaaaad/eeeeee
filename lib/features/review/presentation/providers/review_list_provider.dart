import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/review/domain/entities/shop_review.dart';
import 'package:mobile_owner/features/review/domain/usecases/delete_review_reply_usecase.dart';
import 'package:mobile_owner/features/review/domain/usecases/get_shop_reviews_usecase.dart';
import 'package:mobile_owner/features/review/domain/usecases/reply_to_review_usecase.dart';
import 'package:mobile_owner/features/review/presentation/providers/review_provider.dart';

final reviewListNotifierProvider = AutoDisposeNotifierProviderFamily<
    ReviewListNotifier, ReviewListState, String>(
  () => ReviewListNotifier(),
);

class ReviewListNotifier
    extends AutoDisposeFamilyNotifier<ReviewListState, String> {
  static const _pageSize = 20;

  @override
  ReviewListState build(String shopId) {
    return const ReviewListState();
  }

  Future<void> loadReviews() async {
    state = state.copyWith(status: ReviewListStatus.loading);

    final useCase = ref.read(getShopReviewsUseCaseProvider);
    final result = await useCase(GetShopReviewsParams(
      shopId: arg,
      page: 0,
      size: _pageSize,
      sort: state.sortType.apiValue,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        status: ReviewListStatus.error,
        errorMessage: failure.message,
      ),
      (paged) => state = state.copyWith(
        status: ReviewListStatus.loaded,
        reviews: paged.items,
        hasNext: paged.hasNext,
        currentPage: 0,
        totalElements: paged.totalElements,
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasNext || state.status == ReviewListStatus.loadingMore) return;

    state = state.copyWith(status: ReviewListStatus.loadingMore);

    final nextPage = state.currentPage + 1;
    final useCase = ref.read(getShopReviewsUseCaseProvider);
    final result = await useCase(GetShopReviewsParams(
      shopId: arg,
      page: nextPage,
      size: _pageSize,
      sort: state.sortType.apiValue,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        status: ReviewListStatus.error,
        errorMessage: failure.message,
      ),
      (paged) => state = state.copyWith(
        status: ReviewListStatus.loaded,
        reviews: [...state.reviews, ...paged.items],
        hasNext: paged.hasNext,
        currentPage: nextPage,
      ),
    );
  }

  Future<void> changeSort(ReviewSortType sortType) async {
    if (state.sortType == sortType) return;
    state = state.copyWith(sortType: sortType, currentPage: 0);
    await loadReviews();
  }

  Future<bool> replyToReview(String reviewId, String content) async {
    final useCase = ref.read(replyToReviewUseCaseProvider);
    final result = await useCase(ReplyToReviewParams(
      shopId: arg,
      reviewId: reviewId,
      content: content,
    ));

    return result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        final now = DateTime.now();
        final updatedReviews = state.reviews.map((review) {
          if (review.id == reviewId) {
            return ShopReview(
              id: review.id,
              shopId: review.shopId,
              memberId: review.memberId,
              shopName: review.shopName,
              shopImage: review.shopImage,
              authorName: review.authorName,
              rating: review.rating,
              content: review.content,
              images: review.images,
              createdAt: review.createdAt,
              updatedAt: review.updatedAt,
              ownerReplyContent: content,
              ownerReplyCreatedAt: now,
            );
          }
          return review;
        }).toList();
        state = state.copyWith(reviews: updatedReviews);
        return true;
      },
    );
  }

  Future<bool> deleteReviewReply(String reviewId) async {
    final useCase = ref.read(deleteReviewReplyUseCaseProvider);
    final result = await useCase(DeleteReviewReplyParams(
      shopId: arg,
      reviewId: reviewId,
    ));

    return result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        final updatedReviews = state.reviews.map((review) {
          if (review.id == reviewId) {
            return ShopReview(
              id: review.id,
              shopId: review.shopId,
              memberId: review.memberId,
              shopName: review.shopName,
              shopImage: review.shopImage,
              authorName: review.authorName,
              rating: review.rating,
              content: review.content,
              images: review.images,
              createdAt: review.createdAt,
              updatedAt: review.updatedAt,
            );
          }
          return review;
        }).toList();
        state = state.copyWith(reviews: updatedReviews);
        return true;
      },
    );
  }
}

enum ReviewListStatus { initial, loading, loaded, loadingMore, error }

enum ReviewSortType {
  latestFirst('createdAt,desc'),
  oldestFirst('createdAt,asc'),
  highestRating('rating,desc'),
  lowestRating('rating,asc');

  final String apiValue;
  const ReviewSortType(this.apiValue);
}

class ReviewListState extends Equatable {
  final ReviewListStatus status;
  final List<ShopReview> reviews;
  final bool hasNext;
  final int currentPage;
  final int totalElements;
  final ReviewSortType sortType;
  final String? errorMessage;

  const ReviewListState({
    this.status = ReviewListStatus.initial,
    this.reviews = const [],
    this.hasNext = false,
    this.currentPage = 0,
    this.totalElements = 0,
    this.sortType = ReviewSortType.latestFirst,
    this.errorMessage,
  });

  ReviewListState copyWith({
    ReviewListStatus? status,
    List<ShopReview>? reviews,
    bool? hasNext,
    int? currentPage,
    int? totalElements,
    ReviewSortType? sortType,
    String? errorMessage,
  }) {
    return ReviewListState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      hasNext: hasNext ?? this.hasNext,
      currentPage: currentPage ?? this.currentPage,
      totalElements: totalElements ?? this.totalElements,
      sortType: sortType ?? this.sortType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reviews,
        hasNext,
        currentPage,
        totalElements,
        sortType,
        errorMessage,
      ];
}
