import 'package:equatable/equatable.dart';

class GeocodeResult extends Equatable {
  final String roadAddress;
  final String jibunAddress;
  final double latitude;
  final double longitude;

  const GeocodeResult({
    required this.roadAddress,
    required this.jibunAddress,
    required this.latitude,
    required this.longitude,
  });

  String get displayAddress =>
      roadAddress.isNotEmpty ? roadAddress : jibunAddress;

  @override
  List<Object?> get props => [roadAddress, jibunAddress, latitude, longitude];
}
