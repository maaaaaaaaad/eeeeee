import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/treatment/data/models/create_treatment_request.dart';

void main() {
  group('CreateTreatmentRequest', () {
    test('should convert to JSON with all fields', () {
      const request = CreateTreatmentRequest(
        name: '젤네일',
        price: 30000,
        duration: 60,
        description: '기본 젤네일',
      );

      final json = request.toJson();

      expect(json['name'], '젤네일');
      expect(json['price'], 30000);
      expect(json['duration'], 60);
      expect(json['description'], '기본 젤네일');
    });

    test('should handle null description in JSON', () {
      const request = CreateTreatmentRequest(
        name: '젤네일',
        price: 30000,
        duration: 60,
      );

      final json = request.toJson();

      expect(json['description'], isNull);
    });
  });
}
