import 'package:equatable/equatable.dart';

class BeautyShop extends Equatable {
  final String id;
  final String name;
  final String regNum;
  final String phoneNumber;
  final String address;
  final double latitude;
  final double longitude;
  final Map<String, String> operatingTime;
  final String? description;
  final List<String> images;
  final double averageRating;
  final int reviewCount;
  final List<CategorySummary> categories;

  const BeautyShop({
    required this.id,
    required this.name,
    required this.regNum,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.operatingTime,
    this.description,
    required this.images,
    required this.averageRating,
    required this.reviewCount,
    required this.categories,
  });

  @override
  List<Object?> get props => [id];
}

class CategorySummary extends Equatable {
  final String id;
  final String name;

  const CategorySummary({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
