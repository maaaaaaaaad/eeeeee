import 'package:equatable/equatable.dart';

class Treatment extends Equatable {
  final String id;
  final String shopId;
  final String name;
  final int price;
  final int duration;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Treatment({
    required this.id,
    required this.shopId,
    required this.name,
    required this.price,
    required this.duration,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id];
}
