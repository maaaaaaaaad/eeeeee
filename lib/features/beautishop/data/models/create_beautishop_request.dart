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
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'regNum': regNum,
      'phoneNumber': phoneNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'operatingTime': operatingTime,
      'shopDescription': shopDescription,
      'shopImages': shopImages,
    };
  }
}
