class UpdateTreatmentRequest {
  final String name;
  final int price;
  final int duration;
  final String? description;

  const UpdateTreatmentRequest({
    required this.name,
    required this.price,
    required this.duration,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
      'description': description,
    };
  }
}
