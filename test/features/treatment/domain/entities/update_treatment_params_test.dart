import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/treatment/domain/entities/update_treatment_params.dart';

void main() {
  group('UpdateTreatmentParams', () {
    test('should create with all fields', () {
      const params = UpdateTreatmentParams(
        treatmentId: 't-1',
        name: '젤네일 수정',
        price: 35000,
        duration: 90,
        description: '수정된 설명',
      );

      expect(params.treatmentId, 't-1');
      expect(params.name, '젤네일 수정');
      expect(params.price, 35000);
      expect(params.duration, 90);
      expect(params.description, '수정된 설명');
    });

    test('should allow null description', () {
      const params = UpdateTreatmentParams(
        treatmentId: 't-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
      );

      expect(params.description, isNull);
    });

    test('should support value equality', () {
      const a = UpdateTreatmentParams(
        treatmentId: 't-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
      );
      const b = UpdateTreatmentParams(
        treatmentId: 't-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
      );
      expect(a, b);
    });
  });
}
