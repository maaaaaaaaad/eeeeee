import 'package:mobile_owner/features/beautishop/domain/entities/geocode_result.dart';

class GeocodeResultModel extends GeocodeResult {
  const GeocodeResultModel({
    required super.roadAddress,
    required super.jibunAddress,
    required super.latitude,
    required super.longitude,
  });

  factory GeocodeResultModel.fromJson(Map<String, dynamic> json) {
    return GeocodeResultModel(
      roadAddress: json['roadAddress'] as String? ?? '',
      jibunAddress: json['jibunAddress'] as String? ?? '',
      latitude: double.parse(json['y'] as String),
      longitude: double.parse(json['x'] as String),
    );
  }

  static List<GeocodeResultModel> fromApiResponse(
    Map<String, dynamic> response,
  ) {
    final addresses = response['addresses'] as List<dynamic>?;
    if (addresses == null || addresses.isEmpty) return [];

    return addresses
        .map((e) => GeocodeResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
