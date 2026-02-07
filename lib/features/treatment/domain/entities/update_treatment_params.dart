import 'package:equatable/equatable.dart';

class UpdateTreatmentParams extends Equatable {
  final String treatmentId;
  final String name;
  final int price;
  final int duration;
  final String? description;

  const UpdateTreatmentParams({
    required this.treatmentId,
    required this.name,
    required this.price,
    required this.duration,
    this.description,
  });

  @override
  List<Object?> get props => [treatmentId, name, price, duration, description];
}
