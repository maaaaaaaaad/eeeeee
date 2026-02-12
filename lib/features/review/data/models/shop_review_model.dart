import 'package:mobile_owner/features/review/domain/entities/shop_review.dart';

class ShopReviewModel extends ShopReview {
  const ShopReviewModel({
    required super.id,
    required super.shopId,
    required super.memberId,
    super.shopName,
    super.shopImage,
    super.authorName,
    super.rating,
    super.content,
    required super.images,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ShopReviewModel.fromJson(Map<String, dynamic> json) {
    return ShopReviewModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      memberId: json['memberId'] as String,
      shopName: json['shopName'] as String?,
      shopImage: json['shopImage'] as String?,
      authorName: json['authorName'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      content: json['content'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
