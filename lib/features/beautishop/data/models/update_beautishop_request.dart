class UpdateBeautishopRequest {
  final Map<String, String> operatingTime;
  final String? shopDescription;
  final List<String> shopImages;
  final List<String> menuImages;

  const UpdateBeautishopRequest({
    required this.operatingTime,
    this.shopDescription,
    required this.shopImages,
    this.menuImages = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'operatingTime': operatingTime,
      'shopDescription': shopDescription,
      'shopImages': shopImages,
      'menuImages': menuImages,
    };
  }
}
