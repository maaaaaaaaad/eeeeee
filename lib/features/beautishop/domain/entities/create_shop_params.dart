import 'package:equatable/equatable.dart';

class CreateShopParams extends Equatable {
  final String name;
  final String regNum;
  final String phoneNumber;
  final String address;
  final double latitude;
  final double longitude;
  final Map<String, String> operatingTime;
  final String? shopDescription;
  final List<String> shopImages;

  const CreateShopParams({
    required this.name,
    required this.regNum,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.operatingTime,
    this.shopDescription,
    this.shopImages = const [],
  });

  @override
  List<Object?> get props => [
        name,
        regNum,
        phoneNumber,
        address,
        latitude,
        longitude,
        operatingTime,
        shopDescription,
        shopImages,
      ];
}
