import 'package:mobile_owner/features/review/data/models/shop_review_model.dart';
import 'package:mobile_owner/features/review/domain/entities/paged_shop_reviews.dart';

class PagedShopReviewsModel extends PagedShopReviews {
  const PagedShopReviewsModel({
    required super.items,
    required super.hasNext,
    required super.totalElements,
  });

  factory PagedShopReviewsModel.fromJson(Map<String, dynamic> json) {
    return PagedShopReviewsModel(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  ShopReviewModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasNext: json['hasNext'] as bool,
      totalElements: (json['totalElements'] as num).toInt(),
    );
  }
}
