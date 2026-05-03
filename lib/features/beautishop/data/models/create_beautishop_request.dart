class CreateBeautishopRequest {
  final String name;
  final String regNum;
  final String phoneNumber;
  final String address;
  final double latitude;
  final double longitude;
  final Map<String, String> operatingTime;
  final String? shopDescription;
  final List<String> shopImages;
  final List<String> menuImages;

  const CreateBeautishopRequest({
    required this.name,
    required this.regNum,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.operatingTime,
    this.shopDescription,
    required this.shopImages,
    this.menuImages = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'shopName': name,
      'shopRegNum': regNum,
      'shopPhoneNumber': phoneNumber,
      'shopAddress': address,
      'latitude': latitude,
      'longitude': longitude,
      'operatingTime': operatingTime,
      'shopDescription': shopDescription,
      'shopImages': shopImages,
      'menuImages': menuImages,
    };
  }
}
