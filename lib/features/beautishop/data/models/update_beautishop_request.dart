class UpdateBeautishopRequest {
  final Map<String, String> operatingTime;
  final String? shopDescription;
  final List<String> shopImages;

  const UpdateBeautishopRequest({
    required this.operatingTime,
    this.shopDescription,
    required this.shopImages,
  });

  Map<String, dynamic> toJson() {
    return {
      'operatingTime': operatingTime,
      'shopDescription': shopDescription,
      'shopImages': shopImages,
    };
  }
}
