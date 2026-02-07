import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/treatment/data/models/update_treatment_request.dart';

void main() {
  group('UpdateTreatmentRequest', () {
    test('should convert to JSON with all fields', () {
      const request = UpdateTreatmentRequest(
        name: '젤네일 수정',
        price: 35000,
        duration: 90,
        description: '수정된 설명',
      );

      final json = request.toJson();

      expect(json['name'], '젤네일 수정');
      expect(json['price'], 35000);
      expect(json['duration'], 90);
      expect(json['description'], '수정된 설명');
    });

    test('should handle null description in JSON', () {
      const request = UpdateTreatmentRequest(
        name: '젤네일',
        price: 30000,
        duration: 60,
      );

      final json = request.toJson();

      expect(json['description'], isNull);
    });
  });
}
