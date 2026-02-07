import 'package:equatable/equatable.dart';

class CreateTreatmentParams extends Equatable {
  final String shopId;
  final String name;
  final int price;
  final int duration;
  final String? description;

  const CreateTreatmentParams({
    required this.shopId,
    required this.name,
    required this.price,
    required this.duration,
    this.description,
  });

  @override
  List<Object?> get props => [shopId, name, price, duration, description];
}
