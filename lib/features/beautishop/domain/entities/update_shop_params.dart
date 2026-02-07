import 'package:equatable/equatable.dart';

class UpdateShopParams extends Equatable {
  final String shopId;
  final Map<String, String> operatingTime;
  final String? shopDescription;
  final List<String> shopImages;

  const UpdateShopParams({
    required this.shopId,
    required this.operatingTime,
    this.shopDescription,
    required this.shopImages,
  });

  @override
  List<Object?> get props => [shopId, operatingTime, shopDescription, shopImages];
}
