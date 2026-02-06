import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

class BeautyShopModel extends BeautyShop {
  const BeautyShopModel({
    required super.id,
    required super.name,
    required super.regNum,
    required super.phoneNumber,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.operatingTime,
    super.description,
    required super.images,
    required super.averageRating,
    required super.reviewCount,
    required super.categories,
  });

  factory BeautyShopModel.fromJson(Map<String, dynamic> json) {
    return BeautyShopModel(
      id: json['id'] as String,
      name: json['name'] as String,
      regNum: json['regNum'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      operatingTime: (json['operatingTime'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      description: json['description'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => CategorySummaryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CategorySummaryModel extends CategorySummary {
  const CategorySummaryModel({
    required super.id,
    required super.name,
  });

  factory CategorySummaryModel.fromJson(Map<String, dynamic> json) {
    return CategorySummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
