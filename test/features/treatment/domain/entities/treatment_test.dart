import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';

void main() {
  group('Treatment', () {
    test('should create with all required fields', () {
      final treatment = Treatment(
        id: 't-1',
        shopId: 'shop-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
        description: '기본 젤네일 시술',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(treatment.id, 't-1');
      expect(treatment.shopId, 'shop-1');
      expect(treatment.name, '젤네일');
      expect(treatment.price, 30000);
      expect(treatment.duration, 60);
      expect(treatment.description, '기본 젤네일 시술');
    });

    test('should allow null description', () {
      final treatment = Treatment(
        id: 't-1',
        shopId: 'shop-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(treatment.description, isNull);
    });

    test('should support value equality by id', () {
      final a = Treatment(
        id: 't-1',
        shopId: 'shop-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final b = Treatment(
        id: 't-1',
        shopId: 'shop-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(a, b);
    });

    test('should not be equal with different ids', () {
      final a = Treatment(
        id: 't-1',
        shopId: 'shop-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final b = Treatment(
        id: 't-2',
        shopId: 'shop-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(a, isNot(b));
    });
  });
}
