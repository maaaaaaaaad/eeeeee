import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';

class TreatmentModel extends Treatment {
  const TreatmentModel({
    required super.id,
    required super.shopId,
    required super.name,
    required super.price,
    required super.duration,
    super.description,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    return TreatmentModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toInt(),
      duration: (json['duration'] as num).toInt(),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
