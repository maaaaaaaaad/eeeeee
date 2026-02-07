import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/treatment/domain/entities/create_treatment_params.dart';

void main() {
  group('CreateTreatmentParams', () {
    test('should create with all fields', () {
      const params = CreateTreatmentParams(
        shopId: 'shop-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
        description: '기본 젤네일',
      );

      expect(params.shopId, 'shop-1');
      expect(params.name, '젤네일');
      expect(params.price, 30000);
      expect(params.duration, 60);
      expect(params.description, '기본 젤네일');
    });

    test('should allow null description', () {
      const params = CreateTreatmentParams(
        shopId: 'shop-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
      );

      expect(params.description, isNull);
    });

    test('should support value equality', () {
      const a = CreateTreatmentParams(
        shopId: 'shop-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
      );
      const b = CreateTreatmentParams(
        shopId: 'shop-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
      );
      expect(a, b);
    });
  });
}
