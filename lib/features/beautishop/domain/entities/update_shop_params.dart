import 'package:equatable/equatable.dart';

class UpdateShopParams extends Equatable {
  final String shopId;
  final Map<String, String> operatingTime;
  final String? shopDescription;
  final List<String> shopImages;
  final List<String> menuImages;

  const UpdateShopParams({
    required this.shopId,
    required this.operatingTime,
    this.shopDescription,
    required this.shopImages,
    this.menuImages = const [],
  });

  @override
  List<Object?> get props =>
      [shopId, operatingTime, shopDescription, shopImages, menuImages];
}
