import 'package:equatable/equatable.dart';

class TreatmentDraft extends Equatable {
  final String name;
  final int price;
  final int duration;
  final String? description;

  const TreatmentDraft({
    required this.name,
    required this.price,
    required this.duration,
    this.description,
  });

  TreatmentDraft copyWith({
    String? name,
    int? price,
    int? duration,
    String? Function()? description,
  }) {
    return TreatmentDraft(
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      description: description != null ? description() : this.description,
    );
  }

  @override
  List<Object?> get props => [name, price, duration, description];
}
